(* Binary tree implementation of the dictionary abstraction *)
theory BinTree = Dict:

datatype ('a,'b) bt = Node "('a,'b) bt" "'a" "'b" "('a,'b) bt" | NoNode

consts
	bt_cons		:: "('a::linorder,'b) bt"
	bt_lookup	:: "['a::linorder, ('a,'b) bt] => 'b option"
	bt_insert	:: "['a::linorder, 'b, ('a,'b) bt] => ('a,'b) bt"
	bt_remove	:: "['a::linorder, ('a,'b) bt] => ('a,'b) bt"
	bt_scan		:: "('a::linorder,'b) bt => ('a * 'b) set"

	(* Internal helpers *)
	bt_merge	:: "[('a::linorder,'b) bt, ('a,'b) bt] => ('a,'b) bt"
	bt_ltall	:: "['a::linorder, ('a,'b) bt] => bool"
	bt_gtall	:: "['a::linorder, ('a,'b) bt] => bool"
	bt_sorted	:: "('a::linorder,'b) bt => bool"

defs
	bt_cons_def:
		"bt_cons == NoNode"

primrec
	"bt_lookup n' (Node l n v r) =
		(if n' = n	then Some v
		 else if n' < n	then bt_lookup n' l
				else bt_lookup n' r)"
	"bt_lookup n' (NoNode) = None"

primrec
	"bt_insert n' v' (Node l n v r) =
		(if n' = n	then Node l n v' r
		 else if n' < n	then Node (bt_insert n' v' l) n v r
				else Node l n v (bt_insert n' v' r))"
	"bt_insert n' v' (NoNode) = Node NoNode n' v' NoNode"

primrec
	bt_remove_Node:
	"bt_remove n' (Node l n v r) =
		(if n' = n	then bt_merge l r
		 else if n' < n	then Node (bt_remove n' l) n v r
				else Node l n v (bt_remove n' r))"
	"bt_remove n' (NoNode) = NoNode"

primrec
	"bt_merge (Node l n v r) y = Node l n v (bt_merge r y)"
	"bt_merge NoNode y = y"

primrec
	"bt_scan (Node l n v r) = {(n,v)} Un bt_scan l Un bt_scan r"
	"bt_scan (NoNode) = {}"

consts
	btset :: "('a::linorder,'b) bt set"
inductive "btset"
    intros
	empty:	"bt_cons : btset"
	insert:	"D : btset ==> bt_insert n v D : btset"
	remove:	"D : btset ==> bt_remove n D : btset"

declare btset.empty [simp]



(* Prove that insertion and removal operations
   preserve the critical ordering invariants. *)
primrec
	"bt_ltall n' (Node l n v r) =
		(n' < n & bt_ltall n' l & bt_ltall n' r)"
	"bt_ltall n' (NoNode) = True"
primrec
	"bt_gtall n' (Node l n v r) =
		(n < n' & bt_gtall n' l & bt_gtall n' r)"
	"bt_gtall n' (NoNode) = True"
primrec
	"bt_sorted (Node l n v r) = 
		(bt_gtall n l & bt_sorted l &
		 bt_ltall n r & bt_sorted r)"
	"bt_sorted (NoNode) = True"

lemma bt_sorted_cons [simp]: "bt_sorted bt_cons"
 by (unfold bt_cons_def, auto)

lemma bt_ltall_insert [rule_format, intro]:
	"a < n ==> bt_ltall a D --> bt_ltall a (bt_insert n v D)"
 by (induct_tac D, auto)

lemma bt_gtall_insert [rule_format, intro]:
	"n < a ==> bt_gtall a D --> bt_gtall a (bt_insert n v D)"
 by (induct_tac D, auto)

lemma bt_sorted_insert [rule_format, intro]:
	"bt_sorted D --> bt_sorted (bt_insert n v D)"
 apply (induct_tac D, auto)
 apply (rule bt_ltall_insert, auto)
 apply (simp add: linorder_not_less)
 apply (simp add: order_less_le)
 by (auto)

lemma bt_ltall_merge [rule_format, intro]:
	"(bt_ltall a D1 & bt_ltall a D2) --> bt_ltall a (bt_merge D1 D2)"
 by (induct_tac D1, auto)

lemma bt_gtall_merge [rule_format, intro]:
	"(bt_gtall a D1 & bt_gtall a D2) --> bt_gtall a (bt_merge D1 D2)"
 by (induct_tac D1, auto)

lemma bt_ltall_remove [rule_format, intro]:
	"a < n ==> bt_ltall a D --> bt_ltall a (bt_remove n D)"
 by (induct_tac D, auto)

lemma bt_gtall_remove [rule_format, intro]:
	"n < a ==> bt_gtall a D --> bt_gtall a (bt_remove n D)"
 by (induct_tac D, auto)

lemma bt_ltall_trans [rule_format]:
	"a < b ==> bt_ltall b D --> bt_ltall a D"
 apply (induct_tac D, auto)
 by (erule order_less_trans, simp)

lemma bt_gtall_trans [rule_format]:
	"a < b ==> bt_gtall a D --> bt_gtall b D"
 apply (induct_tac D, auto)
 by (erule order_less_trans, simp)
 
lemma bt_sorted_merge [rule_format, intro]:
	"(bt_sorted D1 & bt_gtall a D1 &
	  bt_sorted D2 & bt_ltall a D2) --> bt_sorted (bt_merge D1 D2)"
 apply (induct_tac D1, auto)
 apply (rule bt_ltall_merge, simp)
 by (rule bt_ltall_trans, auto)

lemma bt_sorted_remove [rule_format, intro]:
	"bt_sorted D --> bt_sorted (bt_remove n D)"
 apply (induct_tac D, auto)
 apply (rule bt_ltall_remove, auto)
 apply (simp add: linorder_not_less)
 apply (simp add: order_less_le)
 by (auto)
 
lemma btset_sorted: "D : btset ==> bt_sorted D"
 apply (erule btset.induct)
 apply (unfold bt_cons_def, simp)
 apply (rule bt_sorted_insert, simp)
 by (rule bt_sorted_remove, simp)


(* Prove that all the basic properties of dictionaries hold *)

lemma bt_remove_cons [simp]:
	"bt_remove n (bt_cons) = bt_cons"
 by (unfold bt_cons_def, auto)

lemma bt_lookup_cons [simp]:
	"bt_lookup n (bt_cons) = None"
 by (unfold bt_cons_def, auto)

lemma bt_lookup_ltall [simp]:
	"bt_ltall n D --> bt_lookup n D = None"
 by (induct_tac D, auto)

lemma bt_lookup_gtall [simp]:
	"bt_gtall n D --> bt_lookup n D = None"
 by (induct_tac D, auto)

lemma bt_lookup_insert_neq [simp]:
	"n ~= n' ==> bt_lookup n (bt_insert n' v' D) = bt_lookup n D"
 by (induct_tac D, auto)

lemma bt_lookup_insert_eq [simp]:
	"bt_lookup n (bt_insert n v D) = Some v"
 by (induct_tac D, auto)

lemma bt_lookup_merge1 [simp]:
	"bt_ltall n D2 ==> bt_lookup n (bt_merge D1 D2) = bt_lookup n D1"
 by (induct_tac D1, auto)

lemma bt_lookup_merge2 [rule_format, simp]:
	"bt_gtall n D1 --> bt_lookup n (bt_merge D1 D2) = bt_lookup n D2"
 apply (induct_tac D1, auto)
 by (drule order_less_not_sym, simp)

lemma bt_lookup_remove_neq [rule_format, simp]:
	"n ~= n'
	 ==> bt_sorted D --> bt_lookup n (bt_remove n' D) = bt_lookup n D"
 apply (induct_tac D, auto)
 apply (rule bt_lookup_merge1, erule bt_ltall_trans, simp)
 apply (rule bt_lookup_merge2, rule bt_gtall_trans, auto)
 by (simp add: linorder_neq_iff)

lemma bt_lookup_remove_eq [rule_format, simp]:
	"bt_sorted D --> bt_lookup n (bt_remove n D) = None"
 by (induct_tac D, auto)



(* Define a simulation relation between the concrete and abstract types,
   using induction over all the modification methods. *)
consts
	dict_bt_rel :: "(('a::linorder,'b) dict * ('a,'b) bt) set"
inductive "dict_bt_rel"
    intros
	init:	"(dict_cons, bt_cons) : dict_bt_rel"
	insert:	"(D,T) : dict_bt_rel
		 ==> (dict_insert n v D, bt_insert n v T) : dict_bt_rel"
	remove:	"(D,T) : dict_bt_rel
		 ==> (dict_remove n D, bt_remove n T) : dict_bt_rel"


(* Prove that the outputs are consistent for all possible input sequences. *)
theorem "(D,T) : dict_bt_rel ==> dict_lookup n D = bt_lookup n T"
 apply (erule dict_bt_rel.induct)
   apply (simp)
  apply (case_tac "n = na", simp_all)
 apply (subgoal_tac "bt_sorted T")
  apply (case_tac "n = na", simp_all)
 by (erule dict_bt_rel.induct, auto)



end
