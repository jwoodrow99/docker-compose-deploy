# Docker Compose Deploy

Docker Compose Deploy contains both a development and production environment which reflect one another. This allows for you to use the same configuration for both local development and deployment. We substitute specific services between the both environments as well as alter specific ports to prevent confusion. However the true power of Docker Compose Deploy is its ability to provision an entire VPS with only installing an SSH server (Which is installed by default on every VPS) and docker on the host machine. All running services are managed by comose and exposing volumes for persistent storage and configuration. Out of the box we have configured Nginx, certbot SSL configuration and automatic renewal, full blow email server.

## Development

The development environment uses a dedicated compose fine and substitutes specific container images as well as exposed ports. This project out of the box offerers configurations.

### Start

``` bash
docker-compose -f docker-compose.dev.yml up -d --build
docker-compose -f docker-compose.dev.yml down
```

## Production

The production environment requires some configuration, but is largely automated and is fully done using docker and its containers.

### Start

``` bash
docker-compose -f docker-compose.prod.yml up -d --build
docker-compose -f docker-compose.prod.yml down
```

### Configure Nginx and SSL

You first step will be to create an A record for your domain pointing to the server IP address.

``` bash
# Generate SSL certificate for your domain Via certbot. Add ```--dry-run``` to the end of the command to test first.
docker exec -i docker-compose-deploy_base_1 certbot certonly --webroot --webroot-path /var/certbot/ -d <domain>

# Replace existing Nginx conf with conf specifically for SSL redirects
rm -f ./docker/config/nginx/conf.d/base.conf
cp ./docker/config/nginx/conf.d/base.ssl.conf.example ./docker/config/nginx/conf.d/base.conf

# Refresh Nginx with zero downtime
docker exec docker-compose-deploy_nginx_1 nginx -s reload
```

### Configure MailServer

You will first need to add the following DNS Records to your nameserver.

| Type | Name |     Content     |
|:----:|:----:|:---------------:|
|   A  | mail | ServerIP        |
|  MX  | @    | mail.\<domain>  |
|  TXT | @    | v=spf1 mx ~all  |

``` bash
# Generate SSL certificate for mail domain Via certbot. Add ```--dry-run``` to the end of the command to test first.
docker exec -i docker-compose-deploy_base_1 certbot certonly --webroot --webroot-path /var/certbot/ -d mail.<domain>

# Create postmaster account, other accounts can be added in the same way.
docker exec -ti docker-compose-deploy_mailserver_1 setup email add <user@domain> <password>

# Generate DKIM key and record
docker exec -ti docker-compose-deploy_mailserver_1 setup config dkim

# Display generated DKIM record.
cat ./docker/volumes/mailserver/config/opendkim/keys/<domain>/mail.txt
```

Finally you will need to add one more record to your nameserver with the output of the final command in the following format:

| Type |       Name      |                       Content                      |
|:----:|:---------------:|:--------------------------------------------------:|
|  TXT | mail._domainkey | v=\<value>;  h=\<value>;  k=\<value>;  p=\<value>; |

You can now use an email client to connect to your mail server with the following:

**Incomming IMAP**
|    Key   |      Value     |
|:--------:|:--------------:|
| Hostname | mail.\<domain> |
| Port     | 143            |
| Security | STARTTLS       |

**Outgoing**
|    Key   |      Value     |
|:--------:|:--------------:|
| Hostname | mail.\<domain> |
| Port     | 587            |
| Security | STARTTLS       |

## Update Strategy

We will use docker-comose to create a duplicate of the outdated container, proceed to update it, move traffic over from nginx to the new container and take down the outdated container. This is a theoretical zero downtime approach, but may result in some dropped connections. However this will keep any downtime to a minimum. Below is an example...

``` bash
# Scale up php to two containers and reload Nginx, traffic should move the the newest container upon reload
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale php=2 --no-recreate php
docker exec docker-compose-deploy_nginx_1 nginx -s reload

# Scale down to single container, the newest container will remain and the older will be removed.
docker-compose -f docker-compose.prod.yml up -d --no-deps --scale php=1 --no-recreate php
docker exec docker-compose-deploy_nginx_1 nginx -s reload
```

## Application Configs

By default we have only Nginx enabled, serving a static html file. Other services can be enabled with very minimal configuration changes. Most basic configurations are built and simply require to be enabled by uncommenting. All of our application containers are routed through Nginx, thus we have separate Nginx .conf files for each application container. Below we outline the process of how to enable different application level containers.

### WordPress

1. In the docker-compose file only the nginx, wordpress and mysql containers should be enabled.
2. The WordPress volume will need to be mounted to Nginx ```./docker/volumes/wordpress/data:/var/www/html```.
3. The ```base.conf``` fine needs to be removed or commented out and the ```wordpress.conf``` file must be enabled.

### PHP

1. In the docker-compose file only the nginx, wordpress and mysql containers should be enabled.
2. The WordPress volume will need to be mounted to Nginx ```./docker/config/nginx/sites/php:/var/www/php```.
3. The ```base.conf``` fine needs to be removed or commented out and the ```php.conf``` file must be enabled.

### Node

### Python

### Ruby
