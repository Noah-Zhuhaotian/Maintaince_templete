# recording Maintaince_templete from previous projects

### Azure DevOps
1. [DeploytoWinServer](DeploytoWinServer): To deploy api and webserver in Azure vitural machines.

2. [AKS](AKS): AKS cluster maintanice scrips.

### Function
1. [retry.py](/function/retry.py): To implement a retry mechanism. The `do_action()` function simulates an action that may fail by always raising an exception. It's decorated with the `@retry` decorator from tenacity, which automatically retries the function with a fixed wait of 2 seconds between attempts.

2. [check_if_exists.py](/function/check_if_exists.py): The function of implementing a function to find the process on the server quickly.

3. [checkostype.py](/function/checkostype.py): The function of collecting fleet of servers.

4. [docker backup mysql](/function/docker_mysql_backup.py): To use Docker backup Mysql DB.

### Monitoring
1. [GrafanaTemplete](GrafanaTemplete): Dashboard for monitoring Kubernets Cluster.