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

###TESTS FILTER
##TEST AGAINST ARITHMETIC PREDICATE WITH ONE ARGUMENT
expres=(2 4)
explength=2
res=($(filter isEven ${arr1[@]}))
reslength=${#res[@]}
echo ""
echo "Test of filter() with ${arr1[@]} against isEven()"
echo "Expected Result ${expres[@]} ... Testresult ${res[@]}"
[[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "FAILURE"
echo "Checking output length. Expected $explength ... got $reslength"
[[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "FAILURE"
echo ""

##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
res=($(filter isLongerSix ${sarr1[@]}))
reslength=${#res[@]}
echo ""
echo "Test of filter() with '${sarr1[@]}' against isLongerSix()"
echo -e "Expected Result '${expres[@]}' \nTestresult ${res[@]}"
[[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "(expected) FAILURE"
echo "Checking output length. Expected $explength ... got $reslength"
[[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "FAILURE"
echo ""


###TESTS REFFILTER
##TEST AGAINST ARITHMETIC PREDICATE WITH ONE ARGUMENT
expres=(2 4)
explength=2
res=($(reffilter isEven arr1[@]))
reslength=${#res[@]}
echo ""
echo "Test of reffilter() with arr1[@] against isEven()"
echo "Expected Result ${expres[@]} ... Testresult ${res[@]}"
[[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "FAILURE"
echo "Checking output length. Expected $explength ... got $reslength"
[[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "FAILURE"
echo ""

##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
res=($(reffilter isLongerSix sarr1[@]))
reslength=${#res[@]}
echo ""
echo "Test of reffilter() with sarr1[@] against isLongerSix()"
echo -e "Expected Result '${expres[@]}' \nTestresult '${res[@]}'"
[[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "FAILURE"
echo "Checking output length. Expected $explength ... got $reslength"
[[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "(expected) FAILURE"
echo ""

###TESTS PREFFILTER
##TEST AGAINST STRING PREDICATE WITH ONE ARGUMENT
expres=("dies ist ein test" 'dies ist "ein weiterer" test')
explength=2
unset res
declare -a res
preffilter isLongerSix sarr1[@] res
reslength=${#res[@]}
echo ""
echo "Test of preffilter() with sarr1[@] against isLongerSix()"
echo -e "Expected Result '${expres[@]}' \nTestresult '${res[@]}'"
[[ "${res[@]}" == "${expres[@]}" ]] && echo "SUCCESS" || echo "(expected) FAILURE"
echo "Checking output length. Expected $explength ... got $reslength"
[[ "$explength" -eq "$reslength" ]] && echo "SUCCESS" || echo "FAILURE"
echo ""
