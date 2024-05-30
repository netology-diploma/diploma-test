resource "yandex_iam_service_account" "cluster-sa" {
 name      = "cluster-sa-${var.environment}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
 folder_id = var.folder_id
 role      = "editor"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "load-balancer-admin" {
 folder_id = var.folder_id
 role      = "load-balancer.admin"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
 folder_id = var.folder_id
 role      = "k8s.clusters.agent"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-cluster-api-editor" {
 folder_id = var.folder_id
 role      = "k8s.cluster-api.editor"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
 folder_id = var.folder_id
 role      = "vpc.publicAdmin"
 member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key-${var.environment}"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 1 год.
}
