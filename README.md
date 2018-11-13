#  Financial Control TRL
Micro services responsible for work with transactions

### Minimum software requirements:
 * Make 4.1
 * Docker 1.12
 * Docker Compose >= 1.22 - https://docs.docker.com/compose/install/

### Ubuntu 18.4 (support VPN) environment configuration

#### Configuration:
 1. Installing dnsmasq - service start error can appear due to occupied port 53 on the address 127.0.0.53:
    `sudo apt-get install dnsmasq`

 2. Redirect domain `lo` to the address of the Docker interface, **please issue a command**:
  
    Domain redirection ‘lo’ to the address of the Docker interface, create `/etc/dnsmasq.d/lo` file and paste
 
    ```
    interface=lo
    interface=docker0
    bind-interfaces
     
    address=/.lo/172.17.0.1
    ```
    
 3. Add the DNS server to your resolver in the file `/etc/systemd/resolved.conf`:
    ```
    [Resolve]
    DNS=127.0.0.1
    ```
    
    If you have fresh system installations, you can issue a command:
    
    `sudo sed -i 's|#DNS=|DNS=127.0.0.1|g' /etc/systemd/resolved.conf`
	
 4. Start Dnsmasq `sudo systemctl restart dnsmasq`
 
 5. Enable service startup during system boot `sudo systemctl enable dnsmasq`

 6. Restart resolver `sudo systemctl restart systemd-resolved`
 
 7. Create a directory: `sudo mkdir -p /etc/systemd/system/docker.service.d`
 
 8. Docker DNS configuration:
    `echo "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// --dns 172.17.0.1 --dns 8.8.8.8 --dns 8.8.4.4" | sudo tee /etc/systemd/system/docker.service.d/dns.conf`

 9. Restart the Docker daemon:
    `sudo systemctl restart docker.service; sudo systemctl daemon-reload`

 10. Run proxy for Docker:
     `docker run -d -p 172.17.0.1:80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name docker-proxy --restart always jwilder/nginx-proxy`

 11. Create networks for the proxy `docker network create proxy`

 12. Add Nginx Proxy to a proxy network:
     `docker network connect proxy docker-proxy`

 13. Launching the project in the project directory
     `make first-run` or if you already have run the `make run`
     
     
#### Now you can:
 
  Each project has the environment variable `BASE_DOMAIN`,
  it is set to the default value in the `Makefile` file, in this project it is `trl.financial.lo`.
 
  Using addresses from the environment variable `BASE_DOMAIN` (`trl.financial.lo`)
  you can make a request from a web browser from your computer
  or inside any container.
  
  Microservices communicate with each other using a proxy and domain address (Nginx-Proxy), eg:
  
##### On local host:
  
  command:
  ```bash
  curl http://financial.lo/expense
  ```
   
 Response:
 
  ```json
  {"example": "json"}
  ```
  
##### In the Docker Container:
 
 command:
 ```bash
 docker run -it --rm ubuntu bash -c 'apt update && apt install curl -y && curl http://financial.lo/expense'
 ```
 
 Response:
 ```json
 {"example": "json"}  
 ```
 
##### If you want to reset the DNS server, issue the command:

`sudo systemctl restart dnsmasq.service`

### DNS-gen Docker configuration (optional):

  With the Docker DNS-get service, you can connect to applications in containers,
  using the names of containers in the address
  e.g. if you want to integrate your editor with a database in a container,
  you can enter the address `financial-trl_database_1.docker` to connect to the container` financial-trl_database_1`
  
 #### Steps:
 
 1. Create a container with the Docker DNS-gen service:
    ```bash
    docker run --detach \
       --name dns-gen \
       --restart always \
       --publish 127.0.0.1:54:53/udp \
       --volume /var/run/docker.sock:/var/run/docker.sock \
       jderusse/dns-gen
    ```
    
 2. Create file `/etc/dnsmasq.d/docker-dns-gen` and paste`server=127.0.0.1#54`
 
 3. Reset the dnsmasq `sudo systemctl restart dnsmasq.service`
 
 4. Reset the resolver `sudo systemctl restart systemd-resolved`
  
  
### EditorConfig:

  The `.editorconfig` file has saved the configuration of code indentation for individual types of text files,
  which allows you to automatically configure the editor.
    
  Go to the website [editorconfig.org](http://editorconfig.org)
  and check if your editor has native support or you need to install the extension.
  
  * Installing the plugin:
   
      * PhpStorm: File -> Settings... -> Plugins -> Browse repositories -> Enter in the search engine: EditorConfig.
      
        The editor usually recommends installing a plugin after detecting the `.editorconfig` file.
        
### The first launch of the project:

  If you have a properly configured environment,
  it is enough to issue the `make first.run` command to run the project

### Docker management (Environment mode ENVIROMENT_MODE=tools):
 * Another project launch: `make run`.
 * Launching a single Docker service: `make run name=application`.
 * Stopping the project: `make stop`.
 * Stopping one service: `make stop name=application`.
 * Restart project : `make restart`.
 * Restarting a single Docker service: `make restart name=application`.
 * Build a project: `make build`.
 * Build of a single Docker service: `make build name=application`.
 * Scaling services with project restart: `make scale name=application n=3`.
 * Scanning a single service: `make scale.single name=application n=3`
 * Download Docker images: `make pull`.
 * Rebuild the project: `make rebuild`.
 * List of project container statuses: `make status`.
 * Displaying the generated docker-compose: `make config`
 * Remove project containers: `make remove`.
 * Remove containers for a single Docker service: `make remove name=application`.
 * Removal of containers, images, project volumes: `make destroy`.
 * Examples of command combinations:
 	 - `make name='webserver application' build run`
 	 - `make name=database stop remove run`
 * Display of logs captured from containers on live: `make logs`

### Tools:
 * First launch of the project: `make first.run`.
 * Running the tool console: `make shell`
 * Running the console with tools and tests: `make shell.tests`
 * Rebuilding the project, used when changing the git branch: `make build.all`.
 * Installation of composer packages: `make composer.install`.
 * Update composer packages: `make composer.update`.
 * Performing the migration: `make migrate`.
 * Generating default data to the database: `make seed`
 * Generation of random data to the database: `make seed-random`

## Logi z pojedynczego kontenera:

  * Displaying logs from a container:
 
    `docker logs -f container`

  * Display only errors and hide the log:

    `docker logs -f container >/dev/null`

  * Displaying logs, hide errors:

    `docker logs -f container 2>/dev/null`

### Setting environment variables:
  Environment variables can be found in the `.env` file.
  When you first run the project, the `.env.example` file is cope to` .env`.
  
  The `.env` file is ignored by Git,
  If you want to add new environment variables, you should also put them in the `.env.example` file.
  
  The `.env.example` file should contain **production configuration values**,
  while **local default addresses**, to automatically launch the environment.

### Environment variables:
  In the `.env` file you have environment variables:

  * `ENVIROMENT_MODE`: - environment mode
    - `prod` - Very simple production mode.
    - `develop` - Development environment mode (prod + database on Docker).
    - `ci` - Environment mode allowed to run on CICD server (develop mode + makefile CI).
    - `tools` - Environment mode for developers, it has tools (develop mode + tools).
  
  * `USE_BUILD_DOCKER_IMAGES`: - Enables setting if you want to use Docker or Dockerfile images
    - `true` - Set to use Dockerfile and locally built images. 
    - `false` - Set to use Docker images.
    
  After making changes to the environment variables in the `.env` file,
  you must issue the command `make build run` command.
  
### Declare the Docker images used
  
  Declaring used docker images, tags and repository is done using the `.docker.images` file.

### Flow docker-compose and Makefile

  A dynamic environmental has been used, which always includes the path of expanding the production modes and development modes.
  
Inheritance path:
  
  1. Environment mode `prod` - production:
      * Does not contain databases.
      * Contains application containers.
      * Mode environment is enabled by setting the environment variable `ENVIROMENT_MODE = prod` in the` .env` file.
      * Environment mode is managed the `makefiles / prod.mk` file.
      * Docker Compose file responsible for the environment mode is `docker-compose.yml`.

  2. Middle mode `develop` - development, production mode + databases in containers:
      * Is generally intended for development process.
      * The environment mode includes bases in containers and application containers.
      * Mode environment is enabled by setting the environment variable `ENVIROMENT_MODE = develop` in the file `.env`.
      * The environment mode is managed the `makefiles / develop.mk` file.             
      * Docker Compose file responsible for the environment mode is `docker-compose.yml` + `docker-compose.develop.yml`
      * If you set `USE_BUILD_DOCKER_IMAGES = true` in the `.env` file, it will use the `Dockerfile` files.
        Flow Docker Compose: `docker-compose.yml` +` docker-compose.develop.yml` (+ `docker-compose.build.yml`)
      * Please note that, this mode is also used on the CI / CD server.
      * In the case of running tests, the flow looks as follows:
              `docker-compose.yml` + `docker-compose.develop.yml` (+ `docker-compose.build.yml`) (+ `docker-compose.tests.yml`)
     
  3. Environment mode `ci`- used on a CI / CD server (continuous integration, continuous deployment)
      * Mode environment is enabled by setting the environment variable `ENVIROMENT_MODE = ci` in the` .env` file
      * The environment mode is managed via the `makefiles / ci.mk.mk` file
        this file contains the procedures used on the CI / CD server when building the code
      * Environment mode `ci` has a common flow docker-compose like the environment mode `develop`:
        `docker-compose.yml` +` docker-compose.develop.yml` (+ `docker-compose.build.yml`)
      * In the case of running tests, the flow looks as follows:
             `docker-compose.yml` + `docker-compose.develop.yml` + `docker-compose.tools.yml` (+` docker-compose.build.yml`) (+ `docker-compose.tests.yml` )
     
  4. Environment mode `tools` - the right environment for developers, this is the `develop` + development tools environment
      * Mode environment is enabled by setting the environment variable `ENVIROMENT_MODE = tools` in the` .env` file
      * The environment mode is managed via the `makefiles / tools.mk` file
      * After setting `USE_BUILD_DOCKER_IMAGES = true` in the` .env` file, it will use the `Dockerfile` files,
        and not from already built Docker images.
        Flow Docker Compose: `docker-compose.yml` + `docker-compose.develop.yml` + `docker-compose.tools.yml`  (+ `docker-compose.build.yml`)
      * In the case of running tests, the flow looks as follows:
        `docker-compose.yml` + `docker-compose.develop.yml` + `docker-compose.tools.yml` (+` docker-compose.build.yml`) (+ `docker-compose.tests.yml` )
   
### Default addresses:

 * Application:
     [financial.lo](http://trl.financial.lo),
     
 * Redis commander:
 	 [redis.financial.lo](http://redis.trl.financial.lo),
 	 
 * PgAdmin:
 	[pgadmin.financial.lo](http://pgadmin.trl.financial.lo),
    - email: pgadmin4@pgadmin.org
    - hasło: admin
 

### If you have some problems:
 * Restart networking service `sudo systemctl restart network-manager.service`
 * Restart Dnsmasq `sudo systemctl restart dnsmasq.service`

#### Debug:
  * Check resolved DNS `nslookup financial.lo`
  * Check resolv DNS-gen `dig @127.0.0.1 -p 54 financial-trl_webserver_1.docker`
