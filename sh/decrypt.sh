#!/bin/bash

path=../config/environments/
openssl enc -in  $path/stage.yml.enc -out  $path/stage.yml.new -d -aes256 -k $1
