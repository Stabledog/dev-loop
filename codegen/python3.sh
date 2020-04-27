#!/bin/bash
# codegen/python3.sh


echo "python3.sh:  Append the following to your taskrc{.md}:" >&2
echo '```bash'
cat $CodegenHome/python3.init
echo '```'
