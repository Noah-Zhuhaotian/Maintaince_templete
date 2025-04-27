     call az resource show -g %resourceGroupName% -n %insightName% --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey>tmpInsightFile
     set /p insightTempVar= < tmpInsightFile 
     del tmpInsightFile
     echo ##vso[task.setvariable variable=insightVar;]%insightTempVar%

     call az resource show -g %resourceGroupName% -n %aksIdentityName% --resource-type "Microsoft.ManagedIdentity/userAssignedIdentities" --query properties.clientId>tmpIdentityFile
     set /p identityTempVar= < tmpIdentityFile 
     del tmpIdentityFile
     echo ##vso[task.setvariable variable=identityVar;]%identityTempVar%