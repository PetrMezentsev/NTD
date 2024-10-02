# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
![изображение](https://github.com/user-attachments/assets/12f272dc-af05-467b-b537-d5eb82e5c988)  

![изображение](https://github.com/user-attachments/assets/5c6f0548-ee22-4493-9fe6-f247f79e545f)

5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.  
![изображение](https://github.com/user-attachments/assets/2efb584c-d6f5-489c-b1ef-aaae03cf5acd)  

![изображение](https://github.com/user-attachments/assets/ebff4a98-24d0-4948-ae76-3c414553c3a9)



---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
![изображение](https://github.com/user-attachments/assets/4afe13d5-9ba7-4d56-a06a-fac58ee7ad96)  
![изображение](https://github.com/user-attachments/assets/c3aed3d6-75c0-4d3b-808c-7f1436f839cc)  
![изображение](https://github.com/user-attachments/assets/017bf520-8b4f-4194-8c5e-7bf8b85e228f)

2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.    

[Репозиторий с тестовым приложением](https://gitlab.com/MPVJ/app-for-ntd)  

2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.    

[Регистри](https://hub.docker.com/repository/docker/mpvj/test-nginx-app/general)

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.  

[Deployment](https://github.com/PetrMezentsev/NTD/tree/main/deployment)

2. Http доступ к web интерфейсу grafana.  

Для входа в систему мониторинга 

admin  
Uarabey

[Web-интерфейс grafana](http://84.201.171.9/d/3138fa155d5915769fbded898ac09fd9/kubernetes-kubelet?orgId=1&refresh=10s)

3. Дашборды в grafana отображающие состояние Kubernetes кластера.  

![изображение](https://github.com/user-attachments/assets/69c37df3-aa70-4758-8da5-434a91855f75)  

![изображение](https://github.com/user-attachments/assets/cc07b1c6-bff2-4b23-a603-5654d07e2920)


4. Http доступ к тестовому приложению.  

[Тестовое приложение](http://84.201.146.35/)  

![изображение](https://github.com/user-attachments/assets/acf2057d-273f-4f1b-9e33-8a47c5c6a027)


---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.  

[ci/cd сервис](https://gitlab.com/MPVJ/app-for-ntd/-/pipelines)  


2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.  

[Задача сборки](https://gitlab.com/MPVJ/app-for-ntd/-/jobs/7971177881)

![изображение](https://github.com/user-attachments/assets/fb9890cf-b280-4310-a4dd-f668a0ce7f5c)

[Собранный образ в регистри](https://hub.docker.com/layers/mpvj/test-nginx-app/1d90d4ca/images/sha256-02b17d20550587e4cb1030f4fd26420e085edcba2b690a233ec20a8e754d77b7?context=repo)

![изображение](https://github.com/user-attachments/assets/1b299fe2-52d0-4e37-bc46-70ae65920637)



3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.  

[Задача сборки и деплоя](https://gitlab.com/MPVJ/app-for-ntd/-/jobs/7971217074)  

![изображение](https://github.com/user-attachments/assets/e281f591-3105-4058-ad46-5a46f8d3966b)  

[Собранный образ с тегом в регистри](https://hub.docker.com/layers/mpvj/test-nginx-app/v2.0.1/images/sha256-02b17d20550587e4cb1030f4fd26420e085edcba2b690a233ec20a8e754d77b7?context=repo)  

![изображение](https://github.com/user-attachments/assets/f984745a-711c-49ef-881d-ac98b982a53f)


Deployment обновлён

![изображение](https://github.com/user-attachments/assets/5505ecca-eeeb-446a-8a52-a78c665eec78)


---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.  

[Bucket](https://github.com/PetrMezentsev/NTD/tree/main/s3)

[Terraform](https://github.com/PetrMezentsev/NTD/tree/main/terraform)

2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.  

![изображение](https://github.com/user-attachments/assets/5d8b3f41-a177-46b7-b7c6-da48d9dd842f)

3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.  

[Репозиторий с тестовым приложением](https://gitlab.com/MPVJ/app-for-ntd)  

[Регистри](https://hub.docker.com/repository/docker/mpvj/test-nginx-app/general)

5. Репозиторий с конфигурацией Kubernetes кластера.  

[Deployment](https://github.com/PetrMezentsev/NTD/tree/main/deployment)

6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.  

Для входа в систему мониторинга 


[Тестовое приложение](http://84.201.146.35/)


[Web-интерфейс grafana](http://84.201.171.9/d/3138fa155d5915769fbded898ac09fd9/kubernetes-kubelet?orgId=1&refresh=10s)  

admin  
Uarabey

7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

