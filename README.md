# About

- Docker image for creating an insecure `nginx` web server for the purpose of testing the
  [SSLTest](https://github.com/SamoKopecky/SSLTest) tool

# Getting started

- Run `docker-compose up -d` to create a docker image and run the image in a new container
- Variables `OPENSSL_VER` and `NGINX_VER` can be set in the `docker-compose.yml` file to change the compiled
  `openssl` or `nginx` versions respectively
- Supported SSL/TLS protocols or cipher suites can be configured in the `nginx.conf` configuration file by changing the
fields `ssl_protocols` and `ssl_ciphers`
