#!/bin/bash

random() {
min=$1
max=$2-$1
num=$(date +%s+%N)
((return=num%max+min))
echo $return
}

id_num=($(random 1 52) $(random 1 52) $(random 1 52) $(random 1 52) $(random 1 52))

echo ${id_num[*]}