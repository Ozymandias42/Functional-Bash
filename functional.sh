#!/bin/bash

filter() {
    arr=(${@:2})
    ret=()
    inc=1
    for i in ${arr[@]}; do
        [[ $($1 $i) -eq 0 ]] && { ret[$inc]=$i ; inc=$(($inc+1)) }
    done
    echo ${ret[@]}
}

map() {
    outarr=()
    tmparr=(${@:2})
    for (( i=1 ; i<=${#tmparr[@]} ; i++ )); do
        outarr[$i]=$($1 ${tmparr[$i]})
    done
    echo  $outarr
}

forEachParallel() {
#$1=callback $2..N array to act on.
    arr=(${@:2}) #Copy $2..N into own array
    for i in ${arr[@]}; do
        coproc $1 $i 
    done
}

forEach() {
    arr=(${@:2})
    for i in ${arr[@]}; do
        $1 $i
    done
}



