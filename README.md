# DEPRECATED

This project is **obsolete** and no longer maintained. Refer to https://kubernetes.io/docs/home/ for kubernetes logging configuration.

## Kubernetes Fluentd (Elasticsearch)

Alternative fluentd docker image designed as a drop-in replacement for the fluentd-es-image in the fluentd-elasticsearch cluster-level logging addon. This image provides support for shipping journald logs for docker and kubelet since these services are often managed by systemd.

**Components**

| Component | Version |
| --------- | ------- |
| fluentd | 1.2.4 |

**Configuration**

Uses [ReDACT](https://github.com/emacski/redact) for fluentd configuration.

| Environment Variable | Description |
| -------------------- | ----------- |
| `fluentd_es_host` | The elasticsearch host to connect to (Default: `elasticsearch-logging`) |
| `fluentd_es_port` | The elasticsearch API port (Default: `9200`) |
| `fluentd_use_journald` | Use journald for retrieving top level service logs like docker and kubelet (Default: empty) |

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
        - name: fluentd_has_systemd
          value: "yes"
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
