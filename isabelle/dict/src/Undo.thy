(* Abstract specification, implementation, and correctness proof
   for a simple document revision control system.
   A "document" for our purposes is a dictionary (set of name-value pairs);
   the "change" operations supported are insert(/replace) and remove.
   Each change increments the document's version number,
   which is simply a natural number that starts at 1 and increases. *)
theory Undo = Dict:


(* First the model for the desired behavior -
   we want the system to work as if it stored each version independently,
   so that's what we do in the abstract model.
   For convenience we store the current (head) version first in the list,
   which means the version numbers correspond inversely to list indexes. *)

types ('a,'b) doc = "('a,'b) dict list"

constdefs
	doc_cons :: "('a,'b) doc"
	"doc_cons == [dict_cons]"	(* One version, empty document *)

	doc_insert :: "['a, 'b, ('a,'b) doc] => ('a,'b) doc"
	"doc_insert n v D == dict_insert n v (hd D) # D"

	doc_remove :: "['a, ('a,'b) doc] => ('a,'b) doc"
	"doc_remove n D == dict_remove n (hd D) # D"

	doc_lookup :: "['a, ('a,'b) doc] => 'b option"
	"doc_lookup n D == dict_lookup n (hd D)"

	doc_version :: "('a,'b) doc => nat"
	"doc_version D == length D"

	doc_undo :: "[('a,'b) doc] => ('a,'b) doc"
	"doc_undo D == tl D"


consts
	docset :: "('a,'b) doc set"
inductive "docset"
    intros
	empty:	"doc_cons : docset"
	insert:	"D : docset ==> doc_insert n v D : docset"
	remove:	"D : docset ==> doc_remove n D : docset"


lemma doc_lookup_cons [simp]: "doc_lookup n (doc_cons) = None"
 by (unfold doc_lookup_def doc_cons_def, auto)

lemma doc_lookup_insert_neq [simp]:
	"n ~= n' ==> doc_lookup n (doc_insert n' v' D) = doc_lookup n D"
 by (unfold doc_lookup_def doc_insert_def doc_remove_def, auto)

lemma doc_lookup_insert_eq [simp]:
	"doc_lookup n (doc_insert n v D) = Some v"
 by (unfold doc_lookup_def doc_insert_def doc_remove_def, auto)

lemma doc_lookup_remove_neq [simp]:
	"n ~= n' ==> doc_lookup n (doc_remove n' D) = doc_lookup n D"
 by (unfold doc_lookup_def doc_remove_def doc_remove_def, auto)

lemma doc_lookup_remove_eq [simp]:
	"n = n' ==> doc_lookup n (doc_remove n' D) = None"
 by (unfold doc_lookup_def doc_remove_def doc_remove_def, auto)

lemma doc_version_cons [simp]:
	"doc_version (doc_cons) = 1"
 by (unfold doc_version_def doc_cons_def, auto)

lemma doc_version_insert [simp]:
	"doc_version (doc_insert n v D) = Suc (doc_version D)"
 by (unfold doc_version_def doc_insert_def, auto)

lemma doc_version_remove [simp]:
	"doc_version (doc_remove n D) = Suc (doc_version D)"
 by (unfold doc_version_def doc_remove_def, auto)

lemma doc_version_undo [simp]:
	"1 < doc_version D ==> doc_version (doc_undo D) = doc_version D - 1"
 by (unfold doc_version_def doc_undo_def, auto)

lemma doc_undo_insert [simp]:
	"doc_undo (doc_insert n v D) = D"
 by (unfold doc_undo_def doc_version_def doc_insert_def, auto)

lemma doc_undo_remove [simp]:
	"doc_undo (doc_remove n D) = D"
 by (unfold doc_undo_def doc_version_def doc_remove_def, auto)

lemma docset_undo [rule_format]:
	"D : docset ==> 1 < doc_version D --> doc_undo D : docset"
 by (erule docset.induct, auto)



end
