$resourcegroup = 'azure-load-balancing-agw'

az group create `
    --resource-group $resourcegroup `
    --location westeurope

az deployment group create `
    --resource-group $resourcegroup `
    --template-file 'Applicationv3.bicep' `
    --parameters resourceGroupName=$resourcegroup