## 📊 Observability (Prometheus + Grafana + Loki via Helm)

This project uses a production-ready observability stack deployed with Helm:

- **Prometheus** – collects metrics from Kubernetes and application pods  
- **Grafana** – dashboards and visualizations  
- **Loki + Promtail** – centralized application logs (lightweight alternative to ELK)

Helm is used to ensure easy upgrades, rollback support, and consistent deployments across environments.

---

### 🛠 Install Helm Charts

#### Create the namespace

```bash
kubectl apply -f namespace.yaml
```
### Add Helm repositories
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo add grafana https://grafana.github.io/helm-charts

helm repo update
```

### 📈 Deploy Prometheus (Metrics)
```
helm install prometheus prometheus-community/prometheus \
  -n observability \
  -f kubernetes/observability/values-prometheus.yaml
```

Prometheus automatically discovers Kubernetes services and starts scraping metrics.

### 📊 Deploy Grafana (Dashboards)
```
helm install grafana grafana/grafana \
  -n observability \
  -f kubernetes/observability/values-grafana.yaml
```

## Get Grafana admin password:

```
kubectl get secret grafana -n observability -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Get external URL:
```
kubectl get svc -n observability
```
### 📜 Deploy Loki + Promtail (Logs)
```
helm install loki grafana/loki-stack \
  -n observability \
  -f kubernetes/observability/values-loki.yaml
```

Promtail automatically ships pod logs to Loki. Grafana visualizes them using the Loki data source.
