@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

param resourceGroupName string = ''

@description('The name of the App Service application to create. This must be globally unique.')
param appName string = 'myapp-{0}-${uniqueString(resourceGroup().id)}'

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = 'afd-${uniqueString(resourceGroup().id)}'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Standard_AzureFrontDoor'

var frontDoorProfileName = 'MyFrontDoor'
var frontDoorOriginGroupName = 'MyOriginGroup'
var frontDoorOriginName = 'MyAppServiceOrigin{0}'
var frontDoorRouteName = 'MyRoute'

var appServicePlanNameEuropeWest = 'asp-euw-afd'
var appServicePlanNameEuropeNorth = 'asp-eun-afd'
var appServicePlanNameEastUs = 'asp-usw-afd'

module appServicePlan '../shared/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanNameEuropeWest
    skuTier: 'Basic'
    skuName: 'B1'
    skuCapacity: 1
  }
}

module appServicePlanNorthEurope '../shared/app-service-plan.bicep' = {
  name: 'appServicePlanNorthEurope'
  params: {
    location: 'North Europe'
    appServicePlanName: appServicePlanNameEuropeNorth
    skuTier: 'Basic'
    skuName: 'B1'
    skuCapacity: 1
  }
}

module appServicePlanEastUs '../shared/app-service-plan.bicep' = {
  name: 'appServicePlanEastUs'
  params: {
    location: 'East US'
    appServicePlanName: appServicePlanNameEastUs
    skuTier: 'Basic'
    skuName: 'B1'
    skuCapacity: 1
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource app 'Microsoft.Web/sites@2020-06-01' = {
  name: format(appName, 0)
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

resource appTwo 'Microsoft.Web/sites@2020-06-01' = {
  name: format(appName, 1)
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.outputs.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlan
  ]
}

resource appThree 'Microsoft.Web/sites@2020-06-01' = {
  name: format(appName, 2)
  location: 'North Europe'
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanNorthEurope.outputs.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlanNorthEurope
  ]
}

resource appFour 'Microsoft.Web/sites@2020-06-01' = {
  name: format(appName, 3)
  location: 'East US'
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanEastUs.outputs.id
    httpsOnly: true
    siteConfig: {
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
      requestTracingEnabled: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorProfile.properties.frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
    }
  }
  dependsOn: [
    appServicePlanEastUs
  ]
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: format(frontDoorOriginName, 0)
  parent: frontDoorOriginGroup
  properties: {
    hostName: app.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: app.properties.defaultHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorOriginTwo 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: format(frontDoorOriginName, 1)
  parent: frontDoorOriginGroup
  properties: {
    hostName: appTwo.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: appTwo.properties.defaultHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorOriginThree 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: format(frontDoorOriginName, 2)
  parent: frontDoorOriginGroup
  properties: {
    hostName: appThree.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: appThree.properties.defaultHostName
    priority: 3
    weight: 1000
  }
}

resource frontDoorOriginFour 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: format(frontDoorOriginName, 3)
  parent: frontDoorOriginGroup
  properties: {
    hostName: appFour.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: appFour.properties.defaultHostName
    priority: 4
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: frontDoorRouteName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output appServiceHostName string = app.properties.defaultHostName
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
