# Project Description: EIP7702 priviledge de-escalation
Privilege de-escalation EIP7702 enforced by a master EOA with updatable on-chain policies

Privilege de-escalation enforced by a static master address, hereby called _Master_, who reserves the right to update policies enforced on the de-escalated account, hereby called _Org_. The intent is that _Org_ is generally untrusted and needs strictly enforced, on-chain boundaries as controlled by _Master_. This is achieved through an EIP7702 contract with a stored owner (_Master_) address, and which _Org_ unconditionally authorizes himself to be bound to. The EIP7702 contract stores a pointer to the contract address _Master_ wishes to validate, which has the ABI `function verify(address recipient, uint256 amount, bytes calldata data) external view returns (bool);`, and which _Org_'s EIP7702 contract (must) validate against for each transaction. The _Master_ controlled contract can therefore implement any logic it wants, we implemented a whitelist and a maximum native ETH transfer limit as examples.

The project was deployed on the polygon chain.
This L1 with permissionless validators had low gas fees and fast transaction times, great for development and UX!
We used Foundry for contract creation testing and deployment, as well as verification.
Noir from AZTEC was going to be used as well, however it turns out that the ZK cryptographic primitive doesn't preserve the privacy
of policies that _Master_ sets unfortunately.

### Problems with this approach
An EOA can always revoke an authorisation. There is no way for _Master_ to prevent this.
Therefore EIP7702 can't effectively be used as privilege de-escalation.
I am not an expert, however, potentially the EIP7702 attached code may be able to intercept this type-4 TX?
I haven't tried yet, so this may be a non-issue.

I have since discovered that after upgrading your contract to an EIP7702 smart-EOA, you can't continue to send "raw"
transactions in general as there is a [2300 gas limit](https://solidity-by-example.org/fallback/).
This makes me sad.
The currently accepted "standard" (which should really be written up as an EIP) is an `execute` function,
see [here](https://github.com/ActuallyHappening/ethglobal-2025/blob/aa98ceab4eb18bbd6cf546bf326c10c02c6395fa/contracts/src/EIP7702.sol#L63).

### Things not yet implemented
Due to time and learning constraints, there are no tests for actually sending transactions to the EIP7702 EOA code.
This is due to some technical bugs I couldn't solve, like `Vm.SignedDelegation` doesn't exist and I can't work out how to
update forge-std.


### Future considerations
The initial goal of this project was to maintain privacy in the policies set by _Master_.
I put a lot of work and manny hours into building some `Noir` circuits, see [the circuits folder](./circuits)
and [the generate-zk.nu script](./actions/generate-zk.nu).
Unfortunately, I didn't understand ZK enough when I first started hacking (absolutely no experience before)
and so didn't realise the policies had to be enforced onchain, which means they must be *public* because onchain means public.
AZTEC would solve this problem, but I didn't have enough time from realising my mistake!
I also wrote my first lines of Solidity, deployed and verified my first smart contract, and wrote my first Foundry tests
in this hackathon which ate up a significant amount of time.


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

### The failed ZK aspect
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
