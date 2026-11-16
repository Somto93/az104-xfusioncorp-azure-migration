# 03 — Hybrid Identity and Governance

**Status: Designed and scripted only. Not deployed to xFusionCorp or tested in a tenant.**

## Given case-study facts

- Forest: `xFusionCorp.com` (on-premises Active Directory Domain Services).
- Microsoft Entra tenant: `xFusionCorp.onmicrosoft.com`, P1 tier.
- Finance, Human Resources, Sales, Research and Information Technology each have an OU containing department user accounts.
- The `department` attribute is set for all users, and new accounts are added frequently.
- An account named `User1` exists in on-premises AD.
- Requirements: synchronize on-premises AD to Entra ID, enable MFA for Finance users **only**, and create a custom Azure role `Role1` based on Reader.

The missing inventory tables prevent confirmation of existing sync server configuration, identity matching rules and current Azure RBAC assignments.

## Part A — Synchronize on-premises AD to Entra ID

**Recommendation:** Plan Microsoft Entra Connect Sync on a supported, appropriately secured Windows Server with network access to domain controllers and the Entra tenant.

1. Review prerequisites, supported OS, TLS, outbound endpoints and administrative permissions. Verify on-premises DNS health, UPN suffixes and duplicate users before installing.
2. Determine the sign-in approach (e.g., Password Hash Synchronization) according to organisational requirements; don't assume pass-through authentication or federation is required.
3. Review domain and OU scoping. Because the case says users are added frequently to established departmental OUs, OU inclusion plus automatic sync of new objects is suitable *provided these OUs contain the identities that should sync*. Avoid accidentally excluding infrastructure objects or service accounts.
4. Check whether `xFusionCorp.com` is verified as a routable custom domain in Entra. The tenant's `onmicrosoft.com` name alone does not establish verification of `xFusionCorp.com`. Plan UPN handling accordingly.
5. Install/configure Entra Connect Sync with a staging/pilot approach, verify matching and exports before enabling broad sync.
6. Verify sample users including `User1`, their synchronized `department` attribute and group membership. Validate that a newly created Finance user syncs into the correct dynamic group after directory synchronization and group evaluation.

**Safety:** Changing OU filtering later can take existing cloud objects out of scope and cause deletions. Back up configuration, stage changes, review pending exports and avoid irreversible changes to real identities.

**Current product check:** Microsoft documentation announces a mandatory upgrade to Entra Connect Sync v2.6.84.0 or later and application-based authentication by April 7, 2027; verify the official prerequisites at deployment time.

## Part B — Enable MFA for Finance users only

**Recommended design:** Use Microsoft Entra ID P1 dynamic security group membership based on the `department` attribute. Apply a Conditional Access policy scoped to that group, requiring MFA for the intended cloud apps. Avoid relying exclusively on OUs, because Conditional Access targets Entra users/groups, not AD OUs directly.

### Dynamic group

- Suggested display name: `SG-Finance-MFA`
- Group type: Security; membership: Dynamic User
- Membership rule:

```text
(user.department -eq "Finance")
```

**Steps:** In Microsoft Entra admin center, create the dynamic group. Confirm synchronized Finance users join and non-Finance users do not. Membership updates are asynchronous.

### Conditional Access policy

- Name: `CA-Finance-Require-MFA`
- Users: **include** `SG-Finance-MFA`; **exclude** emergency-access accounts (break glass).
- Target resources: all cloud apps if the intended requirement means Finance MFA across their cloud applications; narrow this if the organisation specifies individual apps.
- Grant: Require multifactor authentication (or an appropriate authentication strength chosen by security policy).
- Enable: start in **Report-only**; review sign-in logs and policy impact before switching to **On**.
- **Do not** create an unintended policy targeting all employees.

**Precise interpretation:** This makes *this policy* apply only to Finance. It does not guarantee that non-Finance users will never be prompted for MFA by other tenant security defaults, Conditional Access policies, per-user settings or application requirements. Audit existing settings before asserting exclusive enforcement.

### Validation matrix (not yet executed)

| User | Department | Dynamic group expected | This CA policy expected |
| --- | --- | --- | --- |
| Finance pilot | Finance | In | MFA required |
| New Finance hire | Finance | In after sync/group processing | MFA required |
| HR pilot | Human Resources | Out | Not in scope |
| Sales pilot | Sales | Out | Not in scope |
| Emergency account | Admin | Excluded | Excluded |

Capture real sign-in logs and What If results in a properly authorised tenant; redact names and identifiers before publishing.

## Part C — Role1: custom Azure role based on Reader

Azure RBAC custom roles are Azure Resource Manager **control-plane roles**. They do not replace Microsoft Entra directory roles. The case says Role1 is *based on Reader*, but specifies no extra permissions. Therefore, the least-assumption interpretation is a Reader-equivalent custom role called `Role1` at the desired subscription scope, with no added privileges.

- File: [`infrastructure/scripts/generate-role1.sh`](../infrastructure/scripts/generate-role1.sh)
- Script downloads the current built-in Reader role definition using Azure CLI, copies its permission arrays, and generates `role1.generated.json` under the current directory.
- The script **does not create or assign** Role1 by default. Explicit deployment is a separate reviewed step.
- Before use: set the correct Azure subscription and ensure the operator has `Microsoft.Authorization/roleDefinitions/write` on its assignable scope.
- Custom roles can be created with `az role definition create --role-definition role1.generated.json`; assigning the role to principals is a separate step, not required here.

### Preview (read-only against Azure, local generated file)

```bash
az account show --query '{subscription:id,tenant:tenantId}' -o table
bash infrastructure/scripts/generate-role1.sh
cat role1.generated.json
```

### Only when authorised and ready to create Role1

```bash
az role definition create --role-definition role1.generated.json
az role definition list --name Role1 --query '[].{Role:roleName,Scopes:assignableScopes}' -o json
```

**Not executed:** These are proposed commands, not proof of successful creation. Avoid publishing generated outputs with tenant or subscription identifiers if the project is meant to stay generic.

## Lab boundaries

- A restricted KodeKloud subscription might not grant Entra administrator rights or permissions to create role definitions.
- Entra Connect Sync requires an actual compatible on-premises AD environment and supported server; Bicep alone does not configure AD synchronization.
- A group membership rule and Conditional Access policy require tenant permissions; merely provisioning a resource group does not grant them.
- Before any live MFA rollout, validate report-only results and keep emergency access working.

## References

- [Microsoft: Entra Connect prerequisites](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-prerequisites)
- [Microsoft: Entra Connect scoping and OU filtering](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-configure-filtering)
- [Microsoft: Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)
- [Microsoft: Custom Azure roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Microsoft: Create a custom Azure role with Azure CLI](https://learn.microsoft.com/en-us/azure/role-based-access-control/tutorial-custom-role-cli)
