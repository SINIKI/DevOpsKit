Set-StrictMode -Version Latest
function Set-AzSKEventHubSettings
{
	<#
	.SYNOPSIS
	This command would help in updating the EventHub configuration settings under the current powershell session.
	.DESCRIPTION
	This command will update the EventHub settings under the current powershell session. This also remembers the current settings and use them in the subsequent sessions.
	
	.PARAMETER EventHubNamespace
		Namespace name of the EventHub.  
	.PARAMETER EventHubName
		Name of the EventHub within the namespace that will receive the events.
	.PARAMETER EventHubSendKeyName
		Name of the send key (as configured for the EventHub instance).
	.PARAMETER EventHubSendKey
		Value of the key used to generate the SAS token to access the EventHub for sending messages.
	.PARAMETER Source
		Provide the source of EventHub Events.(e.g. CC,CICD,SDL)
	.PARAMETER Disable
		Use -Disable option to clean the EventHub setting under the current instance.	

	.LINK
	https://aka.ms/azskossdocs 

	#>
	param(
        
		[Parameter(Mandatory = $true, HelpMessage="Namespace name of the EventHub.", ParameterSetName = "Setup")]
        [AllowEmptyString()]
        [string]
        $EventHubNamespace,

        [Parameter(Mandatory = $true, HelpMessage="Name of the EventHub within the namespace that will receive the events..", ParameterSetName = "Setup")]
        [AllowEmptyString()]
        [string]
        $EventHubName,

		[Parameter(Mandatory = $true, HelpMessage="Name of the send key (as configured for the EventHub instance)..", ParameterSetName = "Setup")]
        [AllowEmptyString()]
        [string]
        $EventHubSendKeyName,

        [Parameter(Mandatory = $true, HelpMessage="Value of the key is used to generate the SAS token to access the Event Hub for sending messages.", ParameterSetName = "Setup")]
        [AllowEmptyString()]
        [string]
        $EventHubSendKey,

		[Parameter(Mandatory = $false, HelpMessage="Provide the source of EventHub Events.(e.g. CC,CICD,SDL)", ParameterSetName = "Setup")]
        [AllowEmptyString()]
        [string]
        $Source,

        [Parameter(Mandatory = $true, HelpMessage="Use -Disable option to clean the EventHub setting under the current instance.", ParameterSetName = "Disable")]
        [switch]
        $Disable
    )
	Begin
	{
		[CommandHelper]::BeginCommand($PSCmdlet.MyInvocation);
		[ListenerHelper]::RegisterListeners();
	}
	Process
	{
		try
		{
			$appSettings = [ConfigurationManager]::GetLocalAzSKSettings();
			if(-not $Disable) 
			{
        			$appSettings.EventHubNamespace = $EventHubNamespace
	    			$appSettings.EventHubName = $EventHubName
	    			$appSettings.EventHubSendKeyName = $EventHubSendKeyName
	    			$appSettings.EventHubSendKey = $EventHubSendKey;
			}
			else {
        			$appSettings.EventHubNamespace = ""
	    			$appSettings.EventHubName = ""
	    			$appSettings.EventHubSendKeyName = ""
	    			$appSettings.EventHubSendKey = "";
			}
			if(-not [string]::IsNullOrWhiteSpace($Source))
			{				
				$appSettings.EventHubSource = $Source
			}
			else
			{
				$appSettings.EventHubSource = "SDL"
			}			
			[ConfigurationManager]::UpdateAzSKSettings($appSettings);
		}
		catch
		{
			[EventBase]::PublishGenericException($_);
		}
	}
	End
	{
		[ListenerHelper]::UnregisterListeners();
	}
}

