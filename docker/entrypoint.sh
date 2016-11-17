#!/bin/bash

set -e

# Run confd to generate the application configurations
echo "Generating configurations from /app/config with prefix $ENV_CONFD_PREFIX"
confd -onetime -backend env -confdir /app/config -prefix=$ENV_CONFD_PREFIX
sed -i 's/\\n/\n/g' /app/config/id_rsa
mkdir ~/.ssh && cp /app/config/id_rsa ~/.ssh

# Decrypt yml
echo "Decrypt environment yml"
cd /app/bin
ruby decrypt.rb prod
ruby decrypt.rb stage

# Run the command
cd /app
exec "$@"
