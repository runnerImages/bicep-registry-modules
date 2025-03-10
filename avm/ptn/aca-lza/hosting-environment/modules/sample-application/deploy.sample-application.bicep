targetScope = 'subscription'

// ------------------
//    PARAMETERS
// ------------------
@description('Required. The resource names definition')
param resourcesNames object

@description('The location where the resources will be created. This needs to be the same region as the Azure Container Apps instances.')
param location string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Required. Whether to enable deplotment telemetry.')
param enableTelemetry bool

@description('Optional. The name of the Container App. If set, it overrides the name generated by the template.')
@minLength(2)
@maxLength(32)
param helloWorldContainerAppName string = 'ca-simple-hello'

@description('The resource ID of the existing user-assigned managed identity to be assigned to the Container App to be able to pull images from the container registry.')
param containerRegistryUserAssignedIdentityId string

@description('The resource ID of the existing Container Apps environment in which the Container App will be deployed.')
param containerAppsEnvironmentResourceId string

@description('The container apps environment workload profile to use for the Container App.')
param workloadProfileName string

// ------------------
// RESOURCES
// ------------------

module sampleApplication 'br/public:avm/res/app/container-app:0.12.0' = {
  name: helloWorldContainerAppName
  scope: resourceGroup(resourcesNames.resourceGroup)
  params: {
    name: helloWorldContainerAppName
    location: location
    tags: tags
    enableTelemetry: enableTelemetry
    environmentResourceId: containerAppsEnvironmentResourceId
    managedIdentities: {
      userAssignedResourceIds: [
        containerRegistryUserAssignedIdentityId
      ]
    }
    workloadProfileName: workloadProfileName
    containers: [
      {
        name: 'simple-hello'
        image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
        resources: {
          cpu: json('0.25')
          memory: '0.5Gi'
        }
      }
    ]
    scaleMinReplicas: 2
    scaleMaxReplicas: 10
    activeRevisionsMode: 'Single'
    ingressExternal: true
    ingressAllowInsecure: false
    ingressTargetPort: 80
    ingressTransport: 'auto'
  }
}

// ------------------
// OUTPUTS
// ------------------

@description('The FQDN of the "Hello World" Container App.')
output helloWorldAppFqdn string = sampleApplication.outputs.fqdn
