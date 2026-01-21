#!/bin/bash

# The original comma-separated string
my_string="csv,txt,xlsx"

# Set the Internal Field Separator (IFS) to a comma
IFS=',' read -r -a my_string <<< "$my_string"
rgx=""

for elemento in "${my_string[@]}"; do
    rgx+="*\.${elemento}\|"
done

rgx="${rgx::-1}"

echo $rgx