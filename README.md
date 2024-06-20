## Дипломный практикум в Yandex.Cloud  
### 1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.  
- Сервисный аккаунт создается в файле [sa-rbac-keys.tf](terraform/sa-rbac-keys.tf), там же ему назначаются рекомендованные роли и создается симметричный ключ для шифрования ресурсов.  
- Бэкенд для Terraform подготовил в Terraform Cloud. Описан в файле [provider.tf](terraform/provider.tf), там же указаны переменные с секретами для доступа к облаку. Сами секреты сохранены в безопасных переменных Terraform Cloud.  
- VPC с подсетями во всех зонах доступности создаются в [network.tf](terraform/network.tf), там же группы безопасности для кластера, шлюз и правило NAT для доступа группы узлов в Интернет.  
- В pull-request еще до слияния с веткой main по которой настроен запуск Run в Terraform Cloud сразу можно просмотреть plan и подправить ошибки.  
![not done :(](img/diploma_01.png)  
- Если все проверки прошли успешно, "мержим" в main.  
![complete](img/diploma_02.png)  
- Результат - запуск Run в Terraform Cloud и создание объектов в Yandex Cloud.  
![plan applied](img/diploma_03.png)  
![infra created](img/diploma_04.png)  

### 2. Запустить и сконфигурировать Kubernetes кластер.  
Выбрал второй вариант: сервис Yandex Managed Service for Kubernetes и группа узлов.
- Региональный кластер создается в файле [cluster.tf](terraform/cluster.tf). Использует сервис-аккаунт созданный ранее.    
- После создания и инициализации файла конфига для подключения ```kubectl get pods -A``` отрабатывает без ошибок.  
![k8s done](img/diploma_05.png)  

### 3. Тут всё идёт не по плану. Запуск CD системы, основных контроллеров и мониторинга вместе с инициализацией кластера.  
В качестве CD системы было интересно попробовать FluxCD.  
Инициализация FluxCD происходит в следующих файлах:
- [provider.tf](terraform/provider.tf). Объявление необходимых провайдеров и их подключение к кластеру. Переменные "спрятаны" в Terraform Cloud.  
- [flux.tf](terraform/flux.tf). Создание deploy-key для работы с репозиторием и собственно инициализация репозитория.  
Тут я долгое время пытался сделать всё в одном репозитории, том же где находится этот README.md, уже добился запуска основных контроллеров (ingress-nginx, external-dns, cert-manager, sealed-secrets), но надолго застрял на интеграции мониторинга. Поэтому взял [форк манифестов и конфигов для мониторинга Flux от создателей](https://github.com/fluxcd/flux2-monitoring-example), инициализировал и продолжил работать в отдельном [репозитории](https://github.com/netology-diploma/diploma-test-app).  
Сразу после запуска (был установлен сам flux в одноименный namespace и инструменты мониторинга: kube-prometheus-stack, loki-stack, включена grafana (с паролем в открытом виде, да, его предстоит спрятать в сгенерированный секрет).  
Затем добавил cert-manager, external-dns, ingress-nginx и sealed-secrets для хранения API-токена панели управления Cloudflare где находится мой домен tasenko.ru. Всё это в папке [infrastructure](https://github.com/netology-diploma/diploma-test-app/tree/main/infrastructure/controllers), kustomization файл [здесь](https://github.com/netology-diploma/diploma-test-app/blob/main/clusters/test/controllers.yaml).  
К сожалению, не нашел простого и надежного способа спрятать секрет (API-токен Cloudflare) в переменных Terraform Cloud или GitHub и корректно передать его в манифест. Поэтому создание токена требует ручного запуска команд для специально подготовленного файла секрета:
```kubeseal -f .\_unencrypted_cloudflare-api-token.yaml -w cloudflare-api-token.yaml --controller-namespace sealed-secrets --controller-name sealed-secrets```
```k apply -f .\cloudflare-api-token.yaml```
Следующим шагом применяю манифест [ClusterIssuer](https://github.com/netology-diploma/diploma-test-app/tree/main/infrastructure/issuers) и [кастомизацию](https://github.com/netology-diploma/diploma-test-app/blob/main/clusters/test/issuers.yaml), модифицирую файл релиза [kube-prometheus-stack](https://github.com/netology-diploma/diploma-test-app/blob/main/monitoring/controllers/kube-prometheus-stack/release.yaml) добавив туда блок Ingress для Grafana. Спустя некоторое время Grafana отвечает по адресу https://grafana.tasenko.ru/ с доверенным сертификатом.  
![cluster-stats](img/diploma_06.png)  
![control-plane](img/diploma_07.png)  
Добавил еще щепотку зависимостей и теперь вся инфраструктура и готовый кластер стартуют по одному коммиту или ручному запуску ```terraform apply```. Развертывание external-dns стопорится из-за отсутствия секрета. После создания и применения секрета (и ручного удаления релиза для ускорения процесса) Flux применяет кастомизации заново и инфраструктура готова.  

### 4. Подготовка и деплой тестового приложения, сборка образа при помощи GitHub Actions.  
В качестве тестового приложения взял fork JavaScript приложения с которым я уже когда-то работал - [Flatris](https://github.com/atasenko/flatris).
Собрал [Dockerfile](https://github.com/netology-diploma/diploma-test-app/blob/main/apps/flatris/Dockerfile), проверил запуском локально ~~завис минут на 10 в игре~~.  
Перенес к себе в репозиторий в папку [apps/flatris](https://github.com/netology-diploma/diploma-test-app/tree/main/apps/flatris).  
Создал Yandex Container Registry в файле [ycr.tf](terraform/ycr.tf), получил отдельный ключ для сервис-аккаунта командой ```yc iam key create --service-account-name cluster-sa -o key.json```, добавил его в качестве секрета YC_SA_JSON_CREDENTIALS в репозиторий GitHub.  
Создал [workflow](https://github.com/netology-diploma/diploma-test-app/blob/main/.github/workflows/image-publish.yml) для сборки и публикации образов. После тестов оставил сборку только по пушу в main и semver тегам.  


Тут будет создание Dockerfile приложения, сборка образа, HelmRelease, публикация в registry и деплой. 
