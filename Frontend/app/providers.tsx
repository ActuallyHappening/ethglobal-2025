'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider, createConfig, http } from 'wagmi';
import { mainnet, sepolia, localhost } from 'wagmi/chains';
import { injected } from 'wagmi/connectors';
import { useState } from 'react';
import type { Chain } from 'viem';

// Definir la red Garfield testnet manualmente
const garfieldTestnet: Chain = {
  id: 48898,
  name: 'Garfield Testnet',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: {
      http: ['https://garfield-testnet.zircuit.com'],
    },
  },
  blockExplorers: {
    default: {
      name: 'Garfield Explorer',
      url: 'https://explorer.garfield-testnet.zircuit.com',
    },
  },
  testnet: true,
} as const;

const config = createConfig({
  chains: [garfieldTestnet, mainnet, sepolia, localhost],
  connectors: [
    injected(),
  ],
  transports: {
    [garfieldTestnet.id]: http(),
    [mainnet.id]: http(),
    [sepolia.id]: http(),
    [localhost.id]: http(),
  },
});

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiProvider>
  );
}

