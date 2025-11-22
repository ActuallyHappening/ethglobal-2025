# Project Descriptions:
## Problem statement
*Org* is considered untrusted.
All of *Org*s transactions should be filtered by *Master*.
But *Master* doesn't want his policies being public.
- [] And *Master* want's his policies to be applied cross-chain

## Terminology and topology
Accounts involved (named suggestively):
- *Org* account
- *Master* account

Contracts involved:
- **7702** is the EIP-7702 "contract" assigned to *Org*
- **pMasterControl** (abbreviated **pMC**) is the static proxy.
**7702** always points to this proxy.
This proxy is controllable by *Master*.
This proxy points to **MasterControl**.
- **MasterControl** is a Noir ZK filter contract

## Solution
Using ZK, *Master* can deploy his **MasterControl** contract, which takes as
input the details of the transaction and will fail (revert) if the transaction
is deemed invalid.
*Org* then MUST willingly subdue itself under *Master* by deploying its **7702**
contract.

## Requirements
- **7702** contract must be permanent, and must not be able to be taken down by
the contract

## Problems
Since the ZK proof is on chain, anybody can download it and manually run it against
transactions to gain a rough and approximate idea of what policies *Master*
has set.
