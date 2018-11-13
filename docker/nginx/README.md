# Nginx Docker Image 

## Dockerize:
  
  The Docker Image is equipped with
  [Dockerize](https://github.com/jwilder/dockerize "Utility to simplify running applications in docker containers."),
  it is responsible for generating the conguration.
   
  If you want to update the Dockerize, you should update the version in the environment variable in the Dockerize file.

## Environment variables:
  
  You can declare environment variables in the file `docker-compose.yml` e.g.
  ```yaml
  webserver:
    environment:
      RESOLVER_ADDRESS: 127.0.0.11
      NGINX_UPSTREAM_ENDPOINT: application:9000
  ```
  
  List of environment variables:
  
  * `RESOLVER_ADDRESS` - Address resolver, defulat `127.0.0.11`
  * `RESOLVER_TIME` - The validity time resolver, defulat: `3s`
  * `NGINX_UPSTREAM_ENDPOINT` - Address and port of the service with the application, defulat `application:9000`
  * `CLIENT_MAX_BODY_SIZE` - The maximum size of the sent request, defulat `250M`
  
