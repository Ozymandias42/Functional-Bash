#!/bin/bash

filter() {
    arr=(${@:2})
    ret=()
    inc=1
    for i in ${arr[@]}; do
        [[ $($1 $i) -eq 0 ]] && { ret[$inc]=$i ; inc=$(($inc+1)) ; } 
    done
    echo ${ret[@]}
}

#Variant on filter. Passing array name instead of elements as positional arguments
#Makes passing of multiple arrays of varying sizes possible
#Breaks functional purity through use of references though
#Needs to be called: filter funcName arrName[@]
#Other function is called filter funcName "${arrName[@]}"
filter() {
    arr=("${!2}")
    ret=()
    inc=1
    for i in ${arr[@]}; do
        [[ $($1 $i) -eq 0 ]] && { ret[$inc]=$i ; inc=$(($inc+1)) ; }
    done
    echo ${ret[@]}
}

#Usage refmap callback arr[@] => []
refmap() {
    outarr=()
    tmparr=("${!2}")
    for item in ${tmparr[@]}; do
        outarr=( ${outarr[@]} $($1 $item) )
    done
    echo ${outarr[@]}
}

#Usage map callback ${arr[@]}
map() {
    outarr=()
    tmparr=("${@:2}")
    for item in ${tmparr[@]}; do
        outarr=( ${outarr[@]} $($1 $item) )
    done
    echo ${outarr[@]}
}

#Usage chain funcArr[] value[]
chain() {
    funcs=("${!1}")
    input=("${!2}")
    res=(${input[@]})
    for func in ${funcs[@]}; do
            res=( $(map $func res[@]) )
    done
    echo "${res[@]}"
}

#Usage foldr callback [$init] arr[@]
reffoldr() {
    fun=${1}
    [[ $# -eq 3 ]] && init=("${2}")
    arr=("${!3:-${!2}}")
    res=${init:-0}
    for i in ${arr[@]}; do
        res=( $($fun $res $i ) )
    done
    echo ${res[@]}  
}

#Usage foldr callback ${arr[@]}
foldr() {
    fun=${1}
    arr=("${@:2}")
    res=${init:-0}
    for i in ${arr[@]}; do
        res=( $($fun $res $i ) )
    done
    echo ${res[@]}  
}

#usage: unfold callback [$init] $limit [$step] => []
unfold() {
    fun=${1}
    [[ $# -eq 3 ]] && init=("${2}") || init=0
    limit=${3:-$2}
    [[ $# -eq 4 ]] && inc=("${4}") || step=1
    out=()
    range=( $(seq $init $step $limit)  ) 
    for i in ${range[@]} ; do
        out=( ${out[@]} $($fun $i) )
    done
    echo ${out[@]}
}

zip() {
    arr1=( "${!1}" )
    arr2=( "${!2}" )
    [[ ${#arr1[@]} -ge ${#arr2[@]} ]] && use=1 || use=2
    [[ ${#arr1[@]} -eq ${#arr2[@]} ]] && use=1
    out=()

    next() {
        lastindex=$1
        arr=( "${!2}" )
        if [[ "$lastindex" -ne $((${#arr[@]}-1)) ]]; then
            echo $(($lastindex+1))
        else
            next $(($lastindex-${#arr[@]})) arr[@]
        fi
    }

    index1=0
    index2=0
    index=0
    while [[ $index -ne $( [[ $use -eq 1 ]] && echo ${#arr1[@]} || echo ${#arr2[@]} ) ]] ; do
        out=( ${out[@]} \'${arr1[$index1]} ${arr2[$index2]}\' )
        index1=$(next $index arr1[@])
        index2=$(next $index arr2[@])
        index=$(($index+1))
    done
    echo "${out[@]}"
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



