# xFusionCorp — Azure Infrastructure Migration (AZ-104)

## Overview

A practical, documented design and implementation project based on an AZ-104 case study for xFusionCorp Ltd. The company has 3,200 employees across Singapore (2,000), Doha (1,000), and London (200), with existing on-premises infrastructure and a new Azure subscription.

> **Project status: Planning.** This is a case-study exercise, not a verified production deployment. The original case references two missing inventory tables. Assumptions and simulated components are explicitly identified.

## Goals

- Synchronise on-premises Active Directory with Microsoft Entra ID.
- Enable MFA for the Finance department only.
- Design Singapore ExpressRoute connectivity with dynamic route exchange (BGP).
- Design an encrypted London-to-Azure site-to-site VPN.
- Plan VM migration from Server1 and Server2 to Azure.
- Allow VM3 outbound TCP 8080 to Singapore application servers.
- Migrate App1 and App2 to Azure App Service; autoscale WebApp1 up to five instances.
- Map `app2.xFusionCorp.com` to WebApp2 (requires domain ownership/control).
- Alert by email when VM4 settings are modified.
- Define a custom Azure RBAC role based on Reader.
- Minimise costs where feasible.

## Repository layout

```text
.
├── README.md
├── docs/
│   ├── 01-case-study-analysis.md
│   ├── 02-architecture-design.md
│   ├── 03-identity-and-governance.md
│   ├── 04-hybrid-networking.md
│   ├── 05-vm-migration.md
│   ├── 06-app-service.md
│   ├── 07-monitoring-and-alerts.md
│   └── 08-lessons-learned.md
├── infrastructure/
│   ├── bicep/
│   └── scripts/
├── diagrams/
└── screenshots/
```

## Implementation approach

1. Analyse each requirement and record assumptions.
2. Design the architecture and justify the Azure services chosen.
3. Create Bicep and Azure CLI/Bash automation where feasible.
4. Validate and test only in environments with appropriate permissions.
5. Capture real outputs, errors, costs, and lessons learned.

## Evidence labels

- **Designed** — documented but not deployed.
- **Simulated** — demonstrated with representative lab resources.
- **Deployed and verified** — created and validated in Azure with recorded evidence.

## Security and cost

Never commit passwords, access keys, SAS tokens, tenant secrets, `.env` files, or real credentials. Some services (such as ExpressRoute and VPN Gateway) may be costly or unavailable in restricted labs; their production designs can be documented without claiming deployment.

## Reference

Charles Pluta, *Exam Ref AZ-104 Microsoft Azure Administrator*, 2nd ed., Microsoft Press. The book is a study reference and is not redistributed in this repository.
