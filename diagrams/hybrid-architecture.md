# xFusionCorp Proposed Hybrid Architecture

**Conceptual diagram — simulated names and IP ranges, not deployed resources.**

```mermaid
flowchart LR
  subgraph OnPrem["On-premises offices"]
    SG["Singapore HQ · 2,000 staff\nAD DS / DNS / apps\n192.168.10.0/24 (assumed)"]
    DO["Doha · 1,000 staff\n192.168.30.0/24 (assumed)"]
    LO["London · 200 staff\nVPN-capable edge device\n192.168.20.0/24 (assumed)"]
  end
  SG ---|"Existing private office WAN"| DO
  SG ---|"Existing private office WAN"| LO

  subgraph Azure["Azure subscription · proposed Southeast Asia region"]
    ER["ExpressRoute gateway"]
    VPN["VPN Gateway"]
    HUB["Hub VNet / VNet1\n10.10.0.0/16 (assumed)"]
    VM["Workloads: VM3 / VM4"]
    APPS["WebApp1 + WebApp2\nAzure App Service"]
    MON["Azure Monitor / Activity Logs\nEmail action group"]
    ENTRA["Microsoft Entra ID\nFinance MFA Conditional Access"]
  end

  SG ---|"ExpressRoute private peering + BGP\nprovider circuit required"| ER
  LO ---|"IPsec/IKE Site-to-Site over Internet"| VPN
  ER --- HUB
  VPN --- HUB
  HUB --- VM
  HUB -.->|"Connectivity depends on App Service integration design"| APPS
  VM -.-> MON
  SG -.->|"Entra Connect Sync\nfrom AD DS"| ENTRA
  APPS -.->|"Custom DNS hostname mapping\nrequires public zone control"| DNS["app2.xFusionCorp.com"]
```

## Notes

- Office headcounts and existing private inter-office links come from the case study.
- The diagram is **logical**, not a promise of network transit between ExpressRoute and VPN sites. If route transit between connected offices is required, evaluate supported hub routing, Azure Route Server, gateway coexistence settings and on-premises routing.
- Entra Connect Sync is shown logically; it requires an appropriately managed environment and connectivity.
- App Service is a managed platform, not a VM in the workload subnet. VNet Integration and private endpoint requirements depend on application access needs.
- VM3 connectivity over TCP 8080 requires routes and permission at both ends.
