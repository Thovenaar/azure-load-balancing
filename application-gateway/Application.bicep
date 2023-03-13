param location string = resourceGroup().location
param resourceGroupName string

var appServicePlanName = 'asp-euw-agw'
var appServiceName = 'app-euw-agw-{0}'
var virtualNetworkName = 'agw-vnet-1'

module appServicePlan '../shared/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuTier: 'Basic'
    skuName: 'B1'
    skuCapacity: 1
  }
}

module virtualNetwork '../shared/virtual-network.bicep' = {
  name: 'virtualNetwork'
  params: {
    location: location
    vnetName: virtualNetworkName
  }
}

module appServiceOne '../shared/app-service.bicep' = {
  name: format(appServiceName, 1)
  params: {
    location: location
    appServicePlanName: appServicePlanName
    appServicePlanRg: resourceGroupName
    linuxFxVersion: 'DOTNETCORE|6.0'
    webAppName: format(appServiceName, 1)
    // virtualNetworkSubnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    appServicePlan
  ]
}

module appServiceTwo '../shared/app-service.bicep' = {
  name: format(appServiceName, 2)
  params: {
    location: location
    appServicePlanName: appServicePlanName
    appServicePlanRg: resourceGroupName
    linuxFxVersion: 'DOTNETCORE|6.0'
    webAppName: format(appServiceName, 2)
    // virtualNetworkSubnetId: virtualNetwork.outputs.vnetId
  }
  dependsOn: [
    appServicePlan
  ]
}
