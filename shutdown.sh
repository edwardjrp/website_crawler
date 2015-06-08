#!/bin/bash

source /usr/local/rvm/environments/ruby-1.9.3-p194@updaternc

/usr/local/rvm/gems/ruby-1.9.3-p194@updaternc/bin/thin -s 2 -C /home/edward/updaternc_ondemand/config/config.yml -R /home/edward/updaternc_ondemand/config.ru stop
