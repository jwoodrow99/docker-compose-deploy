# Docker Compose Deploy

Docker Compose Deploy allows you to easily use docker as both a development environment and deployment environment. This configuration can be deployed to a VPS with only SSH and Docker installed on the VPS itself, Docker Compose Deploy will handle the rest.

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

## Obtaining SSL certificates

``` bash
docker exec -i docker-compose-deploy-base-1 certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d example.org
docker exec -i docker-compose-deploy-base-1 certbot certonly --webroot --webroot-path /var/www/certbot/ -d example.org
docker exec -i docker-compose-deploy-base-1 certbot renew
```

## Update container with no downtime

``` bash
# Scale up php to two containers and reload Nginx
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale nginx=2 --no-recreate nginx
docker exec docker-compose-deploy-nginx-1 nginx -s reload

# Scale down to single container removing old and reload Nginx again
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale nginx=1 --no-recreate nginx
docker exec docker-compose-deploy-nginx-1 nginx -s reload
```
