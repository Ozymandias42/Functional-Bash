# Functional Bash

#### _This is a collection of Bash functions to make bash more functional._

Filter(_callback_,arr[]) => results[]
```bash
filter() {
    arr=(${@:2})
    ret=()
    inc=1
    for i in ${arr[@]}; do
        [[ $($1 $i) -eq 0 ]] && { ret[$inc]=$i ; inc=$(($inc+1)) }
    done
    echo ${ret[@]}
}
```
Call via `filter funcName "${arrName[@]}"`

map(_callback_, arr[]) => results[]
```bash
#Usage map callback ${arr[@]}
map() {
    outarr=()
    tmparr=("${@:2}")
    for item in ${tmparr[@]}; do
        outarr=( ${outarr[@]} $($1 $item) )
    done
    echo ${outarr[@]}
}
```
Call via `map funcName "${arrName[@]}"`

referential map(_callback_, arr[@]) => results[]
```bash
#Usage refmap callback arr[@] => []
refmap() {
    outarr=()
    tmparr=("${!2}")
    for item in ${tmparr[@]}; do
        outarr=( ${outarr[@]} $($1 $item) )
    done
    echo ${outarr[@]}
}
```

chain(_callback[]_, arr[]) => results[]
```bash
chain() {
    funcs=("${!1}")
    input=("${!2}")
    res=(${input[@]})
    for func in ${funcs[@]}; do
            res=( $(map $func res[@]) ) #NOTE: uses referential map. 
#Altern.    res=( $(map $func ${res[@]} )
    done
    echo "${res[@]}"
}
```
Call via `chain funcs[@] arr[@]`

referential foldr(_callback_ [init] arr[]) => result
```bash
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
```

foldr(_callback_ arg[@]) => result
```bash
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
```

unfold(_callback_ [init] limit [step]) => []
```bash
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
```

forEach(_callback_, arr[]) => void
```bash
forEach() {
    arr=(${@:2})
    for i in ${arr[@]}; do
        $1 $i
    done
}
```
Call via `filter funcName "${arrName[@]}"`

_Special forEachParallel._  
_Uses the `coproc` directive in bash to run each function call asynchronously_
forEachParallel(_callback_, arr[]) => void
```bash
forEachParallel() {
#$1=callback $2..N array to act on.
    arr=(${@:2}) #Copy $2..N into own array
    for i in ${arr[@]}; do
        coproc $1 $i 
    done
}
```
Call via `filter funcName "${arrName[@]}"`
