docker compose up -d --remove-orphans

docker run --network=dataflow_compose_storage -v $PWD:/terraform --workdir /terraform/infrastructure hashicorp/terraform:latest init
docker run --network=dataflow_compose_storage -v $PWD:/terraform --workdir /terraform/infrastructure hashicorp/terraform:latest apply -auto-approve
