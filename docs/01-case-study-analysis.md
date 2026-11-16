# 01 — Case Study Analysis

**Status:** Designed (initial analysis only)

## Known facts

- Offices: Singapore (2,000 employees), Doha (1,000), London (200).
- On-premises Active Directory forest: `xFusionCorp.com`; domain controllers also host its DNS zone.
- Microsoft Entra tenant: `xFusionCorp.onmicrosoft.com`, P1 tier.
- Departments: Finance, Human Resources, Sales, Research, Information Technology. Each has an OU; user `department` attributes are populated.
- Existing offices are connected by private links; Singapore and Doha have data centres and VPN-capable firewalls.
- All infrastructure servers are virtualised; App1 and App2 each require 1 GB memory per instance.

## Missing case-study information

The supplied text refers to two inventory tables (virtualisation servers and Azure resources), but the tables were not provided. We must not present any assumed VM sizes, operating systems, existing plans, address ranges, or routing details as confirmed facts.

## Requirement-to-solution map

| Requirement | Proposed approach | Constraints / validation |
| --- | --- | --- |
| Singapore private connectivity and automatic route exchange | ExpressRoute private peering with BGP | Requires circuit/provider and verified routing configuration |
| London encrypted internet connectivity to VNet1 | Site-to-site IPsec VPN Gateway | Needs public VPN peer and non-overlapping IP ranges |
| Synchronise on-premises AD | Microsoft Entra Connect Sync | Requires suitable on-premises AD and supported host |
| Finance-only MFA | Finance-scoped Conditional Access policy | Entra ID P1; test with pilot accounts and emergency-access exclusions |
| Migrate VMs from Server1/Server2 | Azure Migrate assessment and migration | Actual hypervisor/VM inventory unknown |
| VM3 outbound TCP 8080 to Singapore | NSG egress, routing, firewall rules | Test path end to end; destination IPs unknown |
| WebApp1 autoscale to five | Compatible App Service Plan and Azure Monitor autoscale | Plan sizing and instance cost must be checked |
| WebApp2 custom domain | DNS verification and App Service hostname binding | Requires control of `xFusionCorp.com` DNS |
| VM4 modification email | Activity Log alert plus action group | Define which write operations count as modification |
| Reader-derived Role1 | Custom RBAC role definition | Exact deviations from Reader unspecified |

## Simulation policy

Use documented lab-only values where details are missing, and clearly label them as assumptions. Do not claim that designs or templates were deployed without real validation evidence.
