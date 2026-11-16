# 04 — Hybrid Networking

**Status:** Design only; no real ExpressRoute circuit, site-to-site VPN or VM deployed.

## Requirement A: Singapore office to Azure

**Requirement:** Deploy ExpressRoute to Singapore; automatically exchange routing information with Azure.

**Design:** Establish ExpressRoute private peering with a connectivity provider, configure the ExpressRoute gateway in the Azure hub, use BGP for exchanging route prefixes, and validate effective routes and return paths.

**Dependencies:** Provider/circuit, peering VLAN and ASN/BGP parameters, circuit authorisation, gateway SKU, non-overlapping prefixes and subscription permissions.

**Test evidence to collect:** BGP peer state, learned/advertised routes, effective routes on VM NICs and successful private application connectivity.

## Requirement B: London office to VNet1

**Requirement:** Encrypted connection across the internet.

**Design:** Site-to-site IPsec/IKE tunnel using route-based Azure VPN Gateway and London VPN-capable device. Configure Local Network Gateway for London's public IP and LAN prefixes; securely provision preshared key or approved authentication.

**Dependencies:** London internet-facing public IP, supported VPN device, local LAN prefix, GatewaySubnet, compatible gateway SKU, firewall rules and secret-handling policy.

**Test evidence to collect:** Tunnel connection status, IKE/IPsec negotiation logs, effective routes, private endpoint reachability and access restriction checks.

## Requirement C: VM3 outbound TCP/8080

**Requirement:** VM3 can connect to Singapore application servers on TCP/8080.

**Design:** An NSG outbound allow rule scoped from VM3 subnet/NIC to known Singapore app-server IP prefixes on TCP/8080. Ensure ExpressRoute routing is effective and firewalls in Azure/on-prem permit forward and return traffic. Prefer least-privilege destinations.

**Tests:** `nc -vz <singapore-app-ip> 8080` on Linux VM3, or `Test-NetConnection <singapore-app-ip> -Port 8080` on Windows VM3, after deployment. Record the actual source/destination, result and firewall logs. Tests are **not executed yet**.

## Coexistence caveat

ExpressRoute and VPN gateways can coexist subject to SKU and routing constraints. Avoid assuming London can automatically transit through Azure to Singapore. If cross-site transit is requested, it needs separate validated design.

## Cost caveat

Do not deploy gateways/circuits simply to demonstrate the diagram; they can be expensive and require provider configuration. Capture validated Bicep or Azure CLI infrastructure plans as later milestones.
