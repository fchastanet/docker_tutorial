# refactoring 02-docker-compose/exo2-apache-mysql-gosu 
instead of using Apache/mod_php, we will use nginx/php-fpm stack with *alpine* base image

## create .env file
here we are creating .env file
all the variables defined in this file are available in the docker-compose.yml file
and are passed to the container as environment variables via environment instruction

> commands id -u and id -g gives current user/group id
> 
> under windows 1000 default value is used, the files shared between host and container
> are world writable anyway, chmod on windows files has no effect

execute this command in order to create .env file
```bash
# go to the exercise directory
cd "${TUTO_BASE_DIR}/02-docker-compose/exo3-alpine-nginx-php-fpm/exercise"
# create .env file
if [[ "$(uname -o)" = "Msys" ]]; then
    # windows
    echo "HOST_USER_ID=1000" > .env
    echo "HOST_GROUP_ID=1000" >> .env
else
    # linux
    echo "HOST_USER_ID=$(id -u)" > .env
    echo "HOST_GROUP_ID=$(id -g)" >> .env
fi
```

## Build the images
Just pull the images needed
```bash
docker-compose pull
```
during the build read the following chapters

## New architecture

### First [Why are we using php fpm comparing to mod_php ?](https://www.inmotionhosting.com/support/product-guides/wordpress-hosting/php-fpm-the-future-of-php-handling)

The fact is that Apache + mod_php will keep an instance of the 
PHP interpreter active in every single child httpd process (even for css/js files).
Php-fpm starts a pool of php workers, a worker can be reused by several subsequent requests (automatically 
restarted to avoid memory leeks that could be occurred by some php scripts.
Another advantage is that php-fpm support http2.

### Why using nginx instead of Apache ?
With nginx+fpm, your static assets are served directly from 
nginx without the overhead of an unnecessary PHP interpreter 
loaded into that process, while only your PHP requests are 
funneled to FPM.
Nginx configuration file format is more clear than apache configuration
file format.
However Nginx is not recommended if you have long php process on the frontend. 
  
### Why using alpine based images vs debian/ubuntu ?
alpine based image results in smaller image's size but there are 
some culprits to take into consideration

* debian and alpine packages are different
* debian uses glibc whereas alpine uses musl libc

 > Musl and glibc are two implementations of libc, as in the standard C library. 
 > This is basically the standardized interface between the kernel and userland. 
 > The kernel itself actually has no stable interface, the stability is guaranteed 
 > by the libc which are a bunch of C functions wrapped around binary system calls 
 > that make it easy to write programs. So now you can do fork() instead of having 
 > to manually copy numbers into registers to communicate to the kernel what you want 
 > to do which is what the libc does for you amongst other things.
 > 
 > It also provides basic routine libraries like handling of strings and what-not.
 >   
 > Neither is "better", they have different goals. Glibc is by far the most common 
 > one and is faster than Musl, but Musl uses less space and is also written with 
 > more security in mind and avoids a lot of race conditions and security pitfalls.
 > [source](https://www.reddit.com/r/linuxmasterrace/comments/41q2m9/eli5_what_is_musl_and_glibc/cz4cy3k?utm_source=share&utm_medium=web2x)
 
* it's more difficult to find documentation and forum answers when 
 you want to configure a package
* alpine is considered more secure than debian, but it seems that 
   there is a lot of false positives for debian in reality on docker security checks

About this, see [php image alpine warning](https://hub.docker.com/_/php/#phpversion-alpine) 
    search "php:<version>-alpine" in this page

## check files
* docker-compose.yml
    * we are using 2 services web based on nginx image and php based on php-fpm image
* config/site.conf
    * notice how we instruct nginx to interpret php files by php container

## See how docker-compose.yml is interpreted
see how .env variables are replaced in docker-compose.yml
```bash
docker-compose config
```

## launch our containers
now we will launch all the services defined in the docker-compose.yml file in background process (-d option)
```bash 
docker-compose up -d
```

see the logs of the different services, Ctrl-C to go back to the tutorial
```bash
docker-compose logs -f
```

## open the web sites
Open the web site in your browser [http://localhost](http://localhost)
You should see the `php information` page

Open phpmyadmin [http://localhost:8080](http://localhost:8080)
Notice that you can now authenticate to it using server/login/password mysql/sf4/sf4
defined in the docker-compose.yml file

## cleaning
now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```
