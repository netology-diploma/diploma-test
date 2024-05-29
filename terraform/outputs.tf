output "k8s_ca_certificate" {
  value     = yandex_kubernetes_cluster.diploma.master[0].cluster_ca_certificate
  sensitive = true
}

output "endpoint" {
  value     = yandex_kubernetes_cluster.diploma.master[0].external_v4_endpoint
  sensitive = true
}
