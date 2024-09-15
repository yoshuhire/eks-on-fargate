## Kubernetes 環境構築手順

- [Kubernetes 環境構築手順](#kubernetes-環境構築手順)
- [概要](#概要)
  - [インフラ環境について(`infra`)](#インフラ環境についてinfra)
  - [Webサーバーについて(`app`)](#webサーバーについてapp)
  - [マニフェストについて(`manifest`)](#マニフェストについてmanifest)
- [事前準備](#事前準備)
- [環境構築手順](#環境構築手順)
  - [◻︎ 1. infra リソース作成(作業ディレクトリ: `infra`)](#︎-1-infra-リソース作成作業ディレクトリ-infra)
  - [◻︎ 2. Webサーバー用コンテナイメージ作成・ECRプライベートリポジトリにPush(作業ディレクトリ: `app`)](#︎-2-webサーバー用コンテナイメージ作成ecrプライベートリポジトリにpush作業ディレクトリ-app)
  - [◻︎ 3. Webサーバーデプロイ(作業ディレクトリ: `manifest`)](#︎-3-webサーバーデプロイ作業ディレクトリ-manifest)
- [Info](#info)
  - [EKS on Fargate でのノードリソースの指定について](#eks-on-fargate-でのノードリソースの指定について)
  - [ランニングコスト](#ランニングコスト)
  - [ノード移行](#ノード移行)

## 概要

Kubernetes にシンプルなWebサーバー(python)を構築するためのコードと手順を記載したリポジトリです。<br>
ディレクトリ構成は以下です。

```
.
├── app               ### Webサーバー用アプリコードとDockerfileが格納されているディレクトリ
│   ├── Dockerfile
│   └── app.py
├── infra             ### インフラ環境構築用ファイル格納ディレクトリ
│   ├── _variable.tf
│   ├── _version.tf
│   ├── main.tf
│   └── modules
│       └── eks
├── manifest          ### マニフェストファイル格納ディレクトリ
└── READEME.md

```

### インフラ環境について(`infra`)

- IaCツールであるTerraformを利用しAWS 上に構築します。事前にAWSアカウントのご用意をお願いします。
- Kubernetes は AWS のマネージドサービスである EKS を利用します。
- Kubernetes のデータプレーンはノード管理の負担を軽減するため fargateを採用しております。
- インフラ構成図とカスタム可能な設定については [EKSモジュールのREADME.md](./infra/modules/eks/README.md)をご確認ください。

### Webサーバーについて(`app`)

- HTTP リクエスト時に`ENV`環境変数の値を返すシンプルなWebサーバーです。
- PythonのWebアプリケーションフレームワークであるFlaskを利用します。
- `Dockerfile`を利用しコンテナイメージをビルドし`infra`で作成したECRにPushします。

### マニフェストについて(`manifest`)

- development・production毎に各環境用のマニフェストファイルを用意しています。内容は以下です。
  - `namespace.yml`: Webサーバー用Podおよびサービスが所属する名前空間を定義
  - `deployment.yml`: Webサーバー用Podの実行数、スケーリング設定を定義
  - `service.yml`: Webサーバー用PodのClusterIPを定義
  - `ingress.yml`: Webサーバー用Podのフロントエンド（ALB）を定義
  - `hpa.yml`: 水平Podスケーリングを定義

## 事前準備

環境構築のために以下のセットアップが必要です。

- AWS アカウント:
  - 環境構築用のAWSアカウントをご用意ください。
- IAMユーザーの作成: 
  - AWSリソース作成操作の実行のため、`AdministratorAccess` 権限が付与されたIAMユーザーを作成してください
  - アクセスキーを発行し、`アクセスキーID`と`シークレットアクセスキー`をメモしておいてください
- コマンドのインストール: 以下環境構築に必要なコマンドです。
  - `aws cli` コマンド:
    - 参考: [awsコマンドのインストール手順](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html)
  - `terraform` コマンドのインストール(`バージョン:1.9.5以上`):
    - 参考: [tfenvコマンドのインストール手順](https://github.com/tfutils/tfenv?tab=readme-ov-file#tfenv)
  - `kubectl` コマンドのインストール:
    - 参考: [kubectlインストール手順](https://kubernetes.io/ja/docs/tasks/tools/#kubectl)
  - `docker` コマンドのインストール:
    - 参考:
      - [dockerインストール手順(Windows)](https://docs.docker.jp/v1.12/windows/step_one.html)
      - [dockerインストール手順(MacOSX)](https://docs.docker.jp/v1.12/mac/index.html#mac-os-x)
      - [dockerインストール手順(Linux)](https://docs.docker.jp/engine/installation/linux/index.html#docker-engine-linux)

## 環境構築手順

操作端末のターミナルアプリを起動し、以下の手順で環境構築を実施します。<br>


- 1. infra リソース作成(作業ディレクトリ: `infra`)
- 2. Webサーバー用コンテナイメージ作成・ECRプライベートリポジトリにPush(作業ディレクトリ: `app`)
- 3. Webサーバーデプロイ(作業ディレクトリ: `manifest`)


### ◻︎ 1. infra リソース作成(作業ディレクトリ: `infra`)

<details>
<summary>手順</summary>

> [!NOTE]
> 初期構築の場合は全リソース作成完了までに約20 ~ 25分ほどかかります。

```
# 1. AWSリソース作成操作用IAMユーザーのアクセスキー登録

aws configure

### ダイアログ出力画面
## AWS Access Key ID: 事前準備にてメモした`アクセスキーID`を入力
## AWS Secret Access Key: 事前準備にてメモした`シークレットアクセスキー`を入力
## Default region name: `ap-northeast-1`を入力
## Default output format: `json`を入力

# 1. 確認コマンド (事前準備で作成したIAMユーザーの資格情報が利用できていること)

aws sts get-caller-identity

### 標準出力画面
## {
##     "UserId": "XXXXXXXXXXXXX",
##     "Account": "<AWS アカウントID>",
##     "Arn": "arn:aws:iam::<AWS アカウントID>:user/<IAMユーザー名>"
## }
###

# 2. 環境変数登録
## development用EKSクラスター環境を作成する場合

export TF_VAR_env=dev

## production用EKSクラスター環境を作成する場合

export TF_VAR_env=prd

# 2. 確認コマンド (env 環境変数が登録されていること)

echo $TF_VAR_env

# 3. infra リソース作成

## 作業ディレクトリへ移動

cd infra

# 初期構築の場合

## terraform ディレクトリ初期化

terraform init

## ワークスペースの指定(dev or prd)
terraform workspace new $TF_VAR_env

## リソース作成
terraform apply -auto-approve
cd ../

# 環境更新の場合

## terraform ディレクトリ初期化

terraform init

## ワークスペースの指定(dev or prd)
terraform workspace select $TF_VAR_env

## リソース更新内容の確認
terraform plan

## リソース更新
terraform apply -auto-approve

## リソース作成後に 後続のmanifest 作成手順で必要となる「ALB用のセキュリティグループID」がOutput値として標準出力画面に表示されるためコピーしておく

### 標準出力画面
##
## Outputs:
##
## alb_sg_id = "sg-xxxxxxxxxxx"
###

## 作業ディレクトリから移動
cd ../

```

</details>

### ◻︎ 2. Webサーバー用コンテナイメージ作成・ECRプライベートリポジトリにPush(作業ディレクトリ: `app`)

<details>
<summary>手順</summary>


```
# 1. kubeconfig の更新
aws eks update-kubeconfig --name eks-cluster-${TF_VAR_env}

# 1. 確認コマンド (対象のEKSクラスターがkube API呼び出し先として指定されていること)

kubectl config current-context

### 標準出力画面
## arn:aws:eks:ap-northeast-1:<AWSアカウントID>:cluster/eks-cluster-<dev/prd>
###

# 2. 環境変数登録

## AWS Account ID
export AWS_ACCOUNT_ID=(`aws sts get-caller-identity --query Account --output text`)

## ECRリポジトリ名
export REPO_NAME=${TF_VAR_env}/web-server

## イメージタグ
export IMAGE_TAG=v1.0.0

# 2. 確認コマンド (各環境変数が登録されていること)

echo $AWS_ACCOUNT_ID
echo $REPO_NAME
echo $IMAGE_TAG

# 3. 作業ディレクトリへ移動
cd app

# 4. docker login、build、ECRへのイメージプッシュ

## docker login
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

## docker build
docker build --platform linux/amd64 -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPO_NAME}:${IMAGE_TAG} .

## docker push
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}

# 4. 確認コマンド(イメージタグがECRリポジトリに格納されていること)

aws ecr list-images --repository-name ${REPO_NAME}

### 標準出力画面
## {
##   "imageIds": [
##       {
##         "imageDigest": "sha256:xxxxxxxxxxx",
##         "imageTag": "<IMAGE_TAG>"
##       }
##   ]
## }
###

## 作業ディレクトリから移動
cd ../

```

</details>

### ◻︎ 3. Webサーバーデプロイ(作業ディレクトリ: `manifest`)

<details>
<summary>手順</summary>

```
# 1. 作業ディレクトリに移動
cd manifest/<development or production>

# 2. deployment.yml の修正

## deployment.yml内の<AWS ACCOUNT ID>を対象AWSアカウントIDに変更します。

# 3. ingress.yml の修正

## ingress.yml内の<Security Group ID>をTerraformで作成した「ALB用のセキュリティグループID」の値に変更します。

# 4. Web サーバー用Namespaceを作成

kubectl apply -f namespace.yml

# 5. Web サーバー用Deploymentを作成

kubectl apply -f deployment.yml

# 6. Web サーバー用serviceを作成

kubectl apply -f service.yml

# 7. Web サーバー用ingressを作成

kubectl apply -f ingress.yml

# 8. 確認コマンド

kubectl get ns web-server            ## Namespace
kubectl get deployment -n web-server ## Deployment
kubectl get svc -n web-server        ## Service
kubectl get ingress -n web-server    ## Ingress
```

</details>


## Info

### EKS on Fargate でのノードリソースの指定について

<details>
<summary>説明</summary>

EKS on Fargate ではノードのリソース(CPU, Memory)を直接指定することはできませんが、<br>
deployment または pod のマニフェスト内で指定できます。<br>
Fargate では、以下のような CPU とメモリの組み合わせを選択できます。

| CPU (vCPU) | メモリ (GB) |
|------------|------------|
| 0.25 | 0.5, 1, 2 |
| 0.5 | 1 ~ 4 (1GB のインクレメント)|
| 1 | 2 ~ 8 (1GB のインクレメント)|
| 2 | 4 ~ 16 (1GB のインクレメント)|
| 4 | 8 ～ 30 (1 GB のインクリメント)|
| 8 | 16 ～ 60 (4 GB のインクリメント)|
| 16 | 32 ～ 120 (8 GB のインクリメント)|

- Pod マニフェストでのリソース指定例

```
apiVersion: v1
kind: Pod
metadata:
  name: fargate-pod
  namespace: fargate-namespace
spec:
  containers:
    - name: my-container
      image: nginx
      resources:
        requests:
          memory: "1Gi"     # Pod が要求するメモリ
          cpu: "0.25"       # Pod が要求する CPU
        limits:
          memory: "2Gi"     # メモリの上限
          cpu: "0.5"        # CPU の上限
```

</details>

### ランニングコスト

<details>
<summary>infracost</summary>

`infracost` ツールを利用して本環境をAWS上で作成した際にかかる固定費を算出しております。<br>
なお、データ通信量等従量課金分については算出しておりませんためあくまで目安となります。

```
Project: main

 Name                                                                                  Monthly Qty  Unit              Monthly Cost   
                                                                                                                                     
 module.eks.aws_eks_cluster.this                                                                                                     
 └─ EKS cluster                                                                                730  hours                   $73.00   
                                                                                                                                     
 module.eks.aws_eks_fargate_profile.this["default"]                                                                                  
 ├─ Per GB per hour                                                                              1  GB                       $4.04   
 └─ Per vCPU per hour                                                                            1  CPU                     $36.91   
                                                                                                                                     
 module.eks.aws_eks_fargate_profile.this["web-server"]                                                                               
 ├─ Per GB per hour                                                                              1  GB                       $4.04   
 └─ Per vCPU per hour                                                                            1  CPU                     $36.91   
                                                                                                                                     
 module.eks.aws_vpc_endpoint.this["ec2"]                                                                                             
 ├─ Data processed (first 1PB)                                                      Monthly cost depends on usage: $0.01 per GB      
 └─ Endpoint (Interface)                                                                     2,190  hours                   $30.66   
                                                                                                                                     
 module.eks.aws_vpc_endpoint.this["ecr.api"]                                                                                         
 ├─ Data processed (first 1PB)                                                      Monthly cost depends on usage: $0.01 per GB      
 └─ Endpoint (Interface)                                                                     2,190  hours                   $30.66   
                                                                                                                                     
 module.eks.aws_vpc_endpoint.this["ecr.dkr"]                                                                                         
 ├─ Data processed (first 1PB)                                                      Monthly cost depends on usage: $0.01 per GB      
 └─ Endpoint (Interface)                                                                     2,190  hours                   $30.66   
                                                                                                                                     
 module.eks.aws_vpc_endpoint.this["elasticloadbalancing"]                                                                            
 ├─ Data processed (first 1PB)                                                      Monthly cost depends on usage: $0.01 per GB      
 └─ Endpoint (Interface)                                                                     2,190  hours                   $30.66   
                                                                                                                                     
 module.eks.aws_vpc_endpoint.this["sts"]                                                                                             
 ├─ Data processed (first 1PB)                                                      Monthly cost depends on usage: $0.01 per GB      
 └─ Endpoint (Interface)                                                                     2,190  hours                   $30.66   
                                                                                                                                     
 module.eks.aws_cloudwatch_log_group.cluster                                                                                         
 ├─ Data ingested                                                                   Monthly cost depends on usage: $0.76 per GB      
 ├─ Archival Storage                                                                Monthly cost depends on usage: $0.033 per GB     
 └─ Insights queries data scanned                                                   Monthly cost depends on usage: $0.0076 per GB    
                                                                                                                                     
 module.eks.aws_ecr_repository.this["ecr-public/eks/aws-load-balancer-controller"]                                                   
 └─ Storage                                                                         Monthly cost depends on usage: $0.10 per GB      
                                                                                                                                     
 module.eks.aws_ecr_repository.this["k8s/autoscaling/addon-resizer"]                                                                 
 └─ Storage                                                                         Monthly cost depends on usage: $0.10 per GB      
                                                                                                                                     
 module.eks.aws_ecr_repository.this["k8s/metrics-server/metrics-server"]                                                             
 └─ Storage                                                                         Monthly cost depends on usage: $0.10 per GB      
                                                                                                                                     
 module.eks.aws_ecr_repository.this["web-server"]                                                                                    
 └─ Storage                                                                         Monthly cost depends on usage: $0.10 per GB      
                                                                                                                                     
 OVERALL TOTAL                                                                                                            $308.19 

*Usage costs can be estimated by updating Infracost Cloud settings, see docs for other options.

──────────────────────────────────
57 cloud resources were detected:
∙ 13 were estimated
∙ 44 were free

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━┓
┃ Project                                            ┃ Baseline cost ┃ Usage cost* ┃ Total cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━╋━━━━━━━━━━━━┫
┃ main                                               ┃          $308 ┃           - ┃       $308 ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━┻━━━━━━━━━━━━┛
```




</details>

### ノード移行

<details>
<summary>ノード移行</summary>

ノードをユーザー管理しているk8sでは、起動中のPodのノードを移行する場合、<br>
以下の手順でノード移行を実施します。

- 1. 移行対象 pod が起動している ノードを確認(`kubectl get pod <pod-name> -n <namespace> -o wide`)
- 2. 移行前のノードにて Pod のスケジュール無効化・ Pod を他のノードへの退避(`kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data`)
  - Pod が一つしか起動していない場合は、サービスの完全停止を防止するため、事前に`replica`を増やしておく必要があります
- 3. ノードを他の Pod のスケジューリング対象に戻す(`kubectl uncordon <node-name>`)

EKS on Fargate では ノードをユーザー側で管理することが不要であるため、`kubectl drain` コマンド実行後に対象ノード自体がPodを起動するノードから除外されます。<br>
Pod が起動するノードを変更するためには以下コマンドを実行します。

`kubectl rollout restart deployment <deployment-name> -n <namespace>` <br>

</details>
