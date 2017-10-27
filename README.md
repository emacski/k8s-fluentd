[![Build Status](https://travis-ci.org/emacski/k8s-fluentd.svg?branch=master)](https://travis-ci.org/emacski/k8s-fluentd)

Kubernetes Fluentd (Elasticsearch)
----------------------------------

Alternative fluentd docker image designed as a drop-in replacement for the fluentd-es-image in the fluentd-elasticsearch cluster-level logging addon. This image provides support for shipping journald logs for docker and kubelet since these services are often managed by systemd.

**Components**

| Component | Version |
| --------- | ------- |
| fluentd | 0.14.20 |
| fluent-plugin-elasticsearch | 1.10.2 |
| fluent-plugin-kubernetes_metadata_filter | 0.29.0 |
| fluent-plugin-systemd | 0.3.1 |

**Configuration**

Uses [ReDACT](https://github.com/emacski/redact) for fluentd configuration.

| Environment Variable | Description |
| -------------------- | ----------- |
| `fluentd_es_host` | The elasticsearch host to connect to (Default: `elasticsearch-logging`) |
| `fluentd_es_port` | The elasticsearch API port (Default: `9200`) |
| `fluentd_systemd_docker_service` | The name of the systemd docker service (Example: `docker.service`). If supplied fluentd will parse logs from the system journal, otherwise fluentd will look for log files on disk (Default: empty) |
| `fluentd_systemd_kubelet_service` | The name of the systemd kubelet service (Example: `kubelet.service`). If supplied fluentd will parse logs from the system journal, otherwise fluentd will look for log files on disk (Default: empty) |

**Example DaemonSet**
```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd-es
  namespace: kube-system
  labels:
    k8s-app: fluentd-es
spec:
  template:
    metadata:
      labels:
        k8s-app: fluentd-es
        kubernetes.io/cluster-service: "true"
        addonmanager.kubernetes.io/mode: Reconcile
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "CriticalAddonsOnly"
        operator: "Exists"
      terminationGracePeriodSeconds: 30
      containers:
      - name: fluentd-es
        image: emacski/k8s-fluentd:latest
        env:
        - name: fluentd_systemd_docker_service
          value: "docker.service"
        - name: fluentd_systemd_kubelet_service
          value: "kubelet.service"
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: logs
          mountPath: /var/log
        - name: containers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: logs
        hostPath:
          path: /var/log
      - name: containers
        hostPath:
          path: /var/lib/docker/containers
```
