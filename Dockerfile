# Use Ubuntu 14.04 as the base container
FROM ubuntu:14.04

# ADD the CRAN Repo to the apt sources list
RUN echo "deb http://cran.fhcrc.org/bin/linux/ubuntu trusty/" > /etc/apt/sources.list.d/cran.fhcrc.org.list

# Add the package verification key
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9

# Update the system and install packages
RUN apt-get -y -qq update && apt-get -y -qq install \

	r-base=3.2.2* \
	r-recommended=3.2.2-1trusty0* \
	git \
	vim \
	nano \
	make \
	gcc \
	g++ 

# Install latest version of Node 5.x
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -
RUN apt-get -y install nodejs

# Install node-gyp required to build node add-ons
RUN npm install -g node-gyp

EXPOSE  80

CMD ["bash"]
