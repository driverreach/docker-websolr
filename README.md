
Docker image for DriverReach's Websolr Integration

For use in development/testing only.

To use, first install Docker on your machine: https://docs.docker.com/desktop/install/mac-install/

To build, clone this repo, navigate to the working directory the in your terminal, run:

```
docker build -t websolr .
```

Then, to start up a new container using this image, run the following, replacing `LOCALHOST_PORT` with the port you wish to use:

```
docker run -p <LOCALHOST_PORT>:8981 websolr
```

### Note:
You could run development and testing Solr instances by running the above command twice, substituting different ports for development and testing respectively:
```
docker run -d -p 8982:8981 --name solr-dev websolr

docker run -d -p 8981:8981 --name solr-test websolr
```
