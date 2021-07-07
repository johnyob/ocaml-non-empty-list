# ocaml-non-empty-list
A list that is known, statically, to be nonempty. 
The `hd` and `tl` functions don't require `option` types, or exceptions. 

This library follows closely Janestreet's `Base` library,
providing similar complexity and functions to `Base.List`. 

## Usage

```ocaml
open Non_empty_list

let one = [1]

let two = cons 2 one (* [2; 1] *)

let hd_of_one = hd one (* 1 *)

let combined = append one two (* [1; 2; 1] *)
```

## Testing
TODO

