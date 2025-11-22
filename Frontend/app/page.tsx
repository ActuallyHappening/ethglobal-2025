'use client';

import Image from "next/image";
import { useConnect, useAccount, useDisconnect, useSwitchChain, useConfig, useWalletClient } from 'wagmi';
import { useState } from 'react';
import { parseEther, type Address, createWalletClient, custom, createPublicClient, http, getAddress } from 'viem';
import { eip7702Actions } from 'viem/experimental';

// Dirección del contrato al que se delega
const DELEGATE_CONTRACT = '0xBCAA669EC44d6eCBc291f5cf9cB0215E9784b857' as Address;
const GARFIELD_CHAIN_ID = 48898;

export default function Home() {
  const { connect, connectors, isPending } = useConnect();
  const { address, isConnected, chainId } = useAccount();
  const { disconnect } = useDisconnect();
  const { switchChain } = useSwitchChain();
  const config = useConfig();
  const { data: walletClient } = useWalletClient();
  const [userType, setUserType] = useState<'org' | 'master' | null>(null);
  const [isDeploying, setIsDeploying] = useState(false);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [txError, setTxError] = useState<Error | null>(null);

  const handleSignIn = async (type: 'org' | 'master') => {
    if (isConnected) {
      // Si ya está conectado, solo guardamos el tipo de usuario
      setUserType(type);
      return;
    }

    // Intentar conectar con el conector injected (funciona con MetaMask y otras wallets)
    const connector = connectors.find(c => c.id === 'injected');
    if (connector) {
      try {
        await connect({ connector });
        setUserType(type);
      } catch (error) {
        console.error('Error connecting wallet:', error);
        alert('Error al conectar la wallet. Por favor, asegúrate de tener una wallet instalada (MetaMask, Coinbase Wallet, etc.).');
      }
    } else {
      alert('No se encontró una wallet disponible. Por favor, instala MetaMask u otra wallet compatible.');
    }
  };

  const handleDeploy = async (type: 'org' | 'master') => {
    if (!isConnected || !address) {
      alert('Por favor, conéctate primero con tu wallet.');
      return;
    }

    // Verificar que window.ethereum esté disponible
    if (typeof window === 'undefined' || !(window as any).ethereum) {
      alert('Wallet no disponible. Por favor, asegúrate de tener una wallet instalada.');
      return;
    }

    setIsDeploying(true);

    try {
      // Cambiar a la red Garfield si no está conectado a ella
      if (chainId !== GARFIELD_CHAIN_ID) {
        try {
          await switchChain({ chainId: GARFIELD_CHAIN_ID });
          // Esperar un momento para que el cambio de red se complete
          await new Promise(resolve => setTimeout(resolve, 1000));
        } catch {
          alert('Por favor, cambia manualmente a la red Garfield Testnet en tu wallet.');
          setIsDeploying(false);
          return;
        }
      }

      // Verificar que chainId esté disponible
      if (!chainId) {
        throw new Error('Chain ID no disponible');
      }

      // Obtener la chain actual
      const chain = config.chains.find(c => c.id === chainId) || config.chains[0];

      // Crear public client para obtener el nonce
      const publicClient = createPublicClient({
        chain,
        transport: http(),
      });

      // Obtener el nonce de la cuenta para la autorización
      const nonce = await publicClient.getTransactionCount({ address: address as Address });

      // Construir y firmar la autorización EIP-7702 manualmente usando EIP-712
      // Esto evita el problema con cuentas JSON-RPC en signAuthorization
      const ethereum = (window as any).ethereum;

      // Formato EIP-712 para EIP-7702 Authorization según la especificación
      const domain = {
        chainId: chainId,
        name: 'EIP-7702',
        version: '1',
      };

      const types = {
        EIP7702Authorization: [
          { name: 'chainId', type: 'uint256' },
          { name: 'contractAddress', type: 'address' },
          { name: 'nonce', type: 'uint256' },
        ],
      };

      const message = {
        chainId: chainId.toString(),
        contractAddress: DELEGATE_CONTRACT,
        nonce: nonce.toString(),
      };

      // Firmar usando eth_signTypedData_v4 directamente con la wallet
      const signature = await ethereum.request({
        method: 'eth_signTypedData_v4',
        params: [
          address,
          JSON.stringify({
            domain,
            types,
            primaryType: 'EIP7702Authorization',
            message,
          }),
        ],
      });

      // Construir el objeto de autorización en el formato que espera viem
      // El tipo Authorization espera chainId y nonce como number
      // La firma debe estar en formato r, s, v (extraer de la firma ECDSA)
      // La firma de eth_signTypedData_v4 es una firma ECDSA de 65 bytes: r (32) + s (32) + v (1)
      const sigBytes = signature.slice(2); // Remover '0x'
      const r = `0x${sigBytes.slice(0, 64)}` as `0x${string}`;
      const s = `0x${sigBytes.slice(64, 128)}` as `0x${string}`;
      const v = parseInt(sigBytes.slice(128, 130), 16);
      const yParity = v === 27 ? 0 : 1; // Convertir v a yParity (0 o 1)

      const authorization = {
        chainId: chainId,
        address: getAddress(address),
        contractAddress: getAddress(DELEGATE_CONTRACT),
        nonce: nonce,
        r,
        s,
        yParity,
      } as any; // Usar 'as any' porque el tipo exacto puede variar

      // Crear wallet client y extenderlo con acciones EIP-7702
      let client = walletClient;
      if (!client) {
        client = createWalletClient({
          chain,
          transport: custom(ethereum),
        });
      }

      // Extender el cliente con acciones EIP-7702 para enviar la transacción
      const eip7702Client = client.extend(eip7702Actions);

      // Enviar la transacción EIP-7702 usando el wallet client extendido
      // La transacción se envía a la propia dirección (self-delegation)
      const hash = await eip7702Client.sendTransaction({
        account: address as Address,
        to: address, // Enviar a la propia dirección
        value: parseEther('0'), // Sin valor, solo delegación
        authorizationList: [authorization], // Incluir la autorización firmada manualmente
      });

      setTxHash(hash);
      setIsDeploying(false);
      console.log(`Transacción EIP-7702 enviada (${type}): ${hash}`);
      alert(`Transacción EIP-7702 enviada exitosamente!\nTipo: ${type === 'org' ? 'Organización' : 'Master'}\nHash: ${hash}\n\nVer en explorer: https://explorer.garfield-testnet.zircuit.com/tx/${hash}`);
    } catch (err) {
      const error = err as Error;
      console.error('Error en handleDeploy:', error);
      setTxError(error);
      setIsDeploying(false);
      alert(`Error al procesar la transacción: ${error?.message || 'Error desconocido'}`);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <main className="flex min-h-screen w-full max-w-3xl flex-col items-center justify-between py-32 px-16 bg-white dark:bg-black sm:items-start">
        <Image
          className="dark:invert"
          src="/next.svg"
          alt="Next.js logo"
          width={100}
          height={20}
          priority
        />
        <div className="flex flex-col items-center gap-6 text-center sm:items-start sm:text-left">
          {isConnected && address && (
            <div className="flex flex-col gap-2 p-4 bg-gray-100 dark:bg-gray-900 rounded-lg w-full max-w-md">
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Conectado como: {address.slice(0, 6)}...{address.slice(-4)}
              </p>
              {chainId && (
                <p className="text-xs text-gray-500 dark:text-gray-500">
                  Red: {chainId === GARFIELD_CHAIN_ID ? 'Garfield Testnet' : `Chain ID: ${chainId}`}
                </p>
              )}
              {userType && (
                <p className="text-sm font-semibold">
                  Tipo: {userType === 'org' ? 'Organización' : 'Master'}
                </p>
              )}
              {txHash && (
                <div className="flex flex-col gap-1 mt-2 p-2 bg-green-50 dark:bg-green-900/20 rounded">
                  <p className="text-xs font-semibold text-green-700 dark:text-green-400">
                    ✓ Transacción enviada
                  </p>
                  <a
                    href={`https://explorer.garfield-testnet.zircuit.com/tx/${txHash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs text-blue-600 dark:text-blue-400 hover:underline break-all"
                  >
                    Ver en explorer: {txHash.slice(0, 10)}...{txHash.slice(-8)}
                  </a>
                </div>
              )}
              {isDeploying && (
                <p className="text-xs text-yellow-600 dark:text-yellow-400">
                  ⏳ Procesando transacción...
                </p>
              )}
              {txError && (
                <p className="text-xs text-red-600 dark:text-red-400">
                  ✗ Error: {txError.message}
                </p>
              )}
              <button
                onClick={() => {
                  disconnect();
                  setUserType(null);
                }}
                className="text-xs text-red-600 dark:text-red-400 hover:underline mt-2"
              >
                Desconectar
              </button>
            </div>
          )}
        </div>
        <div className="flex flex-col gap-4 text-base font-medium sm:flex-row">
          <button
            onClick={() => handleSignIn('org')}
            disabled={isPending}
            className="flex h-12 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] disabled:opacity-50 disabled:cursor-not-allowed md:w-[158px]"
          >
            {isPending ? 'Conectando...' : 'Sign-in Org'}
          </button>
          <button
            onClick={() => handleDeploy('org')}
            disabled={!isConnected || isDeploying}
            className="flex h-12 w-full items-center justify-center rounded-full border border-solid border-black/[.08] px-5 transition-colors hover:border-transparent hover:bg-black/[.04] dark:border-white/[.145] dark:hover:bg-[#1a1a1a] disabled:opacity-50 disabled:cursor-not-allowed md:w-[158px]"
          >
            {isDeploying ? 'Enviando...' : 'Deploy Org'}
          </button>
        </div>

        <div className="flex flex-col gap-4 text-base font-medium sm:flex-row">
          <button
            onClick={() => handleSignIn('master')}
            disabled={isPending}
            className="flex h-10 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] disabled:opacity-50 disabled:cursor-not-allowed md:w-[158px]"
          >
            {isPending ? 'Conectando...' : 'Sign-in Master'}
          </button>
          <button
            onClick={() => handleDeploy('master')}
            disabled={!isConnected || isDeploying}
            className="flex h-12 w-full items-center justify-center rounded-full border border-solid border-black/[.08] px-5 transition-colors hover:border-transparent hover:bg-black/[.04] dark:border-white/[.145] dark:hover:bg-[#1a1a1a] disabled:opacity-50 disabled:cursor-not-allowed md:w-[158px]"
          >
            {isDeploying ? 'Enviando...' : 'Deploy Master'}
          </button>
        </div>
      </main>
    </div>
  );
}
