param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string
param Availability string
param DiskEncryption bool
param DiskSku string
param DomainName string
param DomainServices string
param EphemeralOsDisk bool
param ImageSku string
param KerberosEncryption string
param Location string
param ManagedIdentityResourceId string
param NamingStandard string
param PooledHostPool bool
param RecoveryServices bool
param SecurityPrincipalIds array
param SecurityPrincipalNames array
param SessionHostCount int
param SessionHostIndex int
param StartVmOnConnect bool
param StorageCount int
param StorageSolution string
param Tags object
param Timestamp string
param VirtualNetwork string
param VirtualNetworkResourceGroup string
param VmSize string


var SecurityPrincipalIdsCount = length(SecurityPrincipalIds)
var SecurityPrincipalNamesCount = length(SecurityPrincipalNames)


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-${NamingStandard}-validation'
  location: Location
  tags: Tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentityResourceId}': {}
    }
  }
  properties: {
    forceUpdateTag: Timestamp
    azPowerShellVersion: '5.4'
    arguments: '-Availability ${Availability} -DiskEncryption ${DiskEncryption} -DiskSku ${DiskSku} -DomainName ${DomainName} -DomainServices ${DomainServices} -Environment ${environment().name} -EphemeralOsDisk ${EphemeralOsDisk} -ImageSku ${ImageSku} -KerberosEncryption ${KerberosEncryption} -Location ${Location} -PooledHostPool ${PooledHostPool} -RecoveryServices ${RecoveryServices} -SecurityPrincipalIdsCount ${SecurityPrincipalIdsCount} -SecurityPrincipalNamesCount ${SecurityPrincipalNamesCount} -SessionHostCount ${SessionHostCount} -SessionHostIndex ${SessionHostIndex} -StartVmOnConnect ${StartVmOnConnect} -StorageCount ${StorageCount} -StorageSolution ${StorageSolution} -VmSize ${VmSize} -VnetName ${VirtualNetwork} -VnetResourceGroupName ${VirtualNetworkResourceGroup}'
    primaryScriptUri: '${_artifactsLocation}Get-Validation.ps1${_artifactsLocationSasToken}'
    timeout: 'PT2H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output acceleratedNetworking string = deploymentScript.properties.outputs.acceleratedNetworking
output anfActiveDirectory string = deploymentScript.properties.outputs.anfActiveDirectory
output anfDnsServers string = deploymentScript.properties.outputs.anfDnsServers
output anfSubnetId string = deploymentScript.properties.outputs.anfSubnetId
output dnsForwarders array = deploymentScript.properties.outputs.dnsForwarders
output dnsServerSize string = deploymentScript.properties.outputs.dnsServerSize
output ephemeralOsDisk string = deploymentScript.properties.outputs.ephemeralOsDisk
output trustedLaunch string = deploymentScript.properties.outputs.trustedLaunch
