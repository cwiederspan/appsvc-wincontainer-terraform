# Development Container Template

This project can be used as a template for other, new GitHub projects where you would
like to use [this Docker image](https://github.com/ateamsw/devcontainer) as the dev
container in your VS Code projects.

## Execution

```bash

az acr import -n cdwms --source mcr.microsoft.com/dotnet/framework/samples:aspnetapp


terraform apply -auto-approve -var 'docker_username=cdwms' -var 'docker_password=XXX'

```
