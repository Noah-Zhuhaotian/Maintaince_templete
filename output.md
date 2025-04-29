5.12 How to clear the cluster whether contains the unhealthy PVCs or PVs.

# Introduction

There will emerge some unhealthy PVCs if the pods run as abnormal status which use the PVCs and PVs. It would need us to clear these dirty data by using pipelines. Before clearing these dirty data, we need to double check if the clusters do have these unhealthy PVCs or PVs.

If you want to know some basic knowledge about the PVCs and PVs. You can refer to the following links:

[Concepts - Storage in Azure Kubernetes Services (AKS) - Azure Kubernetes Service | Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/concepts-storage)

[Persistent Volumes | Kubernetes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

# Check the clusters if that contain the unhealthy PVCs or PVs

Make sure you have installed the kubelogin. If you don’t install, please follow:

Initialize Environment  ([Web view](https://workspaces.bsnconnect.com/sites/PSCAppKX/TM-WinApps/_layouts/OneNote.aspx?id=%2Fsites%2FPSCAppKX%2FTM-WinApps%2FWPS%2FWinApps%20App%20Inventory&wd=target%28AKS%20%28project%20work%5C%29.one%7C37625D5A-B695-4056-BBA8-7D87D52A2054%2FInitialize%20Environment%7C63B78094-C202-4F42-8EF3-020F1F2E6F05%2F%29))

1. PIM the permission that you need to check.

AKS-SB-001:

![](data:image/png;base64...)

AKS-NP-002:

![](data:image/png;base64...)

AKS-PD-002:

![](data:image/png;base64...)

1. Check each PVs if they are in the correct status.
2. From the PowerShell or CMD

kubectl get pv

**#az login**

az login

az account set --subscription "DWZ-NC-CNE-App-01"

**#get creds for cluster**

az aks get-credentials --resource-group RG-PD-0001547 --name aks-PD-002

az aks get-credentials --resource-group RG-NP-0001581 --name aks-NP-002

az aks get-credentials --resource-group RG-T-0003321 --name aks-SB-001

1. From Azure portal:

AKS-SB-001:

[AKS-SB-001 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/RG-T-0003321/providers/Microsoft.ContainerService/managedClusters/aks-sb-001/storage)

AKS-NP-002:

[AKS-NP-002 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/rg-np-0001581/providers/Microsoft.ContainerService/managedClusters/AKS-NP-002/storage)

AKS-PD-002:

[AKS-PD-002 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/RG-PD-0001547/providers/Microsoft.ContainerService/managedClusters/AKS-PD-002/storage)

You will get the following information:

1. PowerShell or CMD

![](data:image/png;base64...)

1. Azure portal:

![](data:image/png;base64...)

If the status is not “Bound” like "Failed", "Pending", "Released":

Run the following pipeline to delete the unhealthy PVs:

[Pipelines - Runs for APM0004459-Aks Cluster Management clear unattached and released pv (visualstudio.com)](https://dow-vsts.visualstudio.com/DevSecOps/_build?definitionId=6954&_a=summary)

Select the “main” branch and choose the environment you want to clear, then run.

![](data:image/png;base64...)

Note: If you want to clear the Prod, you need to raise a change to get a ticket number to run this pipeline.

1. Check each PVCs if they are in the correct status.
2. From the PowerShell or CMD

**#az login**

az login

az account set --subscription "DWZ-NC-CNE-App-01"

**#get creds for cluster**

az aks get-credentials --resource-group RG-PD-0001547 --name aks-PD-002

az aks get-credentials --resource-group RG-NP-0001581 --name aks-NP-002

az aks get-credentials --resource-group RG-T-0003321 --name aks-SB-001

**#get the PVs**

**kubectl get pvc -A**

1. From Azure portal:

AKS-SB-001:

[AKS-SB-001 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/RG-T-0003321/providers/Microsoft.ContainerService/managedClusters/aks-sb-001/storage)

AKS-NP-002:

[AKS-NP-002 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/rg-np-0001581/providers/Microsoft.ContainerService/managedClusters/AKS-NP-002/storage)

AKS-PD-002:

[AKS-PD-002 - Microsoft Azure](https://portal.azure.com/?feature.msaljs=true#@bsnconnect.onmicrosoft.com/resource/subscriptions/6060ea50-d00d-4c40-8219-546ed259f9e5/resourceGroups/RG-PD-0001547/providers/Microsoft.ContainerService/managedClusters/AKS-PD-002/storage)

You will get the following information:

From the PowerShell or CMD:

![A blue background with white text  Description automatically generated](data:image/png;base64...)

From the portal:

![A screenshot of a computer  Description automatically generated](data:image/png;base64...)

Run the following pipeline to delete the unhealthy PVs:

[Pipelines - Runs for APM0004459-Aks Cluster Management Delete unhealthy pvc (visualstudio.com)](https://dow-vsts.visualstudio.com/DevSecOps/_build?definitionId=6984)

Select the “main” branch and choose the environment you want to clear, then run.

![](data:image/png;base64...)

Note: If you want to clear the Prod, you need to raise a change to get a ticket number to run this pipeline.