// AZ-104 xFusionCorp - EXAMPLE ONLY; not deployed.
// Runtime/OS and region are LAB ASSUMPTIONS, not supplied facts.
// Azure Monitor autoscale targets the WebApp1 App Service PLAN.

targetScope = 'resourceGroup'

@description('Example Azure region, not specified by source case')
param location string = 'eastus'

@description('WebApp1 global name - must be unique in Azure App Service')
param webApp1Name string = 'xfusion-webapp1-demo'

@description('WebApp2 global name - replace with the real app name')
param webApp2Name string = 'xfusion-webapp2-demo'

@description('Illustrative Windows .NET runtime; verify support and source compatibility')
param dotnetVersion string = 'v10.0'

var tags = {
  Project: 'AZ104-xFusionCorp'
  Environment: 'Simulation'
}

resource plan1 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'asp-xfusion-webapp1'
  location: location
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

resource plan2 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'asp-xfusion-webapp2'
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

resource webApp1 'Microsoft.Web/sites@2024-04-01' = {
  name: webApp1Name
  location: location
  kind: 'app'
  tags: tags
  properties: {
    serverFarmId: plan1.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: dotnetVersion
      minTlsVersion: '1.2'
      alwaysOn: true
    }
  }
}

resource webApp2 'Microsoft.Web/sites@2024-04-01' = {
  name: webApp2Name
  location: location
  kind: 'app'
  tags: tags
  properties: {
    serverFarmId: plan2.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: dotnetVersion
      minTlsVersion: '1.2'
      alwaysOn: true
    }
  }
}

// Azure Monitor autoscale: WebApp1's dedicated Standard S1 plan.
// Tuning numbers below are placeholders, not measured application thresholds.
resource webApp1Autoscale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: 'autoscale-xfusion-webapp1'
  location: location
  tags: tags
  properties: {
    enabled: true
    targetResourceUri: plan1.id
    profiles: [
      {
        name: 'cpu-based'
        capacity: {
          minimum: '1'
          maximum: '5'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: plan1.id
              metricNamespace: 'Microsoft.Web/serverfarms'
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
              dividePerInstance: false
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: plan1.id
              metricNamespace: 'Microsoft.Web/serverfarms'
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
              dividePerInstance: false
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
        ]
      }
    ]
  }
}

output webApp1DefaultHost string = webApp1.properties.defaultHostName
output webApp2DefaultHost string = webApp2.properties.defaultHostName
output webApp1PlanResourceId string = plan1.id
output webApp2PlanResourceId string = plan2.id
