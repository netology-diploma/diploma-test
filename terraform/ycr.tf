resource "yandex_container_registry" "app-images" {
  name      = "app-images-${var.environment}"
  folder_id = var.folder_id

  labels = {
    my-label = "diploma-${var.environment}-registry"
  }
}
