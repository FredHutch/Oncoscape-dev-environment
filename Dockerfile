# Use Ubuntu 14.04 as the base container
FROM ubuntu:14.04

MAINTAINER "Robert McDermott" robert.c.mcdermott@gmail.com

# ADD the CRAN Repo to the apt sources list
RUN echo "deb http://cran.fhcrc.org/bin/linux/ubuntu trusty/" > /etc/apt/sources.list.d/cran.fhcrc.org.list

# Add the package verification key
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9

# Update the system and install packages
RUN apt-get -y -qq update && apt-get -y -qq install \
	r-base=3.2.2* \
	git \
	vim \
	emacs24-nox \
	make \
	m4 \
	gcc \
	g++ \
	libxml2 \
	libxml2-dev \
	nodejs \
	npm \
	python-pip

# Install required non-apt packages   
RUN pip install websocket-client && npm install -g jshint

# required to get jshint working 
RUN ln -s /usr/bin/nodejs /usr/bin/node

EXPOSE 7777 7788

CMD ["bash"]
