param Environment string
param ImageDefinitionName string
param ImageDefinitionResourceId string
param ImageOffer string
param ImagePublisher string
param ImageSku string
param ImageStorageAccountType string
param ImageVersion string
param Location string
param LocationShortName string
param StorageUri string
param SubnetName string
param Tags object
param Timestamp string
param UserAssignedIdentityResourceId string
param VirtualMachineSize string
param VirtualNetworkName string
param VirtualNetworkResourceGroupName string

@description('An array of objects representing an application install.  Include the following properties: InstallName(String),ExpandArchive(bool), FileURI(string), FileName(string), InstallFileLocation(string), InstallArguments(string)')
param CustomizeSettings array = [
  {
    InstallName: 'office install'
    ExpandArchive: true 
    FileURI: '${StorageUri}/office.zip'
    FileName: 'office.exe'
    InstallFileLocation: './office/setup.exe'
    InstallArguments: '/configure ./office/configuration-Office365-x64.xml'
  }
  {
    InstallName: 'Microsoft Project & Visio'
    ScriptInstall: true
    scriptUri: '${StorageUri}projectVisio.ps1'
  }
]

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: 'imgt-${toLower(ImageDefinitionName)}-${Environment}-${LocationShortName}'
  location: Location
  tags: Tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserAssignedIdentityResourceId}': {
      }
    }
  }
  properties: {
    stagingResourceGroup: '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-aib-staging-${toLower(ImageDefinitionName)}-${Environment}-${LocationShortName}'
    buildTimeoutInMinutes: 300
    vmProfile: {
      vmSize: VirtualMachineSize
      vnetConfig: !empty(SubnetName) ? {
        subnetId: resourceId(VirtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', VirtualNetworkName, SubnetName)
      } : null
    }
    source: {
      type: 'PlatformImage'
      publisher: ImagePublisher
      offer: ImageOffer
      sku: ImageSku
      version: ImageVersion
    }
    customize: [for Install in CustomizeSettings: Install.ScriptInstall ? {
      type: 'PowerShell'
      name: Install.InstallName
      runElevated: true
      runAsSystem: true
      scriptUri: Install.ScriptURI
      } : {
      type: 'PowerShell'
      name: Install.InstallName
      runAsSystem: true
      runElevated: true
      inline: [
        'Invoke-WebRequest -Uri "${Install.FileURI}" -OutFile "${Install.FileName}"'
        Install.ExpandArchive ? 'Expand-Archive -LiteralPath "./${Install.FileName}" -Force' : ''
        'Start-Process -FilePath "${Install.InstallFileLocation}" -ArgumentList "${Install.InstallArguments}" -Wait -PassThru'
      ]
    }]
    
    /*[
      {
        type: 'PowerShell'
        name: 'Virtual Desktop Optimization Tool'
        runElevated: true
        runAsSystem: true
        scriptUri: '${StorageUri}vdot.ps1'
      }
      {
        type: 'PowerShell'
        name: 'Microsoft Project & Visio'
        runElevated: true
        runAsSystem: true
        scriptUri: '${StorageUri}projectVisio.ps1'
      }
      /*{
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'Restarting post VDOT\''
        restartTimeout: '5m'
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
      }
    ]*/
    
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: ImageDefinitionResourceId
        runOutputName: Timestamp
        artifactTags: {}
        replicationRegions: [
          Location
        ]
        storageAccountType: ImageStorageAccountType
      }
    ]
  }
}
