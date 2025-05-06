# Recording Maintaince_templete from previous projects

### Azure
1. [Deploy Applications To Azure](/Azure/DeployApplicationsToAzure/): The templetes to deploy application on Azure.  
*(Reference: [Deploying Applications with Azure DevOps](https://github.com/Noah-Zhuhaotian/Documents/blob/main/Azure/Azure-DevOps/Deploying-Applications-with-Azure-DevOps.md))*

2. [AKS](/Azure/AKS/): AKS cluster maintanice scrips.  
   
3. [Setting Up Secure Connections in Azure Data Factory with Key Vault](/Azure/Security/DF_SQL/): A templete of creating a linked service in Azure Data Factory that connects to Azure SQL Database using Microsoft SQL Server authentication, with the password securely stored in Azure Key Vault.  
*(Reference: [Setting Up Secure Connections in Azure Data Factory with Key Vault](https://github.com/Noah-Zhuhaotian/Documents/blob/main/Azure/Data-integration/Setting-Up-Secure-Connections-in-Azure-Data-Factory-with-Key-Vault.md))*

### AWS
1. [Demo-Tomcat](/AWS/Demo-Tomcat/): Deploying a Java Application to Amazon EC2 Using CodePipeline and CodeDeploy.  
*(Reference: [Deploying a Java Application to Amazon EC2 Using CodePipeline and CodeDeploy (with GitHub OAuth Token Managed by Secrets Manager)](https://github.com/Noah-Zhuhaotian/Documents/blob/main/AWS/AWS-DevOps/Deploying%20a%20Java%20Application%20to%20Amazon%20EC2%20Using%20CodePipeline%20and%20CodeDeploy%20(with%20GitHub%20OAuth%20Token%20Managed%20by%20Secrets%20Manager).md))*

### Function
1. [retry.py](/function/retry.py): To implement a retry mechanism. The `do_action()` function simulates an action that may fail by always raising an exception. It's decorated with the `@retry` decorator from tenacity, which automatically retries the function with a fixed wait of 2 seconds between attempts.

2. [check_if_exists.py](/function/check_if_exists.py): The function of implementing a function to find the process on the server quickly.

3. [checkostype.py](/function/checkostype.py): The function of collecting fleet of servers.

4. [docker backup mysql](/function/docker_mysql_backup.py): To use Docker backup Mysql DB.

### Monitoring
1. [GrafanaTemplete](/Monitoring/GrafanaTemplete/GrafanaTemplete): Dashboard for monitoring Kubernets Cluster.
