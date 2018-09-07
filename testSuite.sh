#!/bin/bash
. $PWD/functional.sh

###TESTINPUT NUMERIC
arr1=(1 2 3 4)
arr2=(5 6 7 8)

###TESTINPUT STRINGS
sarr1=("test2" "dies ist ein test" 'dies ist "ein weiterer" test')
sarr2=("bob" "dies ist alice" 'eve is listening')

###TEST ARITHMETIC CALLBACK /W TWO ARGUMENTS
sum() { echo $(($1+$2)) ; }

###TEST ARITHMETIC CALLBACK /W ONE ARGUMENT
add2(){ echo $(($1+2)) ; }

###TEST ARITHMETIC PREDICATE FUNCTION isEven
isEven() { (( (${1}%2) == 0 )) && echo 1 || echo 0 ; }

###TEST PREDICATE FUNCTION ON STRINGS
isLongerSix(){ [[ ${#1} -ge 6 ]] && echo 1 || echo 0 ; }

###TEST CALLBACK FUNCTION ON STRINGS
makeHelloWorld() { echo "Hello World" ; }

#testFactory func2test callback2test array2test[@] expres[@] explength ref[BOOL=1/0] pref[BOOL=1/0]
testFactory() {
    func2test=${1}
    callback=${2}
    arr2test=("${!3}")
    expres=(${!4})
    explength=${5}
    ref=${6:-0}
    pref=${7:-0}
    [[ $ref -eq 0 ]] && res=($($func2test $callback ${arr2test[@]}))
    if [[ $pref -eq 0 ]] && [[ $ref -eq 1 ]]; then 
        res=($($func2test $callback arr2test[@]))
    fi
    if [[ $pref -eq 1 ]]; then 
        declare -A res
        $func2test $callback arr2test[@] res 
    fi

    reslength=${#res[@]}
    echo ""
    echo "Test of ${1}() with '${arr2test[@]}' against ${2}()"
    printf '%s ' "Expected Result: " "${expres[@]}"; printf '\n'
    printf '%s ' "Testresult     : " "${res[@]}";    #printf '\n'
    [[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "FAILURE"
    echo -n "Checking output length. Expected $explength ... got $reslength ..."
    [[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "FAILURE"
    echo ""
}

###TESTS FILTER
##TEST AGAINST ARITHMETIC PREDICATE WITH ONE ARGUMENT
expres=(2 4)
explength=2
testFactory filter isEven arr1[@] expres[@] $explength

##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
testFactory filter isLongerSix sarr1[@] expres[@] $explength

###TESTS REFFILTER
##TEST AGAINST ARITHMETIC PREDICATE WITH ONE ARGUMENT
expres=(2 4)
explength=2
testFactory reffilter isEven arr1[@] expres[@] $explength 1

##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
testFactory reffilter isLongerSix sarr1[@] expres[@] $explength 1

###TESTS PREFFILTER
##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
testFactory preffilter isLongerSix sarr1[@] expres[@] $explength 1 1


###TESTS MAP
##TEST AGAINST add2 (ONE ARGUMENT)
expres=(3 4 5 6)
explength=4
testFactory map add2 arr1[@] expres[@] $explength 

##TEST AGAINST makeHelloWorld (ZERO ARGUMENTS)
expres=("Hello World" "Hello World" "Hello World")
explength=3
testFactory map makeHelloWorld sarr1[@] expres[@] $explength

###TESTS REFMAP
##TEST AGAINST add2 (ONE ARGUMENT)
expres=(3 4 5 6)
explength=4
testFactory refmap add2 arr1[@] expres[@] $explength 1 

##TEST AGAINST makeHelloWorld (ZERO ARGUMENTS)
expres=("Hello World" "Hello World" "Hello World") 
explength=3
testFactory refmap makeHelloWorld sarr1[@] expres[@] $explength 1

###TESTS PREFMAP
##TEST AGAINST add2 (ONE ARGUMENT)
expres=(3 4 5 6)
explength=4
testFactory prefmap add2 arr1[@] expres[@] $explength 1 1

##TEST AGAINST makeHelloWorld (ZERO ARGUMENTS)
expres=("Hello World" "Hello World" "Hello World") 
explength=3
testFactory prefmap makeHelloWorld sarr1[@] expres[@] $explength 1 1


###TESTS CHAIN
##TEST AGAINST add2 AND times3


##TEST AGAINST makeHelloWorld AND speakL33T
