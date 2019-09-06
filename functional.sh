#!/bin/bash

filter() {
    local func=$1
    local arr=($"${@:2}")
    local -a ret=()
	
    for i in $"${arr[@]}"; do
		[[ $($func $"${i}") ]] && ret+=( $"${i}" )
    done
    echo $"${ret[@]}"
}

# Variant on filter. Passing array name instead of elements as positional arguments.
# This function makes passing multiple arrays of varying sizes possible, too,
# although it breaks functional purity through use of references.
# Call it like so:
#   filter funcName arrName[@]
# Other function is called: 
#   filter funcName "${arrName[@]}"
reffilter() {
    local func=$1
    local arr=($"${!2}")
    local -a ret=()
    local inc=1
    for i in $"${arr[@]}"; do
        [[ $($func $"${i}") ]] && ret+=( $"${i}" )
    done
    echo $"${ret[@]}"
}

preffilter() { 
# Variant without echo-return. needed when filtering space separated strings.
# This allows to "return" arrays with arbitrary content. No accidential separation via spaces possible.
# Needs to be passed the name of a global res array.
# Call it like so: 
#   preffilter predicate arr[@] res
    local func=$1
    local -a arr=($"${!2}")
    local -n ret=${3}

    for i in $"${arr[@]}"; do
        [[ $($func $"${i}" ) ]] && ret+=( $"${i}" )
    done
}

# Call this function like so:
#   map callback ${arr[@]}
map() {
    local func=$1
    local outarr=()
    local tmparr=($"${@:2}")
    for i in $"${tmparr[@]}"; do
        outarr+=( $"$($func $"${i}")" )

    done
    echo $"${outarr[@]}"
}

# Call this function like so:
#   refmap callback arr[@] => []
refmap() {
    local func=$1
    local outarr=()
    local tmparr=($"${!2}")
    for i in $"${tmparr[@]}"; do
        outarr+=( $"$( $func $"${i}" )" )
    done
    echo $"${outarr[@]}"
}

prefmap() {
    local func=$1
    local input_arr=($"${!2}")
    local -n outarr=${3}
    #for i in $"${input_arr[@]}"; do
    for (( i=0 ; i<${#input_arr[@]} ; i++ )); do
    #    outarr+=( $"$( $func $"${i}" )" )
         outarr[$i]=$"$( $func $"${input_arr[$i]}" )"
    done
}

#Usage chain funcArr[] value[]
chain() {
    local funcs=("${!1}")
    local input=("${!2}")
    local res=(${input[@]})
    for func in ${funcs[@]}; do
            res=( $(refmap $func res[@]) )
    done
    echo $"${res[@]}"
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


#Usage foldr callback ${arr[@]}
foldr() {
    local fun=${1}
    local arr=("${@:2}")
    local res=0
    for i in ${arr[@]}; do
        res=( $"$($fun $"$res" $"$i" )" )

#Usage foldr callback [$init] arr[@]
reffoldr() {
    fun=${1}
    arr=("${!2}")
    res=0
    for i in ${arr[@]}; do
        res=( $($fun "$res" "$i" ) )
    done
    echo $"${res[@]}"  
}

#Usage foldr callback [$init] arr[@]
reffoldr() {
    local fun=${1}
    local arr=("${!2}")
    local res=0
    for i in ${arr[@]}; do
        res=( $"$($fun $"$res" $"$i" )" )
    done
    echo $"${res[@]}"  
}

preffoldr() {
    local fun=${1}
    local arr=("${!2}")
    local -n preffoldr_res=${3}
    local preffolr_res=(0) 
    for (( i=0;i<${#arr[@]};i++)); do
        preffoldr_res[0]=$"$($fun $"${preffoldr_res[0]}" $"${arr[$i]}" )"
    fun=${1}
    arr=("${!2}")
    local -n preffoldr_res=${3}
    preffolr_res=(0) 
    for (( i=0;i<${#arr[@]};i++)); do
        preffoldr_res[0]=$($fun "${preffoldr_res[0]}" "${arr[$i]}" )
    done
    #echo ${res[@]}  
}
#usage: unfold callback [$init] $limit [$step] => []
unfold() {
    local fun=${1}
    [[ $# -eq 3 ]] && init=("${2}") || init=0
    local limit=${3:-$2}
    [[ $# -eq 4 ]] && inc=("${4}") || step=1
    local out=()
    local range=( $(seq $init $step $limit)  )
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

    [ $use == 1 ] && length=${#arr1[@]} || length=${#arr2[@]}
    for ((i=0; i<$length; i++ )); do
        zipWith_out[$i]=$( $func "${arr1[$i]}" "${arr2[$i]}" "${additionalParameters[@]}" )
    done
}

zipWith() {
    local func=${1}
    local arr1=( "${!2}" )
    local arr2=( "${!3}" )
    local additionalParameters=( "${!5}" )
    local -A zipWith_out 

    [[ ${#arr1[@]} -ge ${#arr2[@]} ]] && use=2 || use=1
    [[ ${#arr1[@]} -eq ${#arr2[@]} ]] && use=1

    [ $use == 1 ] && length=${#arr1[@]} || length=${#arr2[@]}
    for ((i=0; i<$length; i++ )); do
        zipWith_out[$i]=$( $func "${arr1[$i]}" "${arr2[$i]}" "${additionalParameters[@]}" )
    done
    echo ${zipWith_out[@]}
}

forEach() {
    func=${1}
    arr=( "${!2}" )
    for i in $"${arr[@]}"; do
        $func $"${$i}"
    done
}



