param location string = resourceGroup().location
param appServicePlanName string

@description('Service tier of the resource SKU.')
@allowed([
  'D1'
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
  'I1'
  'I2'
  'I3'
  'Y1'
])
param skuName string

param skuCapacity int

@description('Service tier of the resource SKU.')
@allowed([
  'Shared'
  'Free'
  'Basic'
  'Standard'
  'Premium'
  'PremiumV2'
  'Isolated'
  'Dynamic' // Consumption plan
])
param skuTier string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  kind: 'linux'
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
    tier: skuTier
  }
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
