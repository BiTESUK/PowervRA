﻿function Remove-vRANetworkProfileIPRange {
<#
    .SYNOPSIS
    Remove an ip range from a network profile
    
    .DESCRIPTION
    Remove an ip range from a network profile
        
    .PARAMETER NetworkProfileId
    The id of the network profile

    .PARAMETER Name
    The name of the network profile ip range

    .INPUTS
    System.String

    .EXAMPLE
    Get-vRANetworkProfile -Name "External" | Remove-vRANetworkProfileIPRange -Name "External-Range-01"

#>
[CmdletBinding(SupportsShouldProcess,ConfirmImpact="High")]

    Param (

    [Alias("Id")]
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [String]$NetworkProfileId,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String[]]$Name   
       
    )
    
    begin {}
    
    process {    

        try {

            foreach ($NetworkProfileName in $Name) {

                # --- Get the network profile to modify
                $NetworkProfile = Invoke-vRARestMethod -Method GET -URI "/iaas-proxy-provider/api/network/profiles/$($NetworkProfileId)"

                #--- Test to see if the specified range exists

                if(!($NetworkProfile.definedRanges | Where-Object {$_.name -eq $NetworkProfileName})) {

                    throw "Could not find an IP Range with name $($NetworkProfileName)"

                }

                # --- Creae a new array
                Write-Verbose -Message "Removing IP Range $($NetworkProfileName) From Network Profile $($NetworkProfile.name)"
                $NetworkProfile.definedRanges = @($NetworkProfile.definedRanges | Where-Object {$_.name -ne $NetworkProfileName})

                if ($PSCmdlet.ShouldProcess($NetworkProfileId)){

                    $URI = "/iaas-proxy-provider/api/network/profiles/$($NetworkProfileId)"
            
                    Write-Verbose -Message "Preparing PUT to $($URI)"

                    Invoke-vRARestMethod -Method PUT -URI "$($URI)" -Body ($NetworkProfile | ConvertTo-Json -Depth 20 -Compress) | Out-Null

                    Write-Verbose -Message "SUCCESS"

                }
      
            }

        }
        catch [Exception]{
        
            throw

        }
        
    }   
     
}