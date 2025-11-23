'use client';

import Image from "next/image";
// import { useConnect, useAccount, useDisconnect, useSwitchChain, useConfig, useWalletClient } from 'wagmi';
import { useState } from 'react';
// import { parseEther, type Address, createWalletClient, custom, createPublicClient, http, getAddress, encodeFunctionData } from 'viem';
// import { eip7702Actions } from 'viem/experimental';

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
  const [activeTab, setActiveTab] = useState<'org' | 'master'>('org');
  const [userType, setUserType] = useState<'org' | 'master' | null>(null);
  const [isDeployingOrg, setIsDeployingOrg] = useState(false);
  const [isDeployingMaster, setIsDeployingMaster] = useState(false);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [txError, setTxError] = useState<Error | null>(null);
  
  // Estados para formularios
  const [orgRecipient, setOrgRecipient] = useState('');
  const [orgAmount, setOrgAmount] = useState('');
  const [masterRecipient, setMasterRecipient] = useState('');
  const [masterAmount, setMasterAmount] = useState('');

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
        alert('Error connecting wallet. Please make sure you have a wallet installed (MetaMask, Coinbase Wallet, etc.).');
      }
    } else {
      alert('No wallet found. Please install MetaMask or another compatible wallet.');
    }
  };

  const handleDeploy = async (type: 'org' | 'master') => {
    if (!isConnected || !address) {
      alert('Please connect your wallet first.');
      return;
    }

    // Obtener valores del formulario según el tipo
    const recipient = type === 'org' ? orgRecipient : masterRecipient;
    const amount = type === 'org' ? orgAmount : masterAmount;

    // Validar campos del formulario
    if (!recipient || !recipient.trim()) {
      alert('Please enter a recipient address.');
      return;
    }

    if (!amount || !amount.trim() || parseFloat(amount) <= 0) {
      alert('Please enter a valid ETH amount (greater than 0).');
      return;
    }

    // Validar que la dirección sea válida
    try {
      getAddress(recipient.trim());
    } catch {
      alert('Please enter a valid Ethereum address.');
      return;
    }

    // Verificar que window.ethereum esté disponible
    if (typeof window === 'undefined' || !(window as any).ethereum) {
      alert('Wallet not available. Please make sure you have a wallet installed.');
      return;
    }

    // Prevenir múltiples ejecuciones simultáneas
    if (isDeployingOrg || isDeployingMaster) {
      return;
    }

    // Establecer el estado de deploy según el tipo
    if (type === 'org') {
      setIsDeployingOrg(true);
    } else {
      setIsDeployingMaster(true);
    }

    try {
      // Cambiar a la red Garfield si no está conectado a ella
      if (chainId !== GARFIELD_CHAIN_ID) {
        try {
          await switchChain({ chainId: GARFIELD_CHAIN_ID });
          // Esperar un momento para que el cambio de red se complete
          await new Promise(resolve => setTimeout(resolve, 1000));
        } catch {
          alert('Please manually switch to Garfield Testnet in your wallet.');
          if (type === 'org') {
            setIsDeployingOrg(false);
          } else {
            setIsDeployingMaster(false);
          }
          return;
        }
      }

      // Verificar que chainId esté disponible
      if (!chainId) {
        throw new Error('Chain ID not available');
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

      // Preparar los datos para llamar a la función execute del contrato
      const recipientAddress = getAddress(recipient.trim());
      const amountInWei = parseEther(amount);

      // ABI de la función execute con el struct Call
      const executeABI = [
        {
          name: 'execute',
          type: 'function',
          stateMutability: 'payable',
          inputs: [
            {
              name: 'calls',
              type: 'tuple[]',
              components: [
                { name: 'to', type: 'address' },
                { name: 'value', type: 'uint256' },
                { name: 'data', type: 'bytes' },
              ],
            },
          ],
          outputs: [],
        },
      ] as const;

      // Crear el array de Call con los datos del usuario
      // Para una transferencia simple, el data está vacío
      const calls = [
        {
          to: recipientAddress,
          value: amountInWei,
          data: '0x' as `0x${string}`, // Sin datos adicionales, solo transferencia
        },
      ];

      // Encodear los datos de la función execute
      const encodedData = encodeFunctionData({
        abi: executeABI,
        functionName: 'execute',
        args: [calls],
      });

      // Enviar la transacción EIP-7702 llamando a la función execute del contrato
      // La transacción se envía a la dirección del usuario (self-delegation)
      // pero los datos codificados llaman a execute del contrato DELEGATE_CONTRACT
      const hash = await eip7702Client.sendTransaction({
        account: address as Address,
        to: address, // Enviar a la propia dirección (self-delegation con EIP-7702)
        value: BigInt(0), // El valor se pasa dentro del Call
        data: encodedData, // Datos codificados para llamar a execute
        authorizationList: [authorization], // Incluir la autorización firmada manualmente
      });

      setTxHash(hash);
      if (type === 'org') {
        setIsDeployingOrg(false);
      } else {
        setIsDeployingMaster(false);
      }
      console.log(`EIP-7702 transaction sent (${type}): ${hash}`);
      alert(`EIP-7702 transaction sent successfully!\nType: ${type === 'org' ? 'Organization' : 'Master'}\nHash: ${hash}\n\nView in explorer: https://explorer.garfield-testnet.zircuit.com/tx/${hash}`);
    } catch (err) {
      const error = err as Error;
      console.error('Error in handleDeploy:', error);
      setTxError(error);
      if (type === 'org') {
        setIsDeployingOrg(false);
      } else {
        setIsDeployingMaster(false);
      }
      alert(`Error processing transaction: ${error?.message || 'Unknown error'}`);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <main className="flex min-h-screen w-full max-w-3xl flex-col items-center justify-between py-10 px-16 bg-white dark:bg-black sm:items-start">
        
        <div className="flex flex-col items-center gap-6 text-center sm:items-start sm:text-left">
          {isConnected && address && (
            <div className="flex flex-col gap-2 p-4 bg-gray-100 dark:bg-gray-900 rounded-lg w-full max-w-md">
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Connected as: {address.slice(0, 6)}...{address.slice(-4)}
              </p>
              {chainId && (
                <p className="text-xs text-gray-500 dark:text-gray-500">
                  Network: {chainId === GARFIELD_CHAIN_ID ? 'Garfield Testnet' : `Chain ID: ${chainId}`}
                </p>
              )}
              {userType && (
                <p className="text-sm font-semibold">
                  Type: {userType === 'org' ? 'Organization' : 'Master'}
                </p>
              )}
              {txHash && (
                <div className="flex flex-col gap-1 mt-2 p-2 bg-green-50 dark:bg-green-900/20 rounded">
                  <p className="text-xs font-semibold text-green-700 dark:text-green-400">
                    ✓ Transaction sent
                  </p>
                  <a
                    href={`https://explorer.garfield-testnet.zircuit.com/tx/${txHash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs text-blue-600 dark:text-blue-400 hover:underline break-all"
                  >
                    View in explorer: {txHash.slice(0, 10)}...{txHash.slice(-8)}
                  </a>
                </div>
              )}
              {(isDeployingOrg || isDeployingMaster) && (
                <p className="text-xs text-yellow-600 dark:text-yellow-400">
                  ⏳ Processing transaction...
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
                Disconnect
              </button>
            </div>
          )}
        </div>
        {/* Tabs para Org y Master */}
        <div className="w-full max-w-2xl">
          <div className="flex border-b border-gray-200 dark:border-gray-700 mb-6">
            <button
              onClick={() => setActiveTab('org')}
              className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
                activeTab === 'org'
                  ? 'border-b-2 border-blue-600 text-blue-600 dark:text-blue-400'
                  : 'text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'
              }`}
            >
              Organization
            </button>
            <button
              onClick={() => setActiveTab('master')}
              className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
                activeTab === 'master'
                  ? 'border-b-2 border-blue-600 text-blue-600 dark:text-blue-400'
                  : 'text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'
              }`}
            >
              Master
            </button>
          </div>

          {/* Contenido del tab Org */}
          {activeTab === 'org' && (
            <div className="space-y-6">
              <div className="flex flex-col gap-4">
                <button
                  onClick={() => handleSignIn('org')}
                  disabled={isPending || isConnected}
                  className="flex h-12 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isPending ? 'Connecting...' : isConnected ? 'Connected' : 'Sign-in Org'}
                </button>
              </div>

              {isConnected && (
                <div className="space-y-4 p-6 border border-gray-200 dark:border-gray-700 rounded-lg">
                  <h3 className="text-lg font-semibold mb-4">Send Transfer</h3>
                  
                  <div className="space-y-4">
                    <div>
                      <label htmlFor="org-recipient" className="block text-sm font-medium mb-2">
                        Recipient Address
                      </label>
                      <input
                        id="org-recipient"
                        type="text"
                        value={orgRecipient}
                        onChange={(e) => setOrgRecipient(e.target.value)}
                        placeholder="0x..."
                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>

                    <div>
                      <label htmlFor="org-amount" className="block text-sm font-medium mb-2">
                        Amount (ETH)
                      </label>
                      <input
                        id="org-amount"
                        type="number"
                        step="any"
                        min="0"
                        value={orgAmount}
                        onChange={(e) => setOrgAmount(e.target.value)}
                        placeholder="0.0"
                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>

                    <button
                      onClick={() => handleDeploy('org')}
                      disabled={!isConnected || isDeployingOrg || isDeployingMaster}
                      className="w-full flex h-12 items-center justify-center rounded-full bg-blue-600 px-5 text-white transition-colors hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isDeployingOrg ? 'Sending...' : 'Deploy Org'}
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Contenido del tab Master */}
          {activeTab === 'master' && (
            <div className="space-y-6">
              <div className="flex flex-col gap-4">
                <button
                  onClick={() => handleSignIn('master')}
                  disabled={isPending || isConnected}
                  className="flex h-12 w-full items-center justify-center gap-2 rounded-full bg-foreground px-5 text-background transition-colors hover:bg-[#383838] dark:hover:bg-[#ccc] disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isPending ? 'Connecting...' : isConnected ? 'Connected' : 'Sign-in Master'}
                </button>
              </div>

              {isConnected && (
                <div className="space-y-4 p-6 border border-gray-200 dark:border-gray-700 rounded-lg">
                  <h3 className="text-lg font-semibold mb-4">Send Transfer</h3>
                  
                  <div className="space-y-4">
                    <div>
                      <label htmlFor="master-recipient" className="block text-sm font-medium mb-2">
                        Recipient Address
                      </label>
                      <input
                        id="master-recipient"
                        type="text"
                        value={masterRecipient}
                        onChange={(e) => setMasterRecipient(e.target.value)}
                        placeholder="0x..."
                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>

                    <div>
                      <label htmlFor="master-amount" className="block text-sm font-medium mb-2">
                        Amount (ETH)
                      </label>
                      <input
                        id="master-amount"
                        type="number"
                        step="any"
                        min="0"
                        value={masterAmount}
                        onChange={(e) => setMasterAmount(e.target.value)}
                        placeholder="0.0"
                        className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>

                    <button
                      onClick={() => handleDeploy('master')}
                      disabled={!isConnected || isDeployingOrg || isDeployingMaster}
                      className="w-full flex h-12 items-center justify-center rounded-full bg-blue-600 px-5 text-white transition-colors hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isDeployingMaster ? 'Sending...' : 'Deploy Master'}
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
