# Lab Environment Diagram

```mermaid
flowchart TB

    Internet((Internet))

    Bastion["Azure Bastion Developer<br/>Administrative access"]

    subgraph Azure["Azure Lab Environment"]
        direction TB

        subgraph VNet["vnet-portfolio-lab<br/>10.0.0.0/24"]
            direction LR

            DC["dc01<br/>Windows Server 2022<br/>10.0.0.4<br/>AD DS + DNS"]

            Client["client01<br/>Windows 11 Enterprise<br/>Domain joined<br/>DNS → dc01"]
        end
    end

    Internet --> Bastion
    Bastion --> DC
    Bastion --> Client

    Client -->|"Domain authentication<br/>DNS / SMB"| DC

    subgraph Identity["northstar.test identity and access model"]
        direction TB

        Alice["operations.alice"]
        Chris["finance.chris"]

        OpsGroup["SG_Operations_Access"]
        FinGroup["SG_Finance_Access"]

        OpsShare["\\\\dc01\\Operations<br/>Share: Read<br/>NTFS: Read & Execute"]
        FinShare["\\\\dc01\\Finance<br/>Share: Read<br/>NTFS: Read & Execute"]

        Alice --> OpsGroup
        Chris --> FinGroup

        OpsGroup --> OpsShare
        FinGroup --> FinShare
    end

    DC --- Identity
