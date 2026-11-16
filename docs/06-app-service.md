# 06 — Azure App Service Migration, Autoscale and DNS

**Status: Design + example IaC only. No Azure deployment, live app migration, DNS change, or autoscale test has been performed.**

## Source facts and missing data

- xFusionCorp runs two on-premises web applications: `App1`, `App2`.
- Each application **instance** requires **1 GB of memory**.
- Migrate to Azure web apps `WebApp1`, `WebApp2`.
- WebApp1 must **automatically** vary its instance count with load, up to five instances.
- `webapp2.azurewebsites.net` must also be reachable as `app2.xFusionCorp.com`.
- Minimise costs.

The missing original Azure resource inventory means that existing plans, runtime/OS, worker instance count and migration compatibility are unknown. **1 GB per app instance is not the same as 1 GB for both apps combined.**

## Architecture decision

**For the example lab:** use **two App Service Plans**.

| Plan | App | Proposed tier | Scaling |
| --- | --- | --- | --- |
| `asp-xfusion-webapp1` | WebApp1 | **Standard S1**, Windows | Azure Monitor autoscale, 1–5 plan instances |
| `asp-xfusion-webapp2` | WebApp2 | **Basic B1**, Windows | Manual, 1 plan instance |

Why two plans? Azure Monitor autoscale applies to **the whole App Service Plan**, not a single app. A dedicated plan for WebApp1 prevents WebApp2 being replicated and billed for up to five workers unnecessarily. Standard S1 supports rule-based autoscale; B1 does not. These are candidate tiers, **not a final memory-capacity assessment**. Actual application memory/CPU profiles, runtimes and cost estimates must be validated. <https://learn.microsoft.com/en-us/azure/app-service/manage-automatic-scaling>

**Alternatives:** One shared Standard plan could reduce idle cost, but every app shares compute and scaling. A Premium plan may offer better capacity for memory-heavy apps; App Service *automatic scaling* (traffic-based, different from Azure Monitor autoscale) is also an option on supported Premium v2–v4 tiers. We selected familiar metric-based autoscale for the AZ-104 exercise.

**Operating system / runtime:** Windows and `.NET 10` are **simulation assumptions** used to illustrate declarative provisioning; they are not stated by the case study. Before actual migration, inventory both source applications and use a supported runtime/OS.

## Template and operational scripts

- [`infrastructure/bicep/app-service/main.bicep`](../infrastructure/bicep/app-service/main.bicep) — two App Service plans, two web apps and metric autoscale for WebApp1.
- [`infrastructure/scripts/check-app-service.sh`](../infrastructure/scripts/check-app-service.sh) — **read-only** Azure CLI verification of plans, web apps and autoscale settings.
- [`infrastructure/scripts/check-app2-dns.sh`](../infrastructure/scripts/check-app2-dns.sh) — **read-only** DNS checks for CNAME/TXT records.

## Sample sizing and scaling policy

- WebApp1 plan: S1, `min=1`, `default=1`, `max=5`.
- Scale out **+1** when average App Service Plan `CpuPercentage > 70` for 10 minutes; 5-minute cool-down.
- Scale in **-1** when average `CpuPercentage < 30` for 10 minutes; 10-minute cool-down.
- Thresholds are **illustrative initial settings**, not benchmarked production values.
- Plan CPU, queue and latency must be observed under load before thresholds or worker sizing can be considered final.
- Five Standard S1 workers may cost substantially more than a single plan worker. Autoscale does **not** guarantee response-time objectives or memory headroom.

## WebApp2 custom domain

The case requires `app2.xFusionCorp.com` to resolve to WebApp2, whose stated default hostname is `webapp2.azurewebsites.net`. The example Bicep template uses a globally unique WebApp2 placeholder parameter; its actual hostname may differ from the case's named host. Mapping the **exact case hostname** requires the corresponding WebApp2 to exist and be controlled.

1. Verify public DNS control of `xFusionCorp.com` and administrative access to WebApp2.
2. For a **subdomain**, add a **CNAME** record:
   - Host/label: `app2`
   - Target: WebApp2's **actual** `<appname>.azurewebsites.net` hostname.
3. Add the recommended **TXT** record for domain ownership:
   - Host/label: `asuid.app2`
   - Value: the WebApp2 **custom domain verification ID** shown by Azure (retrieve; **never invent**).
4. Confirm public DNS propagation using `dig`, validate ownership and add hostname binding in App Service.
5. Set up and bind a valid TLS certificate for HTTPS, then test `https://app2.xFusionCorp.com`. Merely adding the CNAME does not configure App Service to accept the custom Host header or secure HTTPS.

**Important:** The on-premises AD-integrated DNS zone `xFusionCorp.com` is not proof that the organisation controls public authoritative DNS for the same domain. DNS steps must be performed where public `xFusionCorp.com` is hosted.

## Suggested deploy (DO NOT RUN without confirming budget and permissions)

The example defaults to East US and uses **example names** that could be globally unavailable.

```bash
az bicep build --file infrastructure/bicep/app-service/main.bicep
az deployment group what-if \
  --resource-group rg-xfusioncorp-az104 \
  --template-file infrastructure/bicep/app-service/main.bicep
# Deploy ONLY after reviewing plan charges, domain uniqueness and policy restrictions:
# az deployment group create --resource-group rg-xfusioncorp-az104 \
#   --template-file infrastructure/bicep/app-service/main.bicep
```

The Bicep example is committed as **unverified source**; the commands above have **not** been run against Azure.

## Validation (after a successful deployment)

```bash
bash infrastructure/scripts/check-app-service.sh rg-xfusioncorp-az104
bash infrastructure/scripts/check-app2-dns.sh app2.xFusionCorp.com
```

Collect plan tier, workers count, autoscale configuration and history, HTTP success, CPU and memory during representative load, real CNAME/TXT response, custom domain bindings, certificate state, final cost estimate and screenshots without secrets.

## Migration runbook

1. Inventory App1/App2 framework, version, dependencies, authentication, database drivers, config, file state and platform support.
2. Evaluate App Service compatibility and available migration tools. Do not assume Windows or .NET from the scenario.
3. Establish application deployment pipeline and secure settings/managed identities.
4. Deploy candidate plans/web apps to test subscription, prepare networking and backend access.
5. Test app behaviour, data migration, health checks, observability and rollback.
6. Set autoscale in **test** conditions, validate at 1 to 5 instances and verify billing assumptions.
7. Configure DNS and HTTPS for WebApp2; execute controlled cutover and monitor.

## Microsoft references

- [How automatic scaling differs from autoscale](https://learn.microsoft.com/en-us/azure/app-service/manage-automatic-scaling)
- [Azure Monitor autoscale](https://learn.microsoft.com/en-us/azure/azure-monitor/autoscale/autoscale-get-started)
- [Custom domain setup and DNS validation](https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain)
- [Troubleshoot App Service custom domains](https://learn.microsoft.com/en-us/troubleshoot/azure/app-service/connection-issues-with-ssl-or-tls/troubleshoot-custom-domain-issues-azure-app-service)
