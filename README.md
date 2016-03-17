##Developing Oncoscape inside a Docker container

Docker is not just for running and deploying applications, it’s great for development too. Using Docker for development provides consistent, clean development environment. Each build can be in a fresh environment without any dependencies on your development workstation or clashes/contamination with your workstation. All developers can use the same OS, same system libraries, same language runtime, no matter what host OS they are using (even Windows). The development environment is the exact same as the production environment. You only need Docker to develop; you don’t need to install a bunch of language environments, libraries and tools on your machine. 

A Docker conatiner recipe for the Oncoscape development environment is located at https://github.com/FredHutch/Oncoscape-dev-environment

To use the Oncoscape development container use 'git' to clone the Oncoscape development container repository to your Docker enabled development system, build a container image and then run it. Here are the commands required to create a container image tagged "oncodev" (you can name it something else if you would like): 

```bash
git clone https://github.com/FredHutch/Oncoscape-dev-environment.git
cd Oncoscape-dev-environment
docker build -t oncodev .
```
The build process will take several minutes to complete. When the build is finished, there will be a new container image registered with your Docker engine named "oncodev" (or whatever you named it). Check to see that the new image was registered with the following command:

```bash
docker images
```
The above command will list the images registered with your docker engine and will look similar to the following:

```
REPOSITORY      TAG         IMAGE ID        CREATED         VIRTUAL SIZE
oncodev         latest      31ee6c745277    2 minutes ago    751.8 MB
```

Now that we have an image registered, you are ready to start making development environment containers. To use the development environment, create and run a container from the image you built and registered. Here is an example (assuming you named your image 'oncodev'):

```bash
docker run -ti -p 80:80 --name myoncodev01 --hostname myoncodev01 oncodev
```
Paramater Description:
  - '--name myoncodev01' flag tags this container (choose whatever name you like). 
  - '--hostname myoncodev01' sets the hostname inside the container to match the container instance name. The bash prompt inside the container will include the provided hostname to make it clear what environment you are currently in. 
  - '-p 80:80' flag tells docker that you want to bind TCP port 80 inside your container to TCP port 80 on your Docker-Machine VM (or directly to the host on Linux). You can bind as many ports as you need by using multiple '-p' arguments. The port you bind to outside the container doesn't have to match the port inside the container. For example '-p 8080:80' will map TCP port 8080 outside the container to TCP port 80 inside the container.

After you execute the above command you'll be dropped to a bash shell inside this new container. You are now root in an isolated Linux environment that has everything that you need to build and run Oncoscape. The container is empty so you'll need to clone the Oncoscape repo (git is included in the container) and install/build/configure/run as you like. You can create new branches, edit code (vim, emacs and nano are provided), commit and push to github right from inside the container. 

***NOTE:*** Windows users only. While the "Docker Quick Start Terminal" is fine for managing, starting, and stopping containers, you'll want to use either the standard command prompt (cmd.exe) or Powershell consoles for interactive work such editing files inside the container. Note that when using 'vi' in a container via cmd.exe or Powershell consoles, the arrow keys do not work and you'll need to use the traditional 'hjkl' keys to move the cursor: 'h'=left, 'j'=down, 'k'=up, 'l'=right.

Setup the environment variables required by docker for the shell of your choice as shown below:

***Classic command prompt (cmd.exe)***
```
FOR /f "tokens=*" %i IN ('docker-machine.exe env --shell=cmd default') DO %i
```
***Powershell***
```
docker-machine.exe env --shell=powershell default | Invoke-Expression
```

After you build and run Oncoscape in a container you'll likely want to point your browser at it. If you are running docker on Linux, you simply point your browser at either http://localhost or http://servername if it's running on a remote server. If you are running Docker on Mac OS X or Windows you first have to determine the IP address of the Docker Machine VM. To do so you'll need to run the following command:

```bash
docker-machine ip default
```

The output of the above command will be a private IP address that you can only reach from your development workstation. After you have this IP address simply point you browser at it with the desired port; "http://192.168.99.100:80" for example.

#### Stopping and starting your containers

To stop your development container, simply exit the bash shell with the "exit" command. This will stop the container and drop you back on your workstation’s command line. You can see all of your containers running and stopped with the following command:

```bash
docker ps -a
```
The output of the above command will look similar to the following:

```
CONTAINER ID   IMAGE      COMMAND   CREATED             STATUS                 NAMES
3bb2bc400dd3   oncodev    "bash"    19 minutes ago      Exited 7 seconds ago   myoncodev01               
```

If you want to start your container again and enter it, simply run the following commands replacing "myoncodev01" with the name of your container:

```bash
docker start myoncodev01
docker attach myoncodev01
```
This will drop you back into an instance of bash running inside your container. 

You're not limited to a single container, you can have as many different Oncoscape development environments on your system as you need.

#### Accessing data outside of your container

In the examples above we cloned the Oncocape repository inside of the container. If you'd rather clone it to your workstation directly and access it from inside your container you can use the Docker 'volumes' feature. For example let's say you have cloned the Oncoscape repo to /Users/myuser/Oncoscape and want to fire up a container and access this external data from inside your container. To accomplish this you'll need to use the '-v' flag when creating a new container and tell it what folder on your workstation you want to be mounted inside the container. Here is an example:

```bash
docker run -ti -p 80:80 -v /Users/myuser/Oncoscape:/opt/Oncoscape --name myoncodev02 --hostname myoncodev02 oncodev
```

After running the above command, you should see that the '/User/myuser/Oncoscape' folder on your development workstation is now mounted read/write to '/opt/Oncoscape' inside this new container. You can change to this directory and use git just like you do on your workstation. It's worth noting that any modifications to this directory or files it contains inside the container, is directly modifying the files outside of your container. This approach can save you a lot of time and disk space by not having to clone the repo inside each container, but if you need true isolation between each conatiner, this might not be the right approach.

***NOTE:*** Windows users can't specify the local folder they want mounted in the traditional *'C:/xyz'* format. You'll need to use the *'/c/xzy'* format. For example *"-v /c/Users/myuser/Oncoscape:/opt/Oncoscape"* will mount 'C:\Users\myuser\Oncoscape' on your workstation to *'/opt/Oncoscape'* inside the container.

#### Cleaning up unneeded containers and images

To delete a container you don't need any longer, it must first be stopped if it's currently running then use the following command replacing "myoncodev03" with the name of the container you wish to delete:

```
docker rm myoncodev03
```

To delete the oncodev image that you built, first there must be no containers running or stopped that are based off of it. When there are no containers created from the oncodev image remaining you can delete this image with the following command replacing "oncodev" with name of the image you created:

```
docker rmi oncodev
```

You can see which containers are on you workstation with the "docker ps -a" command and which images are on your workstation with the "docker images" command.
