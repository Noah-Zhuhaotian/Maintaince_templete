# Maintaince_templete




1. You can use the templetes of [DeploytoWinServer](DeploytoWinServer) to deploy your api and webserver in Azure, upload the codes into your DevOps Repo and Replace the values in your actual environment.

2. You can import the templetes of [GrafanaTemplete](GrafanaTemplete) into your Grafana, the folder contians two files, one is for cluster another is for namespace.

3. You can upload the templetes of [AKS](AKS) into your Azure DevOps Repo, the templetes can assist to do some daily mantaince jobs for Kubernetes or AKS.

4. You can use the function of [retry.py](/function/retry.py) to implement a retry mechanism. The `do_action()` function simulates an action that may fail by always raising an exception. It's decorated with the `@retry` decorator from tenacity, which automatically retries the function with a fixed wait of 2 seconds between attempts.

5. You can use the function of [check_if_exists.py](/function/check_if_exists.py) to implement a function to find your some pragrams which you have installed on the server quickly.
   > [!TIP]
   > For Windows you can only find the programs you have already added into the environment variables.

6. You can use the function of [checkostype.py](/function/checkostype.py) to collect your fleet of servers.
