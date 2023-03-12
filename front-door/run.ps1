$resourcegroup = 'azure-load-balancing-afd'

az group create `
    --resource-group $resourcegroup `
    --location westeurope

az deployment group create `
    --resource-group $resourcegroup `
    --template-file 'Application.bicep' `
    --parameters resourceGroupName=$resourcegroup