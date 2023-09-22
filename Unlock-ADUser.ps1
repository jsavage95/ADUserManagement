<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.167
	 Created on:   	9/06/2020 8:14 AM
	 Created by:   	jsavage
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		Unlocks an Active Directory account and wild-card searches based on last name. 
		Presents options through Out-Gridview and unlocks the account after selecting the object, then OK.
#>


function Unlock-ADUser
{
	
	param
	(
		[parameter (Mandatory = $true, ParameterSetName = "Last Name")]
		[string]$EnterLastName
	)

	$selecteduser = Get-ADUser -Filter "SamAccountName -like '*$EnterLastName*'" -Properties DisplayName, SamAccountName, LockedOut | Select-Object DisplayName, SamAccountName, LockedOut | out-gridview -Passthru 


	if ((Get-ADUser $selecteduser.SamAccountName -Properties LockedOut | Select-Object -Expandproperty LockedOut) -eq $true)
		{
			Unlock-ADAccount $selecteduser.SamAccountName
			Write-Output "Successfully unlocked $($selecteduser.SamAccountName) in AD"
		}
	
	else
		{
			Write-Host "$($selecteduser.SamAccountName) is already unlocked"
		}

}