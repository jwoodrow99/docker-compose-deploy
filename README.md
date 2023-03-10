# Docker Compose Deploy

This repository contains a docker compose configuration that is used as both a development environment as well as deployment environment. The aim of this configuration is to deploy an entire application to a bare VPS with as minimal steps as possible. Docker will do most of the heavy lifting for us, with minimal configuration required.

## Start development environment

``` bash
docker-compose -f docker-compose.dev.yml up -d --build
docker-compose -f docker-compose.dev.yml down
```

## Start production environment

``` bash
docker-compose -f docker-compose.prod.yml up -d --build
docker-compose -f docker-compose.prod.yml down
```
