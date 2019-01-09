(* Now for the more sophisticated logged-document implementation
   that only stores the current version and a change log.
   Since the log stores changes in reverse order (RCS-style),
   each Insert and Remove entry stores the entry name modified
   and the _original_ value of that entry before the change.
   For this reason the Insert and Remove operations
   can each create two different types of log entries,
   depending on whether or not the named item was already present. *)
theory LogDoc = Undo:

datatype ('a,'b) logentry =
	  LogInsert 'a		(* Insert, not present *)
	| LogUpdate 'a 'b	(* Insert, already present *)
	| LogRemove 'a 'b	(* Remove, present *)
	| LogNull		(* Remove, not present *)

types ('a,'b) logdoc = "('a,'b) dict * ('a,'b) logentry list"

constdefs
	logdoc_cons :: "('a,'b) logdoc"
	"logdoc_cons == (dict_cons, [])" (* Empty document, empty log *)

	logdoc_lookup :: "['a, ('a,'b) logdoc] => 'b option"
	"logdoc_lookup n D == dict_lookup n (fst D)"

	logdoc_insert :: "['a, 'b, ('a,'b) logdoc] => ('a,'b) logdoc"
	"logdoc_insert n v D ==
		(case (logdoc_lookup n D) of
		 None => (dict_insert n v (fst D), LogInsert n # snd D)
		 | Some v' => (dict_insert n v (fst D),
						LogUpdate n v' # snd D))"

	logdoc_remove :: "['a, ('a,'b) logdoc] => ('a,'b) logdoc"
	"logdoc_remove n D ==
		(case logdoc_lookup n D of
		 None => (fst D, LogNull # snd D)
		 | Some v' => (dict_remove n (fst D), LogRemove n v' # snd D))"

	logdoc_version :: "('a,'b) logdoc => nat"
	"logdoc_version D == length (snd D) + 1"

	logdoc_undo :: "('a,'b) logdoc => ('a,'b) logdoc"
	"logdoc_undo D ==
		(case (hd (snd D)) of
			  LogInsert n	=> (dict_remove n (fst D), tl (snd D))
			| LogUpdate n v => (dict_insert n v (fst D), tl (snd D))
			| LogRemove n v => (dict_insert n v (fst D), tl (snd D))
			| LogNull	=> (fst D, tl (snd D)))"

consts
	logdocset :: "('a,'b) logdoc set"
inductive "logdocset"
    intros
	empty:	"logdoc_cons : logdocset"
	insert:	"D : logdocset ==> logdoc_insert n v D : logdocset"
	remove:	"D : logdocset ==> logdoc_remove n D : logdocset"



lemma logdoc_lookup_cons [simp]: "logdoc_lookup n (logdoc_cons) = None"
 by (unfold logdoc_lookup_def logdoc_cons_def, auto)

lemma logdoc_lookup_insert_neq [simp]:
	"n ~= n' ==>
	 logdoc_lookup n (logdoc_insert n' v' D) = logdoc_lookup n D"
 apply (unfold logdoc_lookup_def logdoc_insert_def)
 apply (case_tac "dict_lookup n' (fst D)")
 by (auto)

lemma logdoc_lookup_insert_eq [simp]:
	"logdoc_lookup n (logdoc_insert n v D) = Some v"
 apply (unfold logdoc_lookup_def logdoc_insert_def)
 apply (case_tac "dict_lookup n (fst D)")
 by (auto)

lemma logdoc_lookup_remove_neq [simp]:
	"n ~= n' ==> logdoc_lookup n (logdoc_remove n' D) = logdoc_lookup n D"
 apply (unfold logdoc_lookup_def logdoc_remove_def)
 apply (case_tac "dict_lookup n' (fst D)")
 by (auto)

lemma logdoc_lookup_remove_eq [simp]:
	"n = n' ==> logdoc_lookup n (logdoc_remove n' D) = None"
 apply (unfold logdoc_lookup_def logdoc_remove_def)
 apply (case_tac "dict_lookup n' (fst D)")
 by (auto)

lemma logdoc_lookup_undo_insert [simp]:
	"logdoc_undo (logdoc_insert n v D) = D"
 apply (unfold logdoc_undo_def logdoc_insert_def)
 apply (case_tac "logdoc_lookup n D", auto)
 by (unfold logdoc_lookup_def, auto)

lemma logdoc_lookup_undo_remove [simp]:
	"logdoc_undo (logdoc_remove n D) = D"
 apply (unfold logdoc_undo_def logdoc_remove_def)
 apply (case_tac "logdoc_lookup n D", auto)
 by (unfold logdoc_lookup_def, auto)

lemma logdoc_version_cons [simp]:
	"logdoc_version (logdoc_cons) = 1"
 by (unfold logdoc_version_def logdoc_cons_def, auto)

lemma logdoc_version_insert [simp]:
	"logdoc_version (logdoc_insert n v D) = Suc (logdoc_version D)"
 apply (unfold logdoc_version_def logdoc_insert_def)
 by (case_tac "logdoc_lookup n D", auto)

lemma logdoc_version_remove [simp]:
	"logdoc_version (logdoc_remove n D) = Suc (logdoc_version D)"
 apply (unfold logdoc_version_def logdoc_remove_def)
 by (case_tac "logdoc_lookup n D", auto)

lemma logdoc_version_undo [simp]:
	"1 < logdoc_version D ==>
	 logdoc_version (logdoc_undo D) = logdoc_version D - 1"
 apply (unfold logdoc_version_def logdoc_undo_def, auto)
 by (case_tac "hd (snd D)", auto)

lemma logdocset_undo [rule_format]:
	"D : logdocset ==> 1 < logdoc_version D --> logdoc_undo D : logdocset"
 by (erule logdocset.induct, auto)



(* Define an equivalence relation between the two types,
   using induction over the modification methods. *)
consts
	doc_logdoc_rel :: "(('a,'b) doc * ('a,'b) logdoc) set"

inductive "doc_logdoc_rel"
    intros
	init:	"(doc_cons, logdoc_cons) : doc_logdoc_rel"
	insert:	"(D,L) : doc_logdoc_rel ==>
		 (doc_insert n v D, logdoc_insert n v L) : doc_logdoc_rel"
	remove:	"(D,L) : doc_logdoc_rel ==>
		 (doc_remove n D, logdoc_remove n L) : doc_logdoc_rel"


(* Prove that undo operations are also covered by this relation. *)
lemma "(D,L) : doc_logdoc_rel ==>
	1 < doc_version D --> (doc_undo D, logdoc_undo L) : doc_logdoc_rel"
 by (erule doc_logdoc_rel.induct, auto)

(* Prove that query results are identical after any sequence of operations. *)
theorem "(D,L) : doc_logdoc_rel ==> doc_lookup n D = logdoc_lookup n L"
 apply (erule doc_logdoc_rel.induct)
   apply (simp)
  apply (case_tac "n = na")
  apply (simp_all)
 apply (case_tac "n = na")
 apply (simp_all)
.

lemma "(D,L) : doc_logdoc_rel ==> doc_version D = logdoc_version L"
 by (erule doc_logdoc_rel.induct, auto)


end
