# Functional Bash

_This is a collection of Bash functions to make bash more functional._

## API

### `filter`

*description*

**Usage**: `filter funcName "${arrName[@]}"`

### `map`

*description*

**Usage**: `map funcName "${arrName[@]}"`

### `refmap`

*description*

**Usage**: `refmap callback arr[@] => []`

### `chain`

*description*

**Usage**: `chain funcs[@] arr[@]`

### `reffoldr`

Referential `foldr`.

**Usage**: `foldr callback [$init] arr[@]`

### `unfold`

*description*

**Usage**: `unfold callback [$init] $limit [$step] => []`

### `zip`

*description* 

**Usage**: `zip arr1[@] arr2[@] [tuplesep]`

### `zipWith`

*description*

**Usage**: `zipWith funcname arr1[@] arr2[@] [tuplesep]`

### `forEach`

*description*

**Usage**: `...`

### `forEachParallel`

Special forEachParallel.
Uses the `coproc` directive in bash to run each function call asynchronously.

### Contributions

This code is licensed under the MIT license. Contributions are welcome.