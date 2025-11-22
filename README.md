# Project Descriptions:
Accounts involved (named suggestively):
- *Org* account
- *Master* account

Contracts involved:
- **7702** is the EIP-7702 "contract" assigned to *Org*
- **pMasterControl** (abbreviated **pMC**) is the static proxy.
**7702** always points to this proxy.
This proxy is controllable by *Master*.
This proxy points to **MasterControl**
- **MasterControl** is a Noir ZK filter contract