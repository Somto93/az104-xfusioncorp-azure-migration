# xFusionCorp — Azure Infrastructure Migration (AZ-104)

## Overview

An AZ-104 practical case-study portfolio documenting a proposed hybrid Azure architecture for xFusionCorp Ltd. The company has offices in Singapore (2,000 employees), Doha (1,000) and London (200) and plans to migrate selected on-premises resources to Azure.

> **Status: Designed / documentation in progress.** The case references two unavailable inventory tables. This repository intentionally distinguishes given facts from assumptions and **does not claim a working production deployment**.

## Requirements covered

- Microsoft Entra Connect Sync for on-premises Active Directory.
- Finance-scoped Conditional Access MFA using a dynamic security group.
- Singapore ExpressRoute private connectivity with BGP route exchange.
- London-to-Azure encrypted site-to-site VPN.
- Virtual machine migration with Azure Migrate.
- VM3 outbound TCP/8080 connectivity to Singapore application servers.
- Azure App Service for App1 and App2, with WebApp1 autoscale (up to five).
- Public DNS and custom hostname `app2.xFusionCorp.com` for WebApp2.
- Azure Monitor email alert for VM4 control-plane write operations.
- Reader-derived custom Azure RBAC role `Role1`.
- Cost-conscious infrastructure planning.

## Project documents

| File | Contents |
| --- | --- |
| [Case-study analysis](docs/01-case-study-analysis.md) | Requirements, source facts and gaps |
| [Architecture design](docs/02-architecture-design.md) | Proposed topology, assumptions and decisions |
| [Identity and governance](docs/03-identity-and-governance.md) | AD sync, Finance MFA and custom Role1 |
| [Hybrid networking](docs/04-hybrid-networking.md) | ExpressRoute, BGP, VPN and TCP 8080 |
| [VM migration](docs/05-vm-migration.md) | Azure Migrate discovery through cutover |
| [App Service](docs/06-app-service.md) | WebApp1 autoscale, WebApp2 hostname, IaC |
| [Monitoring and alerts](docs/07-monitoring-and-alerts.md) | VM4 Activity Log email alerts |
| [Final review / backlog](docs/08-lessons-learned.md) | Requirement audit, missing work, testing plan |
| [Architecture diagram](diagrams/hybrid-architecture.md) | Conceptual Mermaid topology |

## Automation folders

- [Bicep](infrastructure/bicep/) — illustrative App Service and Azure Monitor templates.
- [Bash](infrastructure/scripts/) — Azure CLI inventory, DNS verification and Reader-derived role definition generator.

**Use environment-specific parameters and verify charges/permissions before deploying.** The scripts and templates have not been end-to-end tested. Some resources require tenant access, proprietary connectivity or expensive gateway services.

## Verification statuses

- **Designed:** solution documented; no deployment implied.
- **Simulated:** representative controlled lab use, with explicit assumptions.
- **Deployed and verified:** actual resource configuration, test results and redacted evidence recorded.

## Security

Never commit `.env` secrets, credentials, access tokens, certificate private keys, VPN preshared secrets or unredacted real-user information.

## Reference

Charles Pluta, *Exam Ref AZ-104 Microsoft Azure Administrator*, 2nd ed., Microsoft Press. This project references the study text but does not redistribute the book.

## Next steps

See the [audit and engineering backlog](docs/08-lessons-learned.md), beginning with Bicep networking automation and VM3's TCP/8080 rule.
