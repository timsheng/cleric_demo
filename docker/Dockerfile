# Base the image off of the latest pre-built rails image
FROM rails

ENV ENV_CONFD_PREFIX=/

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    libsodium-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# make and switch to the /app directory which will hold our app
RUN mkdir /app
WORKDIR /app

# move over the Gemfile and Gemfile.lock before the rest of the app so that we can cache the installed gems
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN \
	# install all gems specified by the Gemfile
	bundle install && \

	# Install confd
	echo "Installing confd.." && \
	wget -c -L -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64  && \
	chmod +x /usr/local/bin/confd

# copy over the rest of the rails app files
ADD . /app

ENTRYPOINT ["/app/docker/entrypoint.sh"]
