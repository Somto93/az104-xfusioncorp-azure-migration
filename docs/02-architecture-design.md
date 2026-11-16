# 02 — Architecture Design

**Status:** Designed — not deployed or validated against a real xFusionCorp environment.

## Scope and evidence boundary

This document translates the supplied AZ-104 case study into a **proposed hybrid Azure architecture**. The source case describes Singapore, Doha and London; an on-premises AD forest (`xFusionCorp.com`); Entra ID P1; planned ExpressRoute, VM and web app migration; and nine technical requirements. The referenced server and Azure resource inventory tables were **not provided**. Names, subnet sizes, IP addresses, VM specifications and target region below are **explicit lab assumptions**, not known facts.

## Architecture decisions

| Workstream | Proposed production solution | Reason and key dependency |
| --- | --- | --- |
| Hybrid identity | Microsoft Entra Connect Sync from existing AD to Entra ID; test identity matching and OU/attribute filtering | Synchronises identities without recreating users; requires on-premises access and correct permissions |
| Finance MFA | Dynamic Entra security group using `user.department -eq "Finance"`; Conditional Access policy scoped to that group | P1 supports dynamic groups and Conditional Access; pilot first; protect emergency-access accounts |
| Singapore hybrid network | ExpressRoute circuit + private peering + ExpressRoute gateway; BGP between provider/on-premises routers and Microsoft edge | Private Azure connectivity with automatic route advertisement; circuit and provider must be provisioned |
| London connectivity | Route-based Azure VPN Gateway with IPsec/IKE site-to-site tunnel to London VPN device | Encrypted traffic across public internet; peer public IP and shared secret required |
| Gateway coexistence | One hub VNet with appropriately sized `GatewaySubnet`, separate ExpressRoute and VPN gateways | Coexistence is possible with compatible SKUs; detailed constraints must be verified before deployment |
| VM migration | Azure Migrate assessment and migration process for VMs on Server1 and Server2 | Depends on unknown host platforms, guest OS, dependencies and disk characteristics |
| VM3 TCP/8080 | Target-specific NSG outbound allow rule **and** verified routes, on-premises firewall/return path | An NSG rule alone does not establish end-to-end connectivity |
| Web app migration | Two Windows or Linux App Services depending on actual app runtime; WebApp1 autoscale 1–5 instances on compatible plan | Memory demands, runtime and plan price need assessment; autoscale rules must specify metrics |
| App2 DNS | Verify ownership and map `app2.xFusionCorp.com` to WebApp2 using appropriate CNAME/TXT records | Requires real domain control; DNS entry alone does not complete App Service binding |
| VM4 changes | Activity Log alert for scoped VM write operations + email action group | Sends notifications for control-plane changes; does not detect all guest OS settings |
| Custom Role1 | Copy Reader role's actions into a versioned custom role definition; specify changes after clarification | Case does not say what privileges Role1 should add/remove |

## Diagram

See [Proposed architecture](../diagrams/hybrid-architecture.md).

## Simulated IP plan (illustrative only)

| Network | Address space | Notes |
| --- | --- | --- |
| Azure hub VNet (`vnet-xfusion-hub`) | `10.10.0.0/16` | Proposed Azure VNet1 simulation |
| Azure workloads subnet | `10.10.1.0/24` | Example placement for VM3 and VM4 |
| Azure management subnet | `10.10.2.0/24` | Example management workloads |
| Azure `GatewaySubnet` | `10.10.255.0/27` | Reserve for connectivity gateways; confirm sizing for coexistence |
| Singapore on-premises | `192.168.10.0/24` | Sample only; replace using actual routing inventory |
| Doha on-premises | `192.168.30.0/24` | Sample only; no new Doha-Azure link mandated |
| London on-premises | `192.168.20.0/24` | Sample only; S2S peer LAN |

**Do not deploy these addresses without verifying there are no overlaps** with existing subnets or connected networks. This is a topology sketch, not a capacity design for 3,200 staff.

## Region and DNS decisions

- **Proposed region:** `southeastasia` (Singapore) to start requirements discussion. The case does **not** specify the Azure region, so this is a design choice, not a given.
- The existing internal AD DNS zone is `xFusionCorp.com`. The case requires the public hostname `app2.xFusionCorp.com`. Public DNS changes require ownership of the external zone; do not assume the internal AD-integrated zone is publicly authoritative.
- Preserve domain controllers and DNS until identity, application and network dependencies have been discovered and tested.

## Implementation order

1. Confirm inventory, subscriptions, quotas, cost permissions, address overlap, public DNS control, routing and application runtimes.
2. Establish foundational naming, resource groups, VNet/subnets, NSGs and tagging.
3. Establish Singapore ExpressRoute private peering with BGP and London VPN connectivity; test routes and firewall controls.
4. Design and test Entra Connect Sync, dynamic Finance group and Conditional Access scope.
5. Assess and migrate Server1/Server2 hosted VMs with Azure Migrate.
6. Deploy App Services, configure WebApp1 autoscaling, deploy applications, and configure WebApp2 custom hostname.
7. Define Role1 (after desired custom privileges are provided), alert on VM4 writes and run acceptance tests.

## Acceptance criteria (to record when implemented)

- Singapore-Azure routes learnt through BGP; return routes present; approved private connectivity tested.
- London-Azure IPsec tunnel established and traffic reaches approved Azure workloads.
- VM3 can initiate TCP/8080 to specified Singapore application hosts; unnecessary destinations remain denied.
- Finance pilot users are challenged for MFA by Conditional Access; non-finance users are not targeted by **this policy** (other tenant policies may still apply).
- WebApp1 configured with a metric-based rule and 1–5 instances; scaling tested with a controlled load.
- WebApp2 hostname ownership verified, binding present and HTTPS behavior validated.
- Email notification received for a designated VM4 control-plane write operation.
- Role1 custom definition created with explicitly documented actions and assignable scopes.

## Constraints and cost controls

- **No Azure resources have been deployed as part of this design phase.**
- ExpressRoute, VPN Gateway and multi-instance App Service plans can incur substantial ongoing costs. Document their configuration and validate templates before launching billable resources.
- KodeKloud lab permissions and automated cleanup may prevent reliable deployment; this is a **design + simulation** portfolio until supported by actual run evidence.
- Never commit passwords, service principal credentials, shared keys or tokens.

## References

- [Microsoft: Plan hybrid connectivity](https://learn.microsoft.com/en-us/azure/networking/design-guide/hybrid-connectivity)
- [Microsoft: ExpressRoute and site-to-site VPN coexistence](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager)
- [Microsoft: Azure VPN Gateway overview](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
