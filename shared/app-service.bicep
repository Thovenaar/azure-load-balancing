param webAppName string
param appServicePlanRg string
param appServicePlanName string
param linuxFxVersion string
param useManagedIdentity bool = true
param location string = resourceGroup().location
param appSettings array = []
param virtualNetworkSubnetId string = ''

@description('true if Always On is enabled; otherwise, false.')
param alwaysOn bool = false

@description('true if client affinity is enabled; otherwise, false.')
param clientAffinityEnabled bool = true

@description('App command line to launch.')
param startupCommand string = ''

@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests')
param httpsOnly bool = true

resource web_app_resource 'Microsoft.Web/sites@2021-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: (useManagedIdentity ? 'SystemAssigned' : 'None')
  }
  properties: {
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    virtualNetworkSubnetId: (virtualNetworkSubnetId != '' ? virtualNetworkSubnetId : null)
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      appSettings: appSettings
      appCommandLine: startupCommand
      alwaysOn: alwaysOn
      vnetRouteAllEnabled: (virtualNetworkSubnetId != '' ? true : false)
      http20Enabled: (virtualNetworkSubnetId != '' ? true : false)
    }
    serverFarmId: resourceId(appServicePlanRg, 'Microsoft.Web/serverfarms', appServicePlanName)
  }
}

output principalId string = web_app_resource.identity.principalId
output url string = web_app_resource.properties.defaultHostName
