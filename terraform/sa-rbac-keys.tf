resource "yandex_iam_service_account" "cluster-sa" {
 name      = "cluster-sa-${var.environment}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-roles" {
  for_each  = var.k8s_sa_roles
  role      = each.value
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.cluster-sa.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key-${var.environment}"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 1 год.
}
