###################################################################################################################
#
# Script Name: rad_azure_upload.ps1
#
# Author: Michael Barrett, CDW Architect
#
# Date Created: May 16, 2024
# 
##################################################################################################################   
#
# Privacy & Intellectual Property Notice:
#
##################################################################################################################
# This procedure and its contents, and all future modifications and versions if this procedure
# are the confidential property of Loxa, LLC.  Loxa, LLC authorizes useage and future enhancements 
# to Radius Health, Inc. only.  Loxa, LLC authorizes use of this procedure, and any derivities of
# this procedure to Prime Solutions, LLC, exclusively for and on behalf of Radius Health, Inc. per
# the Master Services agreement in place between Loxa, LLC and Radius Health, Inc.
# Unauthorized use, reproduction, distribution, or modification for anuy use other than for Radius
# Health, Inc. is strictly prohibited.
# This procedure may contain sensitive operational logic or references to proprietary data 
# structures and processes.
#
# Use of this procedure is governed by internal data usage and privacy policies, Master Services
# Agreements in place between Loxa, LLC and Radius Health, Inc.
# All users must adhere to data protection regulations and organizational compliance rules as set 
# forth in the Master Sercices agreement betßween Loxa, LLC and Radius Health, Inc.
#
# © Loxa, LLC, All rights reserved.
###################################################################################################################

param (
#
# Input Arguments
#
       [string]$i_data_source,
       [string]$i_file_type,
#
# Local Variables
#       
       [string]$BaseDir,
       [string]$DataDir,
       [string]$ScheduleDir,
       [string]$DataSourceDir,
       [string]$debug,
       [string]$scriptID=$pid,
       [string]$azureCLIDir, 
       [string]$azureHost = "https://radiuscommsnowflakesa.blob.core.windows.net/",
       [string]$azureBase = "radiuscommsnowflakestage/",
       [string]$azureDataSourceDir = $azureHost + $azureBase + $i_data_source + "/",
       [string]$azureToken = "?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D",
       [string]$load_file,
       [string]$load_string
)

#
# Handle Cross Platform Development
#
If ($IsWindows) {
       $BaseDir = "C:"
       $DataDir = $BaseDir +  "\DATA"
       $ScheduleDir = $DataDir + "\Radius_Daily"
       $DataSourceDir = $ScheduleDir + "\" + $i_data_source
       } 
else {$BaseDir = "/Users/michaelbarrett"
        $DataDir = $BaseDir +  "/DATA"
        $ScheduleDir = $DataDir + "/Radius_Daily"
        $DataSourceDir = $ScheduleDir + "/" + $i_data_source
        $azureCLIDir = $BaseDir + "/" + "Applications"
       }

If ($debug = "Y") {
       Write-Output $BaseDir
       Write-Output $DataDir
       Write-Output $ScheduleDir
       Write-Output $DataSourceDir
}

#
# Get the name of the powershell script being called and tomestamps for logging
#
       $scriptName = $myInvocation.MyCommand.Name
       $scriptNameNoExt = (Get-Item $scriptName).BaseName
       $timeStamp = Get-Date -Format "yyyy-MM-dd-HH:mm:ss"
       $timeStamp_file = Get-Date -Format "yyyy_MM_dd_HHmmss"

#
# Write Debug
#
if ($debug = "Y") {
       Write-Output $scriptName
       Write-Output $scriptNameNoExt
       write-output "$timeStamp Data Source Directory is $DataSourceDir"
       write-output "$timeStamp Script Process ID is $scriptID"
}
#
# Write Header to Output or to Logging
#
write-Output  "############################################################################################################"
write-output  "#"
write-output  "# $timestamp Powershell script being exeucuted is $scriptName"
write-output  "#"
write-output  "# $timestamp Process ID is $scriptID"
write-output  "#"
write-output  "# $timestamp Data Source being processed is $i_data_source"
write-output  "#"
write-output  "############################################################################################################"


# [MPB] Shouldn't have to do this.....
#cd C:\Data\azcopy_windows_amd64_10.27.1

if ($i_data_source -eq "SAMPLE"){
       $FilePrefix = "FromRxS_Radius*"
       $azureDestination = $azureDataSourceDir + $azureToken
       }
       elseif ($i_data_source -eq "CLARITAS") {
              $FilePrefix = "crx*"
              $azureDestination = $azureDataSourceDir + $azureToken
       }
       elseif ($i_data_source -eq "VEEVA"){
              $FilePrefix = "Veeva*"
              $azureDestination = $azureDataSourceDir + $azureToken
       }


write-output "#"
write-output "# $timeStamp Locating most recent file from local drive for $i_data_source"
write-output "#"

$load_file = Get-ChildItem $DataSourceDir/$FilePrefix $i_file_type| sort-object lastwritetime | ForEach-Object {$_.Name} | Select-Object -last 1
$load_string = $DataSourceDir + $load_file

write-output "#"
write-output "# $timeStamp Beginning Asure Copy for Data Source $i_data_source and file $load_file"
write-output "#"
#
# Call Azure copy utulity moving local file to Radius' Azure blob location
#
#       azcopy copy $load_string $azureDestination

#
# End Script
#




#
#Sampling
#./azcopy  copy "C:\Data\Radius_Daily\FromRxS_Radius*.txt" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/SAMPLE/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true

#Claritas
#.\azcopy  copy "C:\Data\Radius_Daily\Radius_*.txt" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/CLARITAS/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true
#.\azcopy  copy "C:\Data\Radius_Daily\crx*.txt" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/CLARITAS/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true
#.\azcopy  copy "C:\Data\Radius_Daily\CRx*.txt" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/CLARITAS/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true

#VEEVA
#.\azcopy  copy "C:\Data\v55.0.1\EXTRACTS\VEEVA*.csv" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/CRM/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true

#RosterLimited
#.\azcopy  copy "C:\Data\Radius_Daily\FieldRoster_Limited.csv" "https://radiuscommsnowflakesa.blob.core.windows.net/radiuscommsnowflakestage/MISCLOAD/?sv=2022-11-02&ss=b&srt=co&sp=rwdlacyx&se=2034-07-17T01:52:47Z&st=2024-07-16T17:52:47Z&spr=https&sig=%2BXUFJNjfaBJE%2FpPYeDPycLuCiCI1m%2BX5%2BHy8z%2BFjtoI%3D" --recursive=true