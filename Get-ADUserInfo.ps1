
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.167
	 Created on:   	28/08/2020 9:14 AM
	 Created by:   	jsavage
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		Returns a list of useful information relevant to an Active Directory account.
		This function can run through multiple AD objects, as well as accept information from the pipeline. 

	.EXAMPLE
		Get-ADUserInfo -Identity "Username"
#>

function Get-ADUserInfo
{
	param
	(
		[Parameter (mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateLength (3, 10)]
		[String[]]$Username
	)
	
	Begin
	{
		#create an array for a neater script
		$ADUserproperties =
		@(
			"Name"
			"UserPrincipalName"
			"Description"
			"Enabled"
			"CanonicalName"
			"Created"
			"Pager"
			"LockedOut"
			"PasswordExpired"
			"msDS-UserPasswordExpiryTimeComputed"
			"PasswordLastSet"
			"BadLogonCount"
			"badPwdCount"
			"LastBadPasswordAttempt"
			"LastLogon"
		)
		
		#Repeat array except with the added hash table to add in the expiry date.
		#Unable to put the hash table in the first array as the -properties parameter searches based on the name, and "ExpiryDate" is not a valid property of an ADuser.
		
		$selectproperties =
		@(
			"Name"
			@{
				Name	   = "User Principal Name";
				Expression =
				{
					$_.UserPrincipalName
				}
			}
			
			@{
				Name	   = "Job Description";
				Expression =
				{
					$_.Description
				}
			}
			
			"Enabled"
			
			@{
				Name	   = "OU Path";
				Expression =
				{
					$_.CanonicalName
				}
			}
			
			"Created"
			
			@{
				Name	   = "Printer Card Number";
				Expression =
				{
					$_.Pager
				}
			}
			
			@{
				Name	   = "Locked Out";
				Expression =
				{
					$_.LockedOut
				}
			}
			
			@{
				Name	   = "Password Expired";
				Expression =
				{
					$_.PasswordExpired
				}
			}
			
			@{
				Name	   = "Password Expiry Date";
				Expression =
				{
					[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
				}
			}
			
			@{
				Name	   = "Password Last Set";
				Expression =
				{
					$_.PasswordLastSet
				}
			}
			
			@{
				Name	   = "Bad Logon Count";
				Expression =
				{
					$_.BadLogonCount
				}
			}
			
			@{
				Name	   = "Bad Password Count";
				Expression =
				{
					$_.badPwdCount
				}
			}
			
			@{
				Name	   = "Last Bad Password";
				Expression =
				{
					$_.LastBadPasswordAttempt
				}
			}
			
			@{
				Name	   = "Last Logon";
				Expression =
				{
					[datetime]::FromFileTime($_.LastLogon)
				}
			}
		)
	}
	
	Process
	{
		foreach ($user in $Username)
		{
			try
			{
				(Get-ADUser -Identity $user -properties $ADUserproperties | Select-Object $selectproperties | Format-List | Out-String) -replace '\r?\n', "`r`n`r`n"
				Get-ADPrincipalGroupMembership -Identity $user | select-object Name -ExpandProperty Name | Sort-Object name
			}
			
			catch
			{
				"Could not find '$($user)' in Active Directory"
			}
		}
	}
	
	End
	{
		
	}
}
	