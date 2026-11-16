# 08 — Final Review, Gaps, and Lessons Learned

**Review date: 2026-11-16**  
**Project status: DESIGN IN PROGRESS — not deployed / not accepted**

## Summary

We created a GitHub portfolio documenting a proposed hybrid Azure migration for xFusionCorp, with Linux-first Azure CLI/Bash scripts and initial Bicep examples. The case-study text refers to **two missing inventory tables**; no real xFusionCorp tenant or on-premises environment was accessed.

This review is a **source and completeness review**, not a runtime validation. A successful GitHub commit does not prove that Bicep compiles or that Azure resources work.

## Original case-study requirement coverage

| # | Requirement | Documented approach | Artifact coverage | Current validation |
| --- | --- | --- | --- | --- |
| 1 | Singapore ExpressRoute | ExpressRoute private peering + BGP | Network design only | Not configured |
| 2 | Migrate VMs from Server1/Server2 | Azure Migrate discovery, assessment, replication, test cutover | Migration runbook + read-only Bash inventory | No source inventory; not migrated |
| 3 | Sync on-prem AD to Entra ID | Entra Connect Sync; OU/UPN/attribute scoping | Identity runbook | Not synced |
| 4 | Migrate App1/App2 | App Service on compatible plans | Example Bicep + verification Bash | No apps deployed or migrated |
| 5 | WebApp1 automatic scale (max 5) | Azure Monitor autoscale on dedicated Standard S1 plan | Initial Bicep rules for CPU and 1–5 capacity | Bicep and live autoscale unverified |
| 6 | VM3 egress TCP 8080 to Singapore app servers | NSG outbound allow + effective routes and firewalls | Network design; **NSG template still needed** | Not tested |
| 7 | Finance-only MFA | Department-based dynamic group + Finance-scoped Conditional Access | Identity runbook | Not configured |
| 8 | WebApp2 custom hostname | Public DNS CNAME/TXT, App Service binding and TLS | DNS runbook + Bash lookup checks | DNS ownership unverified |
| 9 | London encrypted connection | Site-to-site IPsec/IKE VPN Gateway | Network design only | Not connected |
| 10 | Email on VM4 settings modification | Activity Log alert + email action group | Example Bicep + read-only Bash check | No alert or email verified |
| 11 | Role1 based on Reader | Copy built-in Reader permission set to custom role | Local role-definition generator Bash | Not created or assigned |
| 12 | Minimise cost | Separate plans for isolated scaling; avoid unnecessary lab gateways | Cost tradeoffs documented | No subscription-specific quote |

The case has **nine explicit technical requirements**, plus broader planned changes and a cost objective. The rows above break combined objectives into distinct implementation deliverables.

## Important design caveats / audit findings

1. **Missing source tables:** Server host types, existing resource inventory, IP addresses, app runtimes, existing App Service plans and VM sizes are unknown. The repository must not imply these details were given.
2. **Entra Connect:** A Bash script alone cannot emulate hybrid AD synchronization. Windows-based connectors/appliances and rights to a real tenant are required.
3. **Finance MFA:** Finance membership derives from synchronized `department` values; a Conditional Access policy scoped to Finance only does not disable other policies for other employees.
4. **Role1:** The case only says “based on Reader”; there is no specification for additional permissions, so a Reader-equivalent custom role is the least-assumption example.
5. **Network connectivity:** NSG allow rules alone cannot route traffic; ExpressRoute BGP, destination security and return-path routing must be verified. VPN and ExpressRoute coexistence has constraints.
6. **Autoscale:** Azure Monitor autoscale applies to an **App Service Plan**, not just a web app. 1 GB per application instance does not establish worker sizing. S1 and B1 are candidate tiers, not verified lowest-cost production choices.
7. **App names/domain:** App Service app names must be globally unique; the placeholder names in Bicep are not guaranteed available. Public DNS control and App Service hostname binding are separate steps.
8. **Alert meaning:** `Microsoft.Compute/virtualMachines/write` may capture writes that are not actual setting changes and does not cover all guest OS or linked-resource edits. Verify triggering operations with activity logs.
9. **Testing gap:** Bicep templates and Bash scripts have been committed, but Bicep compilation, `what-if`, deployment, tests, alerts and emails have **not** been verified.
10. **Security:** Avoid committed credentials, preshared VPN keys, connection strings and unredacted sign-in information. Do not expose a real tenant in public screenshots without permission.

## Remaining engineering backlog (recommended order)

- [ ] **Network IaC:** Add VNet, subnets, NSGs, a targeted VM3 outbound TCP/8080 rule, and a safe local validation workflow.
- [ ] **Hybrid connectivity templates:** Document/parameterise ExpressRoute gateway, circuit references, BGP peering and VPN resources. Keep expensive deployment disabled by default.
- [ ] **Identity deployment checklist:** Add dynamic group and Conditional Access setup procedures with pilot/report-only safeguards. Avoid committing environment-specific secrets.
- [ ] **Compute migration:** Capture sample Azure Migrate assessments once a suitable lab can be provided.
- [ ] **App Service:** Compile/validate Bicep, test live autoscale with controlled load and confirm cost at one and five workers.
- [ ] **Custom hostname:** Verify public DNS ownership, bind hostname and test HTTPS (only with authorised domain access).
- [ ] **VM4 alert:** Validate Bicep, provision into authorised lab, trigger a controlled write and confirm email delivery.
- [ ] **Role1:** Review generated definition in correct subscription, create it if allowed, check actions and scope, and test principle of least privilege.
- [ ] **Evidence:** Add redacted command output, deployment operations, architecture screenshots and measured cost, marked with date and environment.

## Linux-first toolchain

- Bash, Azure CLI, `az bicep build`, `az deployment group what-if`, `jq`, `dig`, `nc`, `git`.
- Microsoft Entra Connect Sync and some Azure Migrate appliance operations may still require Windows-hosted components.

## Lessons learned

- Treat **design**, **simulation**, **deployment**, and **validation** as separate milestones.
- Missing architecture inputs should appear as explicit assumptions instead of invented facts.
- Lab policy restrictions and provider cleanup can cause infrastructure failures independent of IaC correctness.
- Security, network routing and application compatibility need end-to-end evidence, not merely a green deployment result.
- Link every requirement to a documented solution, an artifact and a validation test.

## Next phase

The highest-value next commit is **networking IaC and a VM3 port 8080 security-rule template**, followed by an offline Bicep compilation check where the tooling is available.
