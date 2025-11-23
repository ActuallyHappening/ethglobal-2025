# Project Description: EIP7702 priviledge de-escalation
Priviledge de-escalation EIP7702 enforced by a master EOA with updatable on-chain policies

Privilege de-escalation enforced by a static master address, hereby called _Master_, who reserves the right to update policies enforced on the de-escalated account, hereby called _Org_. The intent is that _Org_ is generally untrusted and needs strictly enforced, on-chain boundaries as controlled by _Master_. This is achieved through an EIP7702 contract with a stored owner (_Master_) address, and which _Org_ unconditionally authorizes himself to be bound to. The EIP7702 contract stores a pointer to the contract address _Master_ wishes to validate, which has the ABI `function verify(address recipient, uint256 amount, bytes calldata data) external view returns (bool);`, and which _Org_'s EIP7702 contract (must) validate against for each transaction. The _Master_ controlled contract can therefore implement any logic it wants, we implemented a whitelist and a maximum native ETH transfer limit as examples.

## How to run project
Install `forge` from Foundry.
Install [`nushell`](https://www.nushell.sh/book/installation.html), you can use `npm install -g nushell`.
```nu
source env.nu
do {
	cd contracts
	forge test
}
# deploys all contracts and verifies them
nu actions/deploy-smartcontracts.nu
```

## The failed ZK aspect
Install `nargo` (from Noir, AZTEC). Install `bb` (from AZTEC).
```nu
nu actions/generate-zk.nu
```


<!---
## Random links

Zircuit Garfield Testnet

Blockchain explorer: https://explorer.garfield-testnet.zircuit.com

How to verify: https://docs.zircuit.com/infra/explorer/verify

EPI-7702: https://eips.ethereum.org/EIPS/eip-7702

Impl foundry: https://viem.sh/docs/eip7702/contract-writes
https://getfoundry.sh/reference/cheatcodes/sign-delegation

docs: https://noir-lang.org/docs/noir/concepts/data_types/integers
--->
