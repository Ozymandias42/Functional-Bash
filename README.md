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
map() {
    outarr=()
    tmparr=(${@:2})
    for (( i=1 ; i<=${#tmparr[@]} ; i++ )); do
        outarr[$i]=$($1 ${tmparr[$i]})
    done
    echo  $outarr
}
```
Call via `filter funcName "${arrName[@]}"`

chain(_callback[]_, arr[]) => results[]
```bash
chain() {
    funcs=("${!1}")
    input=("${!2}")
    res=(${input[@]})
    for func in ${funcs[@]}; do
            res=( $(map $func res[@]) )
    done
    echo "${res[@]}"
}
```
Call via `chain funcs[@] arr[@]`

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
