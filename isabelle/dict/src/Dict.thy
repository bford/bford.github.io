(* Abstract model for a simple dictionary data type,
   which acts as a generic collection of name-value pairs.
   The supported operations are insert, remove, lookup, and scan. *)
theory Dict = Main:

types ('a,'b) dict = "'a => 'b option"

constdefs
	dict_cons :: "('a,'b) dict"
	"dict_cons == (%n. None)"

	dict_insert :: "['a, 'b, ('a,'b) dict] => ('a,'b) dict"
	"dict_insert n v D == (%n'. if n' = n then Some v else D n')"

	dict_remove :: "['a, ('a,'b) dict] => ('a,'b) dict"
	"dict_remove n D == (%n'. if n' = n then None else D n')"

	dict_lookup :: "['a, ('a,'b) dict] => 'b option"
	"dict_lookup n D == D n"

	dict_scan :: "('a,'b) dict => ('a * 'b) set"
	"dict_scan D == {(n,v). D n = Some v}"

consts
	dictset :: "('a,'b) dict set"
inductive "dictset"
    intros
	empty:	"dict_cons : dictset"
	insert:	"[| D : dictset; dict_lookup n D = None |]
		 ==> dict_insert n v D : dictset"

declare dictset.empty [simp]


(* Basic properties of dictionaries -
   these theorems could be the axioms in an axiomatic definition. *)

lemma dict_remove_cons [simp]:
	"dict_remove n dict_cons = dict_cons"
 by (unfold dict_remove_def dict_cons_def, auto)

lemma dict_lookup_cons [simp]:
	"dict_lookup n (dict_cons) = None"
 by (unfold dict_lookup_def dict_cons_def, auto)

lemma dict_lookup_insert_neq [simp]:
	"n ~= n' ==> dict_lookup n (dict_insert n' v' D) = dict_lookup n D"
 by (unfold dict_lookup_def dict_insert_def, auto)

lemma dict_lookup_insert_eq [simp]:
	"dict_lookup n (dict_insert n v D) = Some v"
 by (unfold dict_lookup_def dict_insert_def, auto)

lemma dict_lookup_remove_neq [simp]:
	"n ~= n' ==> dict_lookup n (dict_remove n' D) = dict_lookup n D"
 by (unfold dict_lookup_def dict_remove_def, auto)

lemma dict_lookup_remove_eq [simp]:
	"dict_lookup n (dict_remove n D) = None"
 by (unfold dict_lookup_def dict_remove_def, auto)

(* Inserting a new value over an existing item replaces the old one. *)
lemma dict_insert_insert [simp]:
	"dict_insert n v (dict_insert n v' D) = dict_insert n v D"
 by (unfold dict_insert_def, rule ext, auto)

lemma dict_insert_remove [simp]:
	"dict_insert n v (dict_remove n D) = dict_insert n v D"
 by (unfold dict_insert_def dict_remove_def, rule ext, auto)

lemma dict_remove_insert [simp]:
	"dict_remove n (dict_insert n v' D) = dict_remove n D"
 by (unfold dict_insert_def dict_remove_def, rule ext, auto)

lemma dict_insert_redundant [simp]:
	"dict_lookup n D = Some v ==> dict_insert n v D = D"
 by (unfold dict_lookup_def dict_insert_def, rule ext, auto)

lemma dict_remove_redundant [simp]:
	"dict_lookup n D = None ==> dict_remove n D = D"
 by (unfold dict_lookup_def dict_remove_def, rule ext, auto)

lemma dict_scan_cons [simp]: "dict_scan dict_cons = {}"
 by (unfold dict_scan_def dict_cons_def, auto)

lemma dict_scan_remove:
	"dict_scan (dict_remove n D) =
		{(n',v'). (n',v') : dict_scan D & n' ~= n}"
 apply (unfold dict_scan_def dict_remove_def, auto)
 by (case_tac "x = n", auto)

lemma dict_scan_insert:
	"dict_scan (dict_insert n v D) =
		insert (n,v) {(n',v'). (n',v') : dict_scan D & n' ~= n}"
 apply (unfold dict_scan_def dict_insert_def, auto)
 by (case_tac "x = n", auto)


(* Proofs that order of operations for different items does not matter. *)
lemma dict_insert_insert_assoc:
	"[| n ~= n'; P(dict_insert n v (dict_insert n' v' D)) |]
	 ==> P(dict_insert n' v' (dict_insert n v D))"
 apply (rule_tac P = P in subst, simp_all)
 by (unfold dict_insert_def, rule ext, auto)

lemma dict_insert_remove_assoc:
	"[| n ~= n'; P(dict_remove n (dict_insert n' v' D)) |]
	 ==> P(dict_insert n' v' (dict_remove n D))"
 apply (rule_tac P = P in subst, simp_all)
 by (unfold dict_insert_def dict_remove_def, rule ext, auto)

lemma dict_remove_insert_assoc:
	"[| n ~= n'; P(dict_insert n v (dict_remove n' D)) |]
	 ==> P(dict_remove n' (dict_insert n v D))"
 apply (rule_tac P = P in subst, simp_all)
 by (unfold dict_insert_def dict_remove_def, rule ext, auto)


(* Proofs that dictset is closed over insert and remove operations *)
lemma dictset_insert: "D : dictset ==> dict_insert n v D : dictset"
 apply (erule dictset.induct)
  apply (rule dictset.insert)
   apply (simp)
  apply (simp)
 apply (case_tac "na = n", simp)
 apply (rule dict_insert_insert_assoc)
  apply (force)
 by (rule dictset.insert, auto)
 
lemma dictset_remove: "D : dictset ==> dict_remove n D : dictset"
 apply (erule dictset.induct, simp)
 apply (case_tac "n = na", simp)
 apply (rule dict_remove_insert_assoc, force)
 by (auto intro: dictset_insert)
 


end
