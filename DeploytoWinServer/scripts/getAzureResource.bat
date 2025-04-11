     call az resource show -g %resourceGroupName% -n %insightName% --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey>tmpInsightFile
     set /p insightTempVar= < tmpInsightFile 
     del tmpInsightFile
     echo ##vso[task.setvariable variable=insightVar;]%insightTempVar%