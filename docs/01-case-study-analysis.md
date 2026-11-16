# 01 — Case Study Analysis

**Status:** Designed — not deployed. Missing original inventory tables.

## Facts

- Offices: Singapore (2,000 employees), Doha (1,000), London (200).
- On-premises AD forest and DNS zone: `xFusionCorp.com`. The Entra tenant: `xFusionCorp.onmicrosoft.com`, P1 tier.
- Department OUs: Finance, Human Resources, Sales, Research and Information Technology. User `department` attributes are populated; user accounts are added frequently.
- Private links connect all offices; Singapore and Doha data centres have VPN-capable firewalls.
- App1 and App2 each need 1 GB of memory per instance.

## Missing case-study information

The supplied case references two tables for virtualisation servers and Azure resources, but neither table was provided. We must not treat guessed VM sizes, OS versions, topology or existing App Service plans as facts.

## Requirement mapping

| Requirement | Proposed technology | Status |
| --- | --- | --- |
| Singapore ExpressRoute and automatic route exchange | ExpressRoute private peering + BGP | Design only |
| London encrypted internet connection | Site-to-site IPsec VPN Gateway | Design only |
| VM migration | Azure Migrate | Design only |
| Sync AD identities | Microsoft Entra Connect Sync | Design only |
| Finance-only MFA | Dynamic group by department + Conditional Access | Design only |
| VM3 outbound TCP/8080 | NSG + route/firewall validation | Design only |
| WebApp1 automatic scale up to five instances | Azure App Service autoscale on compatible tier | Design only |
| WebApp2 custom DNS | Custom domain verification and binding | Design only |
| VM4 modification email | Activity Log alert + action group | Design only |
| Role1 based on Reader | Reader-derived custom Azure RBAC role | Script prepared; not deployed |

## Document navigation

- [Architecture](02-architecture-design.md)
- [Identity and governance](03-identity-and-governance.md)
- [Hybrid networking](04-hybrid-networking.md)

The project uses **Designed / Simulated / Deployed and verified** labels throughout to distinguish planning from executed evidence.
