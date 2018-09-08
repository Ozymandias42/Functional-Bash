#!/bin/bash

filter() {
    func=$1
    arr=(${@:2})
    ret=()
    inc=1
    for ((i=0;i<${#arr[@]};i++)); do
        [[ $($func "${arr[$i]}") -eq 1 ]] && { ret[$inc]="${arr[$i]}" ; inc=$(($inc+1)) ; }
    done
    echo ${ret[@]}
}

#Variant on filter. Passing array name instead of elements as positional arguments
#Makes passing of multiple arrays of varying sizes possible
#Breaks functional purity through use of references though
#Needs to be called: filter funcName arrName[@]
#Other function is called filter funcName "${arrName[@]}"
reffilter() {
    func=$1
    arr=("${!2}")
    ret=()
    inc=1
    for ((i=0;i<${#arr[@]};i++)); do
        [[ $($func "${arr[$i]}") -eq 1 ]] && { ret[$inc]="${arr[$i]}" ; inc=$(($inc+1)) ; }
    done
    echo ${ret[@]}
}

preffilter() { 
#Variant w/o echo-return. needed when filtering space separated strings.
#allows to "return" arrays with arbitrary content. No accidential separation via spaces possible.
#needs to be passed the name of a global res array.
#call like this: preffilter predicate arr[@] res
    func=$1
    arr=("${!2}")
    local -n ret=${3}
    inc=1
    for ((i=0;i<${#arr[@]};i++)); do
        [[ $($func "${arr[$i]}") -eq 1 ]] && { ret[$inc]="${arr[$i]}" ; inc=$(($inc+1)) ; }
    done
}

#Usage refmap callback arr[@] => []
refmap() {
    outarr=()
    tmparr=("${!2}")
    for ((i=0;i<${#tmparr[@]};i++)); do
        outarr[$i]=$($1 ${tmparr[$i]})
    done
    echo ${outarr[@]}
}

#Usage map callback ${arr[@]}
map() {
    outarr=()
    tmparr=("${@:2}")
    for ((i=0;i<${#tmparr[@]};i++)); do
        outarr[$i]=$($1 ${tmparr[$i]})
    done
    echo ${outarr[@]}
}

prefmap() {
    local -n outarr=${3}
    input_arr=("${!2}")
    for ((i=0;i<${#input_arr[@]};i++)); do
        outarr[$i]=$($1 ${input_arr[$i]})
    done
}

#Usage chain funcArr[] value[]
chain() {
    funcs=("${!1}")
    input=("${!2}")
    res=(${input[@]})
    for func in ${funcs[@]}; do
            res=( $(refmap $func res[@]) )
    done
    echo "${res[@]}"
}

prefchain() {
    local funcs=("${!1}")
    local input_arr=("${!2}")
    local -n prefchain_res=${3}
    
    for (( i=0;i<${#input_arr[@]};i++ )); do 
        prefchain_res[$i]=${input_arr[$i]}; 
    done

    for func in ${funcs[@]}; do
        prefmap $func prefchain_res[@] prefchain_res
    done
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
    res=0
    for i in ${arr[@]}; do
        res=( $($fun "$res" "$i" ) )
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

refzip() {
    local arr1=( "${!1}" )
    local arr2=( "${!2}" )
    local zip_out=()
    
    [[ ${#arr1[@]} -ge ${#arr2[@]} ]] && use=2 || use=1
    [[ ${#arr1[@]} -eq ${#arr2[@]} ]] && use=1

    index=0
    sep="${3:-" "}" #separator for resulting tuples. $3 if set. else :
    until [[ $index -eq $( [[ $use -eq 1 ]] && echo ${#arr1[@]} || echo ${#arr2[@]} ) ]] ; do
        zip_out[$index]=${arr1[$index]}$sep${arr2[$index]}
        index=$(($index+1))
    done
    echo ${zip_out[@]}
}

prefzip() {
    local arr1=( "${!1}" )
    local arr2=( "${!2}" )
    local -n zip_out=${3}
    local sep="${4:-" "}" #separator for resulting tuples. $3 if set. else :
    
    [[ ${#arr1[@]} -ge ${#arr2[@]} ]] && use=2 || use=1
    [[ ${#arr1[@]} -eq ${#arr2[@]} ]] && use=1

    index=0

    until [[ $index -eq $( [[ $use -eq 1 ]] && echo ${#arr1[@]} || echo ${#arr2[@]} ) ]] ; do
        zip_out[$index]="${arr1[$index]}$sep${arr2[$index]}"
        index=$(($index+1))
    done
    #echo ${zip_out[@]}
}

prefzipWith() {
    local func=${1}
    local arr1=( "${!2}" )
    local arr2=( "${!3}" )
    local additionalParameters=( "${!5}" )
    local -n refzipWith_out=${4} #pointer to external result array. allows for true return of arrays

    [[ ${#arr1[@]} -ge ${#arr2[@]} ]] && use=2 || use=1
    [[ ${#arr1[@]} -eq ${#arr2[@]} ]] && use=1

    index=0
    while [[ $index -le $( [[ $use -eq 1 ]] && echo ${#arr1[@]} || echo ${#arr2[@]} ) ]] ; do
        refzipWith_out[$index]=$( $func "${arr1[$index]}" "${arr2[$index]}" "${additionalParameters[@]}" )
        index=$(($index+1))
    done
}

zipWith() {
    local func=$1
    local arr1=( "${!2}" )
    local arr2=( "${!3}" )
    local tuplesep="${4:-":"}"
    local tmpres=(zip arr1[@] arr2[@] $tuplesep)
    local zipWith_out=()
    local i=0
     while [[ $i -le ${#tmpres[@]} ]]; do
        arg1=$(echo ${tmpres[$i]}|cut -d "'" -f 2|cut -d"$tuplesep" -f 1)
        arg2=$(echo ${tempres[$i]}|cut -d"$tuplesep" -f 2|cut -d"'" -f 1)
        zipWith_out[$index]=$($func $arg1 $arg2)
        index=$(($index+1))
    done
    echo ${res[@]}
}

forEachParallel() {
#$1=callback $2..N array to act on.
    arr=(${@:2}) #Copy $2..N into own array
    for i in ${arr[@]}; do
        coproc $1 $i 
    done
}

forEach() {
    func=${1}
    arr=( "${!2}" )
    for ((i=0;i<${#arr[@]};i++));do
        $func "${arr[$i]}" ${!3:@}
    done
}



