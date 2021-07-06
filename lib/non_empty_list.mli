open Base

(** A non-empty list is defined as a immutable (singly) linked list containing at least 1 element.
    Identical in terms of complexity to [list]. The API is inspired by {!Base.List} 
    (but is not identical). *)

(** The non-empty list type. The use of the [( :: )] infix constructor
    allows the usage of the built-in list syntactic sugar provided by OCaml. 
    
    For example, a singleton is given by [ [1] ]. A list containing 2 elements is given by
    [ [1; 2] ]. *)
type 'a t = ( :: ) of 'a * 'a list
    [@@deriving eq, ord]

include Monad.S with type 'a t := 'a t 

(** [init n ~f] returns the non-empty list [[(f 0); (f 1); ...; (f (n-1))]]. *)
val init : int -> f:(int -> 'a) -> 'a t option

(** [of_list] creates a non-empty list from a standard list, 
    returning [None] if the empty list is provided. *)
val of_list : 'a list -> 'a t option

(* Similar to {!Non_empty_list.of_list}, but raises an [Invalid_argument] if the empty list is provided. *)
val of_list_exn : 'a list -> 'a t

(** [of_array] creates a non-empty list from an array. 
    [of_array arr] is equivalent to [of_list (List.to_array arr)]. *)
val of_array : 'a array -> 'a t option

(* Simialar to {!Non_empty_list.of_array}, but raises an [Invalid_argument] if an empty array is provided. *)
val of_array_exn : 'a array -> 'a t

(*** Length **************************************************************************************)

val length : 'a t -> int

val is_singleton : 'a t -> bool

(*** Accessors ***********************************************************************************)

(** [hd] returns the first element of the given non-empty list [t]. 
    Note that no exception can occur. *)
val hd : 'a t -> 'a

(** [tl] returns the tail of the non-empty list. Note that the [list] type is used
    for the returned value, since removing an element from a non-empty list may yield
    an empty list (e.g. a singleton). *)
val tl : 'a t -> 'a list

(** [last] returns the final element of the non-empty list. *)
val last : 'a t -> 'a

(** Returns the [n]-th element of the list. The head of the list has position 0. 
    [None] is returned if the list [t] is too short or [n] is negative. *)
val nth : 'a t -> int -> 'a option

(** Equivalent to [nth]. However, an [Invalid_argument] exception is raised if the list
    [t] is too short or [n] is negative. *)
val nth_exn : 'a t -> int -> 'a

(** Checks whether the provided element [x] is a member of the non-empty list [t], using
    [equal]. *)
val mem : 'a t -> 'a -> equal:('a -> 'a -> bool) -> bool

(** [find t ~f] returns the first element of the non-empty list [t] that 
    satisfied [f]. *)
val find : 'a t -> f:('a -> bool) -> 'a option

(** Similar to {!Non_empty_list.find}, but raises a [Not_found] if there is no such element
    that satisfies [f]. *)
val find_exn : 'a t -> f:('a -> bool) -> 'a

(** Similar to [find], however, the index is passed as an argument to [f] as well. *)
val findi : 'a t -> f:(int -> 'a -> bool) -> (int * 'a) option

val findi_exn : 'a t -> f:(int -> 'a -> bool) -> int * 'a

(** [find_map t ~f] returns [Some x], the first element [x] for which [f x] retunrs [Some x]. 
    Returns [None] if there is no such element. *)
val find_map : 'a t -> f:('a -> 'b option) -> 'b option

val find_map_exn : 'a t -> f:('a -> 'b option) -> 'b

(** Similar to {!Non_empty_list.find_map}, however, the index is passed as an argument to [f] as well. *)
val find_mapi : 'a t -> f:(int -> 'a -> 'b option) -> (int * 'b) option

val find_mapi_exn : 'a t -> f:(int -> 'a -> 'b option) -> int * 'b

(*** Reverse *************************************************************************************)

(** [Or_unequal_lengths] is used for functions that take multiple non-empty lists (denoted [t1], etc).
    Defines the dependent type: [{'a : length t1 = length t2 = ... length tn}]. 
    Extends the {!Base.List.Or_unequal_lengths} implementation with the Monad methods, improves 
    readabily and reuseability of other library functions. *)
module Or_unequal_lengths : sig
    include module type of List.Or_unequal_lengths
    include Monad.S with type 'a t := 'a t
end

(** Reverses the non-empty list. *)
val rev : 'a t -> 'a t

(** [rev_map t ~f] is equivalent to [rev (map t ~f)]. However, it is more efficient. *)
val rev_map : 'a t -> f:('a -> 'b) -> 'b t

(** [rev_map2 t1 t2 ~f] is equivalent to [map2 t1 t2 ~f >>| rev]. Returns [Unequal_lengths]
    if [length t1 <> length t2]. *)
val rev_map2 : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t Or_unequal_lengths.t

(** Similar to [rev_map2], however, raises  *)
val rev_map2_exn : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t

(*** Quantifiers and Predicates ******************************************************************)

(** [for_all [x1; ...; xn] ~f] returns [true] iff [f xi] is [true] for all [1 <= i <= n]. 
    This is a short-circuiting operation, evaluting [f xi] in a left-to-right order. *)
val for_all : 'a t -> f:('a -> bool) -> bool

(** Similar to {!Non_empty_list.for_all}, however, the index is passed as an argument to [f] as well. *)
val for_alli : 'a t -> f:(int -> 'a -> bool) -> bool

(** Similar to {!Non_empty_list.for_all}, but defines a 2 non-empty list quanitifer *)
val for_all2 : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool Or_unequal_lengths.t

val for_all2_exn : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool

(** [for_all [x1; ...; xn] ~f] returns [true] iff there exists [1 <= i <= n] such that [f xi] is [true]. 
    This is a short-circuiting operation, evaluting [f xi] in a left-to-right order. *)
val exists : 'a t -> f:('a -> bool) -> bool

(** Similar to {!Non_empty_list.exists}, however, the index is passed as an argument to [f] as well. *)
val existsi : 'a t -> f:(int -> 'a -> bool) -> bool

(** Similar to {!Non_empty_list.exists}, but defines a 2 non-empty list quanitifer. *)
val exists2 : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool Or_unequal_lengths.t

val exists2_exn : 'a t -> 'b t -> f:('a -> 'b -> bool) -> bool

(*** Functor, Traversable and Foldable ***********************************************************)

(** [map ~f [x1; ...; xn]] ([n >= 1]) applies [f] to [x1], ..., [xn] (left-to-right order),
    yielding the resultant non-empty list [[f x1; ..., f xn]]. *)
val map : 'a t -> f:('a -> 'b) -> 'b t

(** [rev_map t ~f] is equivalent to [rev (map t ~f)], however, is more efficient. *)
val rev_map : 'a t -> f:('a -> 'b) -> 'b t

(** Similar to {!Non_empty_list.map}, however, the index is passed as an argument to [f] as well. *)
val mapi : 'a t -> f:(int -> 'a -> 'b) -> 'b t

(** Similar to {!Non_empty_list.map}, but defined for 2 non-empty lists. *)
val map2 : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t Or_unequal_lengths.t

(** Analogous to {!Non_empty_list.rev_map}. *)
val rev_map2 : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t Or_unequal_lengths.t

val map2_exn : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t Or_unequal_lengths.t

(** [concat_map t ~f] is equivalent to [concat (map t ~f)]. *)
val concat_map : 'a t -> f:('a -> 'b t) -> 'b t

val concat_mapi : 'a t -> f:(int -> 'a -> 'b t) -> 'b t

(** [iter [x1; ...; xn] ~f] is equivalent to [f x1; ...; f xn] *)
val iter : 'a t -> f:('a -> unit) -> unit

val iteri : 'a t -> f:(int -> 'a -> unit) -> unit

(** [iter2 [x1; ...; xn] [y1; ...; ym] ~f] is equvalent to [f x1 y2; ...; f xn yn].
    Returns [Unequal_lengths] if [m <> n]. *)
val iter2 : 'a t -> 'b t -> f:('a -> 'b -> unit) -> unit Or_unequal_lengths.t

val iter2_exn : 'a t -> 'b t -> f:('a -> 'b -> unit) -> unit

(** [filter t ~f] returns a *list* of elements of [t] that satisfy the predicate [f]. 
    The order is preserved and evaluation is left-to-right. *)
val filter : 'a t -> f:('a -> bool) -> 'a list

val filter_map : 'a t -> f:('a -> 'b option) -> 'b option

val filteri : 'a t -> f:(int -> 'a -> bool) -> 'a list

val filter_mapi : 'a t -> f:(int -> 'a -> 'b option) -> 'b t

(** [rev_filter t ~f] is equivalent to [List.rev (filter t ~f)], however, is more efficient. *)
val rev_filter : 'a t -> f:('a -> bool) -> 'a list

val rev_filter_map : 'a t -> f:('a -> 'b option) -> 'b option

val rev_filter_map : 'a t -> f:('a -> 'b option) -> 'b option

val rev_filter_mapi : 'a t -> f:(int -> 'a -> 'b option) -> 'b t


(** TODO: Remaining comments and documentation *)

val fold_left : 'a t -> init:'b -> f:('b -> 'a -> 'b) -> 'b

val fold_lefti : 'a t -> init:'b -> f:(int -> 'b -> 'a -> 'b) -> 'b

val fold_right : 'a t -> init:'b -> f:('a -> 'b -> 'b) -> 'b

val fold_righti : 'a t -> init:'b -> f:(int -> 'a -> 'b -> 'b) -> 'b

val count : 'a t -> f:('a -> bool) -> int

val counti : 'a t -> f:(int -> 'a -> bool) -> int

val append : 'a t -> 'a t -> 'a t

val concat : 'a t t -> 'a t

val cons : 'a -> 'a t -> 'a t


val zip : 'a t -> 'b t -> ('a * 'b) t Or_unequal_lengths.t
val zip_exn : 'a t -> 'b t -> ('a * 'b) t

val unzip : ('a * 'b) t -> 'a t * 'b t




















