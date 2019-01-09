(* Abstract behavior specification, implementation, and correctness proof
   for simple hash tables. *)
theory Hash = Dict:


(* Now for the hash table model itself.
   A hash table is simply a vector of dictionaries;
   the vector's length is fixed over the lifetime of the hashtable.
   (Obvious follow-on improvement: growable hash tables.)
   The hash function to be used is parameterized;
   any function will work (as far as correctness goes)
   as long as it returns indexes within the correct range.
   The hash function should really be encapsulated in the hash table itself,
   but for now we'll be lazy and simply include it as a separate parameter
   to all of the hash table manipulation methods. *)

types 'a hashfunc = "'a => nat";

types ('a,'b) hashtab = "('a,'b) dict list";


constdefs
	ht_cons :: "nat => ('a,'b) hashtab"
	"ht_cons l == SOME H. (length H = l &
				(ALL i. (i < l --> H!i = dict_cons)))"

constdefs
	ht_remove :: "['a, ('a,'b) hashtab, 'a hashfunc] => ('a,'b) hashtab"
	"ht_remove n H F == list_update H (F n) (dict_remove n (H!(F n)))"

	ht_insert :: "['a, 'b, ('a,'b) hashtab, 'a hashfunc] => ('a,'b) hashtab"
	"ht_insert n v H F == list_update H (F n) (dict_insert n v (H!(F n)))"

	ht_lookup :: "['a, ('a,'b) hashtab, 'a hashfunc] => 'b option"
	"ht_lookup n H F == dict_lookup n (H!(F n))"


lemma ht_cons_ex: "EX H. (length H = l & (ALL i. (i < l --> H!i = dict_cons)))"
 apply (induct_tac l)
  apply (simp)
 apply (rule_tac x = "dict_cons # ht_cons n" in exI)
 apply (unfold ht_cons_def)
 apply (rule someI2_ex)
  apply (simp)
 apply (auto)
 apply (case_tac ia)
 by (simp_all)

lemma ht_cons_length [simp]: "length (ht_cons l) = l"
 apply (unfold ht_cons_def)
 apply (rule someI2_ex)
 apply (rule ht_cons_ex)
 by (auto)

lemma ht_cons_nth [simp]: "i < l ==> ht_cons l ! i = dict_cons"
 apply (unfold ht_cons_def)
 apply (rule someI2_ex)
 apply (rule ht_cons_ex)
 by (auto)

lemma ht_insert_length [simp]:
	"length (ht_insert n v H F) = length H"
 by (unfold ht_insert_def, auto)

lemma ht_remove_length [simp]:
	"length (ht_remove n H F) = length H"
 by (unfold ht_remove_def, auto)

lemma ht_lookup_empty [simp]:
	"!i. F i < l ==> ht_lookup n (ht_cons l) F = None"
 by (unfold ht_lookup_def, auto)

lemma ht_lookup_insert_neq [simp]:
	"[| !i. F i < length H; n ~= n' |]
	 ==> ht_lookup n (ht_insert n' v' H F) F = ht_lookup n H F"
 apply (unfold ht_lookup_def ht_insert_def)
 apply (case_tac "F n' ~= F n") 
 by (simp_all)

lemma ht_lookup_insert_eq [simp]:
	"[| !i. F i < length H |]
	 ==> ht_lookup n (ht_insert n v H F) F = Some v"
 by (unfold ht_lookup_def ht_insert_def, auto)

lemma ht_lookup_remove_neq [simp]:
	"[| !i. F i < length H; n ~= n' |]
	 ==> ht_lookup n (ht_remove n' H F) F = ht_lookup n H F"
 apply (unfold ht_lookup_def ht_remove_def)
 apply (case_tac "F n' ~= F n") 
 by (simp_all)

lemma ht_lookup_remove_eq [simp]:
	"[| !i. F i < length H |]
	 ==> ht_lookup n (ht_remove n H F) F = None"
 by (unfold ht_lookup_def ht_remove_def, auto)



(* Now for the correctness verification stuff. *)


(* Define an equivalence relation between the two types,
   using induction over the modification methods. *)
consts
	dict_ht_rel :: "(('a,'b) dict * ('a,'b) hashtab * 'a hashfunc) set"
inductive "dict_ht_rel"
    intros
	init:	"ALL n. (F n < l) ==> (dict_cons, ht_cons l, F) : dict_ht_rel"
	insert:	"(D,H,F) : dict_ht_rel
		 ==> (dict_insert n v D, ht_insert n v H F, F) : dict_ht_rel"
	remove:	"(D,H,F) : dict_ht_rel
		 ==> (dict_remove n D, ht_remove n H F, F) : dict_ht_rel"


(* Now we have to prove that after any sequence of modifications,
   the result of each query method is the same
   for the basic dictionary and the hash table. *)
lemma dict_ht_rel_length: "(D,H,F) : dict_ht_rel ==> F i < length H"
 by (erule dict_ht_rel.induct, auto)

theorem "(D,H,F) : dict_ht_rel ==> dict_lookup n D = ht_lookup n H F"
 apply (erule dict_ht_rel.induct)
   apply (simp)
  apply (case_tac "n = na")
  apply (simp_all add: dict_ht_rel_length)
 apply (case_tac "n = na")
 apply (simp_all add: dict_ht_rel_length)
.


(* Attic


*)

end
