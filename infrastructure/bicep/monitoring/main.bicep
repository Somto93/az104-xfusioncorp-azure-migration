// xFusionCorp Phase 5: Azure VM4 Activity Log alert + email action group
// Prepared design ONLY. VM4 must already exist; deployment has not been verified.
targetScope = 'resourceGroup'

@description('Existing virtual machine resource name (case study: VM4)')
param vm4Name string = 'vm4'

@description('Authorised email address for VM4 modification notifications')
param notificationEmail string

@description('Location for the Activity Log alert processing rule')
@allowed([
  'global'
  'westeurope'
  'northeurope'
])
param alertLocation string = 'global'

resource vm4 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vm4Name
}

resource emailActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-xfusion-vm4-email'
  location: 'global'
  properties: {
    groupShortName: 'VM4Alerts'
    enabled: true
    emailReceivers: [
      {
        name: 'VM4Admin'
        emailAddress: notificationEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource vm4WriteAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'alert-xfusion-vm4-write'
  location: alertLocation
  properties: {
    description: 'Notify when an Azure Resource Manager write operation is recorded on VM4.'
    enabled: true
    scopes: [
      vm4.id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          field: 'operationName'
          equals: 'Microsoft.Compute/virtualMachines/write'
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: emailActionGroup.id
          webhookProperties: {}
        }
      ]
    }
  }
}

output alertRuleName string = vm4WriteAlert.name
output actionGroupName string = emailActionGroup.name
output watchedVmResourceId string = vm4.id
