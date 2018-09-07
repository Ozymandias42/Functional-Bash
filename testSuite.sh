#!/bin/bash
source  $PWD/functional.sh

###TESTINPUT NUMERIC
arr1=(1 2 3 4)
arr2=(5 6 7 8)

###TESTINPUT STRINGS
sarr1=("test2" "test with spaces" 'quoted test "a quote"')
sarr2=("bob" "this is alice" 'eve is listening')

###TEST ARITHMETIC CALLBACK /W TWO ARGUMENTS
sum() { echo $(($1+$2)) ; }

###TEST ARITHMETIC CALLBACK /W ONE ARGUMENT
add2(){ echo $(($1+2)) ; }
times3(){ echo $(($1*3)) ; }

###TEST ARITHMETIC PREDICATE FUNCTION isEven
isEven() { (( (${1}%2) == 0 )) && echo 1 || echo 0 ; }

###TEST PREDICATE FUNCTION ON STRINGS
isLongerSix(){ [[ ${#1} -ge 6 ]] && echo 1 || echo 0 ; }

###TEST CALLBACK FUNCTION ON STRINGS
makeHelloWorld() { echo "Hello World" ; }
speakL33T(){ echo "${@//e/3}"  ; }

#testFactory func2test callback2test array2test[@] expres[@] explength ref[BOOL=1/0] pref[BOOL=1/0]
testFactory() {
    func2test=${1}
    callback=("${!2:-$2}")
    arr2test=("${!3}")
    expres=(${!4})
    explength=${5}
    functype=${6:-0}
    #Functypes: 0 = pass list as args
    #           1 = pass list via indirection
    #           2 = return result via global variable with declare -n
    #           3 = take two lists as input
    #           4 = take two lists as input return via global variable with declare -n 
    case $functype in 
        0)  res=($($func2test $callback ${arr2test[@]})) ;;
        1)  res=($($func2test $callback arr2test[@])) ;;
        2)  declare -A res
            $func2test $callback arr2test[@] res 
            ;;
        3)  res=($($func2test callback[@] arr2test[@])) ;;
        4)  declare -A res
            $func2test callback[@] arr2test[@] res ;;
    esac

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
expres=("test with spaces" 'quoted test "a quote"')
explength=2
testFactory filter isLongerSix sarr1[@] expres[@] $explength

###TESTS REFFILTER
##TEST AGAINST ARITHMETIC PREDICATE WITH ONE ARGUMENT
expres=(2 4)
explength=2
testFactory reffilter isEven arr1[@] expres[@] $explength 1

##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("test with spaces" 'quoted test "a quote"')
explength=2
testFactory reffilter isLongerSix sarr1[@] expres[@] $explength 1

###TESTS PREFFILTER
##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("test with spaces" 'quoted test "a quote"')
explength=2
testFactory preffilter isLongerSix sarr1[@] expres[@] $explength 2


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
testFactory prefmap add2 arr1[@] expres[@] $explength 2

##TEST AGAINST makeHelloWorld (ZERO ARGUMENTS)
expres=("Hello World" "Hello World" "Hello World") 
explength=3
testFactory prefmap makeHelloWorld sarr1[@] expres[@] $explength 2


###TESTS CHAIN
##TEST AGAINST add2 AND times3
expres=(9 12 15 18)
explength=4
funcs=(add2 times3)
testFactory chain funcs[@] arr1[@] expres[@] $explength 3

##TEST AGAINST makeHelloWorld AND speakL33T
expres=("H3llo World" "H3llo World" "H3llo World")
explength=3
funcs=(makeHelloWorld speakL33T)
testFactory chain funcs[@] sarr1[@] expres[@] $explength 3

testFactory prefchain funcs[@] sarr1[@] expres[@] $explength 4
