(* Simple list-based implementation of a dictionary data type *)
theory ListDict = Dict:

types ('a,'b) listdict = "('a * 'b) list"

constdefs
	ld_cons :: "('a,'b) listdict"
	"ld_cons == []"

	ld_remove :: "['a, ('a,'b) listdict] => ('a,'b) listdict"
	"ld_remove n D == filter (%(n',v). (n' ~= n)) D"

	ld_insert :: "['a, 'b, ('a,'b) listdict] => ('a,'b) listdict"
	"ld_insert n v D == (n,v) # ld_remove n D"

	ld_lookup :: "['a, ('a,'b) listdict] => 'b option"
	"ld_lookup n D ==
		(if (EX v. ((n,v) : set D))
		 then Some (SOME v. ((n,v) : set D))
		 else None)"

	ld_equiv :: "[('a,'b) listdict, ('a,'b) listdict] => bool"
	"ld_equiv D D' == !n. ld_lookup n D = ld_lookup n D'"


lemma ld_lookup_empty [simp]: "ld_lookup n (ld_cons) = None"
 by (unfold ld_lookup_def ld_cons_def, auto)

lemma ld_lookup_insert_neq [simp]:
	"n ~= n' ==> ld_lookup n (ld_insert n' v' D) = ld_lookup n D"
 by (unfold ld_lookup_def ld_insert_def ld_remove_def, auto)

lemma ld_lookup_insert_eq [simp]:
	"ld_lookup n (ld_insert n v D) = Some v"
 by (unfold ld_lookup_def ld_insert_def ld_remove_def, auto)

lemma ld_lookup_remove_neq [simp]:
	"n ~= n' ==> ld_lookup n (ld_remove n' D) = ld_lookup n D"
 by (unfold ld_lookup_def ld_remove_def, auto)

lemma ld_lookup_remove_eq [simp]:
	"n = n' ==> ld_lookup n (ld_remove n' D) = None"
 by (unfold ld_lookup_def ld_remove_def, auto)

lemma ld_equiv_eq [simp]: "ld_equiv D D"
 by (unfold ld_equiv_def, auto)

(* Re-inserting the current value of an existing item
   results in an equivalent dictionary. *)
lemma ld_equiv_insert_lookup:
	"ld_lookup n D = Some v ==> ld_equiv D (ld_insert n v D)"
 apply (unfold ld_equiv_def, auto)
 by (case_tac "na = n", auto)

lemma ld_lookup_equiv:
	"ld_equiv D D' ==> ld_lookup n D = ld_lookup n D'"
 by (unfold ld_equiv_def, auto)


(* Now for the correctness verification stuff. *)


(* Define an equivalence relation between the two types,
   using induction over the modification methods. *)
consts
	dict_ld_rel :: "(('a,'b) dict * ('a,'b) listdict) set"
inductive "dict_ld_rel"
    intros
	init:	"(dict_cons, ld_cons) : dict_ld_rel"
	insert:	"(D,L) : dict_ld_rel
		 ==> (dict_insert n v D, ld_insert n v L) : dict_ld_rel"
	remove:	"(D,L) : dict_ld_rel
		 ==> (dict_remove n D, ld_remove n L) : dict_ld_rel"


(* Now we have to prove that after any sequence of modifications,
   the result of each query method is the same
   for the basic dictionary and the hash table. *)
theorem "(D,L) : dict_ld_rel ==> dict_lookup n D = ld_lookup n L"
 apply (erule dict_ld_rel.induct)
   apply (simp)
  apply (case_tac "n = na")
  apply (simp_all)
 apply (case_tac "n = na")
 apply (simp_all)
.


end
