@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location
param resourceGroupName string = ''

@description('Relative DNS name for the traffic manager profile, must be globally unique.')
param uniqueDnsName string = 'cdn-euw-traf'

var appServiceName = 'app-euw-traf-{0}'
var appServicePlanNameEuropeWest = 'asp-euw-traf'

module appServicePlan '../shared/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanNameEuropeWest
    skuTier: 'Standard'
    skuName: 'S1' // S1 is the minimum for Traffic Manager
    skuCapacity: 1
  }
}

module appServiceOne '../shared/app-service.bicep' = {
  name: format(appServiceName, 1)
  params: {
    location: location
    httpsOnly: true
    appServicePlanName: appServicePlanNameEuropeWest
    appServicePlanRg: resourceGroupName
    linuxFxVersion: 'DOTNETCORE|6.0'
    webAppName: format(appServiceName, 1)
  }
  dependsOn: [
    appServicePlan
  ]
}

module appServiceTwo '../shared/app-service.bicep' = {
  name: format(appServiceName, 2)
  params: {
    location: location
    httpsOnly: true
    appServicePlanName: appServicePlanNameEuropeWest
    appServicePlanRg: resourceGroupName
    linuxFxVersion: 'DOTNETCORE|6.0'
    webAppName: format(appServiceName, 2)
  }
  dependsOn: [
    appServicePlan
  ]
}

resource ExternalEndpointExample 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: 'ExternalEndpointExample'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
      intervalInSeconds: 10
      toleratedNumberOfFailures: 2
      timeoutInSeconds: 5
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 202
        }
        {
          min: 301
          max: 302
        }
      ]
    }
    endpoints: [
      {
        type: 'Microsoft.Network/trafficManagerProfiles/AzureEndpoints'
        name: 'myPrimaryEndpoint'
        properties: {
          target: appServiceOne.outputs.url
          targetResourceId: appServiceOne.outputs.id
          endpointStatus: 'Enabled'
          endpointLocation: 'West Europe'
          priority: 1
        }
      }
      {
        type: 'Microsoft.Network/TrafficManagerProfiles/ExternalEndpoints' // Sadly there can only be one endpoint per Azure Region, thus we fallback on an external endpoint
        name: 'myFailoverEndpoint'
        properties: {
          target: appServiceTwo.outputs.url
          endpointStatus: 'Enabled'
          endpointLocation: 'West Europe'
          priority: 2
        }
      }
    ]
  }
}
