#!/bin/bash

path=../config/environments/
openssl enc -in  $path/stage.yml -out  $path/stage.yml.enc -e -aes256 -k $1