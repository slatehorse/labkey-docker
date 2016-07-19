Labkey Docker Image
==========

Provides the Dockerfile, scripts and instructions needed to build the [slatehorse/labkey-standalone](https://hub.docker.com/r/spikeheap/labkey-standalone/) image.

Forked from [LabKey/samples](https://github.com/LabKey/samples/tree/master/docker/labkey-standalone) to follow the release train.

**IMPORTANT:** This image is intended for local development and testing, and comes with no warranty of any kind. 


## Is there an image already built? 

An image built with this Dockerfile is available at [slatehorse/labkey-standalone](https://hub.docker.com/r/spikeheap/labkey-standalone/) on DockerHub. Check out the [tags](https://hub.docker.com/r/spikeheap/labkey-standalone/tags/) to check for available versions and custom builds.



## Usage 

### Create the image
To create the image you will need do the following:

1. Download the latest version of [Oracle JAVA 8 Server JRE](http://www.oracle.com/technetwork/java/javase/downloads/server-jre7-downloads-1931105.html) to `./lib` directory 
1. Download the latest version of [Tomcat 8](http://tomcat.apache.org/download-80.cgi) binary distribution to `./lib`
    * Use the _Core tar.gz_ download
1. Download the latest version of [LabKey Server](http://labkey.com/download-labkey-server) to `./lib` directory
    * Use the _Binaries for Manual Linux/Mac/Unix Installation_ link
1. Update the `Dockerfile` and change the names in the file to match the ones you downloaded above.
1. Build the image
        
        docker build -t slatehorse/labkey-standalone .


### Running LabKey Server Standalone in a container

To run the image 

    docker run --name labkey-standalone -d -p 8080:8080 slatehorse/labkey-standalone


After few seconds, open [http://<host>:8080](http://<host>:8080) to see the LabKey Server initialization page.

### Pushing this image to the Docker Hub

If you are a maintainer, you can push new versions (e.g. here version 16.2) to the docker hub as follows:

1. Tag the current commit as the release version:

        git tag 16.2

2. Build a tagged image version:

        docker build -t slatehorse/labkey:16.2 .

3. Push the image to the the Docker Hub

        docker push slatehorse/labkey:16.2
