param location string
param aksResourceId string
param devActionGroupResourceId string
param testActionGroupResourceId string
param prodActionGroupResourceId string
param emailActionGroupResourceId string
param monitorWorkspaceName string
param severitynode int
param severitynamespace int
param severitycluster int

resource monitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' existing = {
  name: monitorWorkspaceName
}

resource clusterAlertsNP 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-NP-002') {
  name: 'Kubernetes Cluster-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Cluster Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: 'sum by (cluster) (rate (container_cpu_usage_seconds_total{job="cadvisor"}[1m])) / sum by (cluster) (machine_cpu_cores{job="cadvisor"}) > .80'
        for: 'PT15M'
        annotations: {
          description: 'The CPU usage of {{ $labels.cluster }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitycluster
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}

resource clusterAlertsPD 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-PD-002') {
  name: 'Kubernetes Cluster-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Cluster Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: 'sum by (cluster) (rate (container_cpu_usage_seconds_total{job="cadvisor"}[1m])) / sum by (cluster) (machine_cpu_cores{job="cadvisor"}) > .80'
        for: 'PT15M'
        annotations: {
          description: 'The CPU usage of {{ $labels.cluster }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitycluster
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}


resource nodeAlertsNP 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-NP-002') {
  name: 'Kubernetes Node-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Node Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: '(  (1 - rate(node_cpu_seconds_total{job="node", mode="idle"}[5m]) ) / ignoring(cpu) group_left count without (cpu)( node_cpu_seconds_total{job="node", mode="idle"}) ) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The CPU of {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Memory Usage'
        expression: '1 - avg by (namespace,cluster,job,node)(node_memory_MemAvailable_bytes{job="node"}* on(instance) group_left(node) (node_uname_info)) / avg by (namespace,cluster,job,node)(node_memory_MemTotal_bytes{job="node"}* on(instance) group_left(node) (node_uname_info)) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The Memory of {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Disk Usage'
        expression: '(sum by (node) (node_filesystem_size_bytes{mountpoint="/"})-sum by (node)  (node_filesystem_free_bytes{mountpoint="/"}))/sum by (node)  (node_filesystem_size_bytes{mountpoint="/"}) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The usage of disk in {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'Node Not Ready status'
        expression: 'sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (cluster, node) > 2 '
        for: 'PT15M'
        annotations: {
          description: 'Node: {{ $labels.node }} was not ready more than 2 times in the last 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% of Pod created'
        expression: 'sum by (node) (kubelet_running_pods{job="kubelet" }) / sum by (node) (kube_node_status_capacity{resource="pods"}) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The Pods created in {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}

resource nodeAlertsPD 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-PD-002') {
  name: 'Kubernetes Node-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Node Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: '(  (1 - rate(node_cpu_seconds_total{job="node", mode="idle"}[5m]) ) / ignoring(cpu) group_left count without (cpu)( node_cpu_seconds_total{job="node", mode="idle"}) ) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'CPU of {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Memory Usage'
        expression: '1 - avg by (namespace,cluster,job,node)(node_memory_MemAvailable_bytes{job="node"}* on(instance) group_left(node) (node_uname_info)) / avg by (namespace,cluster,job,node)(node_memory_MemTotal_bytes{job="node"}* on(instance) group_left(node) (node_uname_info)) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'Memory of {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Disk Usage'
        expression: '(sum by (node) (node_filesystem_size_bytes{mountpoint="/"})-sum by (node)  (node_filesystem_free_bytes{mountpoint="/"}))/sum by (node)  (node_filesystem_size_bytes{mountpoint="/"}) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The usage of disk in {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'Node Not Ready status'
        expression: 'sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (cluster, node) > 2 '
        for: 'PT15M'
        annotations: {
          description: 'Node: {{ $labels.node }} was not ready more than 2 times in the last 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% of Pod created'
        expression: 'sum by (node) (kubelet_running_pods{job="kubelet" }) / sum by (node) (kube_node_status_capacity{resource="pods"}) > .80 '
        for: 'PT15M'
        annotations: {
          description: 'The Pods created in {{ $labels.node }} is: {{  $value | humanizePercentage }} that is more than 80% for 15 minutes.'
        }
        enabled: true
        severity: severitynode
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}

resource namespaceAlertsNP 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-NP-002') {
  name: 'Kubernetes Namespace-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Namespace Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: 'sum by (namespace) (node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{pod=~".*"})/ sum by (namespace) (kube_resourcequota{resource="limits.cpu",type="hard"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The CPU usage of {{ $labels.namespace }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Memory Usage'
        expression: 'sum by (namespace) (container_memory_rss{job="cadvisor"})/ sum by (namespace) (kube_resourcequota{resource="limits.memory",type="hard"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The Memory usage of {{ $labels.namespace }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Disk Usage (PVC)'
        expression: '(sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_capacity_bytes{job="kubelet"})-sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_available_bytes{job="kubelet"}))/ sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_capacity_bytes{job="kubelet"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The Disk usage of {{ $labels.persistentvolumeclaim }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'Pod Health'
        expression: 'sum by (namespace,pod) (kube_pod_status_phase{phase=~"pending|unknown|failed"})== 1 '
        for: 'PT15M'
        annotations: {
          description: 'The pod: {{ $labels.pod }} under {{ $labels.namespace }} is not healthy for 15 minitues.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'PV Status'
        expression: 'sum by (namespace,persistentvolumeclaim) (kube_persistentvolumeclaim_status_phase{phase!="Bound"}) == 1 '
        for: 'PT15M'
        annotations: {
          description: 'The status of pv: {{ $labels.persistentvolumeclaim }} under {{ $labels.namespace }} is not bound for 15 minitues.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: devActionGroupResourceId
          }
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: prodActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}

resource namespaceAlertsPD 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = if ('${split(aksResourceId, '/')[8]}' == 'AKS-PD-002') {
  name: 'Kubernetes Namespace-${split(aksResourceId, '/')[8]}'
  location: location
  properties: {
    description: 'Kubernetes Namespace Alerts'
    scopes: [monitorWorkspace.id,aksResourceId]
    clusterName: split(aksResourceId, '/')[8]
    enabled: true
    interval: 'PT60M'
    rules: [
      {
        alert: '% CPU Usage'
        expression: 'sum by (namespace) (node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate{pod=~".*"})/ sum by (namespace) (kube_resourcequota{resource="limits.cpu",type="hard"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The CPU usage of {{ $labels.namespace }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Memory Usage'
        expression: 'sum by (namespace) (container_memory_rss{job="cadvisor"})/ sum by (namespace) (kube_resourcequota{resource="limits.memory",type="hard"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The Memory usage of {{ $labels.namespace }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: '% Disk Usage (PVC)'
        expression: '(sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_capacity_bytes{job="kubelet"})-sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_available_bytes{job="kubelet"}))/ sum by (namespace,persistentvolumeclaim) (kubelet_volume_stats_capacity_bytes{job="kubelet"}) > .90 '
        for: 'PT15M'
        annotations: {
          description: 'The Disk usage of {{ $labels.persistentvolumeclaim }} is: {{  $value | humanizePercentage }} that is more than 90% for 15 minutes.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'Pod Health'
        expression: 'sum by (namespace,pod) (kube_pod_status_phase{phase=~"pending|unknown|failed"})== 1  '
        for: 'PT15M'
        annotations: {
          description: 'The pod: {{ $labels.pod }} under {{ $labels.namespace }} is not healthy for 15 minitues.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
      {
        alert: 'PV Status'
        expression: 'sum by (namespace,persistentvolumeclaim) (kube_persistentvolumeclaim_status_phase{phase!="Bound"}) == 1 '
        for: 'PT15M'
        annotations: {
          description: 'The status of pv: {{ $labels.persistentvolumeclaim }} under {{ $labels.namespace }} is not bound for 15 minitues.'
        }
        enabled: true
        severity: severitynamespace
        resolveConfiguration: {
          autoResolved: false
          timeToResolve: 'PT10M'
        }
        actions: [
          {
            actionGroupId: testActionGroupResourceId
          }
          {
            actionGroupId: emailActionGroupResourceId
          }
        ]
      }
    ]
  }
}
