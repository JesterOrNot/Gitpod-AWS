#!/bin/bash
helm upgrade --debug --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .
