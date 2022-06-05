#!/bin/bash

`sudo bash -c 'mkdir -p /rw/config/protected-files.d/ && echo -e "/etc/hosts\n/etc/hostname" > /rw/config/protected-files.d/protect_hostname.txt'`