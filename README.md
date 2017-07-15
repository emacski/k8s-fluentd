[![Build Status](https://travis-ci.org/emacski/k8s-fluentd.svg?branch=master)](https://travis-ci.org/emacski/k8s-fluentd)

Kubernetes Fluentd (Elasticsearch)
----------------------------------

Alternative fluentd docker image designed as a drop-in replacement for the
fluentd-es-image in the fluentd-elasticsearch cluster-level logging addon. This
image provides support for shipping journald logs for docker and kubelet since
these services are often managed by systemd.

**Components**

| Component | Version |
| --------- | ------- |
| fluentd | 0.14.19 |
| fluent-plugin-elasticsearch | 1.9.5 |
| fluent-plugin-kubernetes_metadata_filter | 0.27.0 |
| fluent-plugin-systemd | 0.2.0 |

**Configuration**

| Environment Variable | Description |
| -------------------- | ----------- |
| `FLUENTD_ES_HOST` | The elasticsearch host to connect to (Default: `elasticsearch-logging`) |
| `FLUENTD_ES_PORT` | The elasticsearch API port (Default: `9200`) |
| `FLUENTD_SYSTEMD_DOCKER_SERVICE` | The name of the systemd docker service (Example: `docker.service`). If supplied fluentd will parse logs from the system journal, otherwise fluentd will look for log files on disk (Default: empty) |
| `FLUENTD_SYSTEMD_KUBELET_SERVICE` | The name of the systemd kubelet service (Example: `kubelet.service`). If supplied fluentd will parse logs from the system journal, otherwise fluentd will look for log files on disk (Default: empty) |
| `FLUENTD_EXTENDED_CONFIG` | Used to add custom additional configuration directives (Default: empty) |

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
      imagePullSecrets:
      - name: gitlab
      containers:
      - name: fluentd-es
        image: emacski/k8s-fluentd:latest
        env:
        - name: FLUENTD_SYSTEMD_DOCKER_SERVICE
          value: "docker.service"
        - name: FLUENTD_SYSTEMD_KUBELET_SERVICE
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
