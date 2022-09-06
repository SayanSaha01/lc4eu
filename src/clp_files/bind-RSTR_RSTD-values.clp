;generates output file "mrs_info_with_rstr_rstd_values.dat" and contains information of all the restrictor restricted and MRS relation features values
(defglobal ?*rstr-rstd* = open-rstr)
(defglobal ?*rstr-rstd-dbg* = debug_rstr)

;This rule deletes a fact that belongs to a set id but the fact should not have the max ID and its MRS concept value should not end with "_q". For example, out of the following 3 facts for the phrase 'a new book' in the sentence: "The boy is reading a new book." "f-2' would be deleted.
  ;f-1    (initial_MRS_info id-MRS_concept-LBL-ARG0-RSTR-BODY 21000 _a_q h8 x9 h10 h11)
  ;f-2    (initial_MRS_info id-MRS_concept-LBL-ARG0-ARG1 22000 _new_a_1 h16 x17 x18)
  ;f-3    (initial_MRS_info id-MRS_concept-LBL-ARG0-ARG1 23000 _book_n_of h5 x6 x7)
;Deleting the facts prevents from generating unwanted "Restr-Restricted * *" relations by the "initial-mrs-info" rule.
(defrule rm-mrs-info
(declare (salience 10000))
?f1<-(MRS_info ?rel1 ?id1 ?noendsq  ?lbl1 ?arg  $?arg1)
?f2<-(MRS_info ?rel2 ?id2 ?noendsq1 ?lbl2 ?arg0 $?arg11)
(test (eq (sub-string 1 1 (implode$ (create$ ?id1))) (sub-string 1 1 (implode$ (create$ ?id2)))))
(test (neq (sub-string (- (str-length ?noendsq1)    1) (str-length ?noendsq1) ?noendsq1) "_q"))
(test (neq (sub-string (- (str-length ?noendsq)    1) (str-length ?noendsq) ?noendsq) "_q"))
(test (< ?id2 ?id1))
(test (eq (str-index _v_modal ?noendsq) FALSE))
(test (neq (str-index poss ?noendsq1) FALSE))
=>
(retract ?f1)
(printout ?*rstr-rstd-dbg* "(rule-rel-values  rm-mrs-info  "?rel1 " " ?id1 " " ?noendsq " " ?lbl1 " " ?arg " " (implode$ (create$ $?arg1)) ")"crlf)
)

;Restr-Trstricted fact for mrs concepts like _each_q, _which_q etc
(defrule rstr-rstd4non-implicit
(rel_name-ids ord|cord|dem ?head ?dep)
(MRS_info ?rel2 ?head ?mrsCon ?lbl2 ?ARG_0 $?v)
?f<-(MRS_info ?rel1 ?dep ?endsWith_q ?lbl1 ?x ?rstr $?vars)
(test (neq ?endsWith_q ?mrsCon))
(test (neq ?endsWith_q def_implicit_q))
(test (neq ?endsWith_q def_explicit_q))
(test (or
   (eq (sub-string (- (str-length ?endsWith_q) 1) (str-length ?endsWith_q) ?endsWith_q) "_q")
   (eq (sub-string (- (str-length ?endsWith_q) 3) (str-length ?endsWith_q) ?endsWith_q) "_dem") ) )
(test (neq (sub-string (- (str-length ?mrsCon) 1) (str-length ?mrsCon) ?mrsCon) "_p"))
(not (Restr-Restricted-fact-generated_for_comp ?dep))
=>
(retract ?f)
(printout ?*rstr-rstd* "(Restr-Restricted     "?rstr  "  " ?lbl2 ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values rstr-rstd4non-implicit  Restr-Restricted  "?rstr"  "?lbl2 ")"crlf)

;(printout ?*rstr-rstd*   "(MRS_info  "?rel1 " " ?dep " " ?endsWith_q " " ?lbl1 " " ?ARG_0 " " ?rstr " " (implode$ (create$ $?vars)) ")"crlf)
;(printout ?*rstr-rstd-dbg* "(rule-rel-values rstr-rstd4non-implicit "?rel1 " " ?dep " " ?endsWith_q " " ?lbl1 " "?ARG_0 " " ?rstr " " (implode$ (create$ $?vars)) ")"crlf)
)


;Restr-Trstricted fact for implicit mrs concepts like _a_q, pronoun_q
;	then Generate (Restr-Restricted RSTR_of_*_q LBL_the_other_fact)
;	     Replace ARG0 value of *_q with ARG0 value of the other fact 	
;INPUT sentence: He will help a blind man.
;INPUT facts:
;(MRS_info id-MRS_concept-LBL-ARG0-RSTR-BODY 20010 _a_q h7 x8 h9 h10)
;OUTPUT: 
;(MRS_info id-MRS_concept-LBL-ARG0-RSTR-BODY 20010 _a_q h7 x12 h9 h10)
(defrule mrs-info_q
(MRS_info ?rel2 ?head ?mrsCon ?lbl2 ?ARG_0 $?v)
?f<-(MRS_info ?rel1 ?dep ?endsWith_q ?lbl1 ?x ?rstr $?vars)
(test (neq ?endsWith_q ?mrsCon))
(test (neq ?endsWith_q def_implicit_q))
(test (neq ?endsWith_q def_explicit_q))
(test (eq (sub-string 1 1 (implode$ (create$ ?head))) (sub-string 1 1 (implode$ (create$ ?dep)))))
(test (eq (sub-string (- (str-length ?endsWith_q) 1) (str-length ?endsWith_q) ?endsWith_q) "_q"))
(test (neq (sub-string (- (str-length ?mrsCon) 1) (str-length ?mrsCon) ?mrsCon) "_p"))
(test (neq (sub-string (- (str-length ?mrsCon) 6) (str-length ?mrsCon) ?mrsCon) "_p_temp"))
(not (Restr-Restricted-fact-generated_for_comp ?dep))
=>
(retract ?f)
(printout ?*rstr-rstd* "(Restr-Restricted     "?rstr  "  " ?lbl2 ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values mrs-info_q  Restr-Restricted  "?rstr"  "?lbl2 ")"crlf)
)

;want to bind LBL of '_home_p' with RSTR of 'def_implicit_q
(defrule defimplicitq
?f<-(MRS_info ?rel1 ?id def_implicit_q ?lbl1 ?x ?rstr $?vars)
(MRS_info ?rel2 ?id ?home ?lbl2 ?ARG_0 $?v)
(test (or (eq ?home  _night_n_of)
          (eq ?home  _early_a_1)
          (eq ?home  _now_a_1)
          (eq ?home  _late_p)
          (eq ?home  _home_p)))
=>
(retract ?f)
(printout ?*rstr-rstd* "(Restr-Restricted     "?rstr  "  " ?lbl2 ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values defimplicitq  Restr-Restricted  "?rstr"  "?lbl2 ")"crlf)
)

;want to bind LBL of '_yesterday_a_1|_today_a_1|_tomorrow_a_1' with RSTR of 'def_implicit_q
(defrule dummy
?f<-(MRS_info ?rel1 ?id def_implicit_q ?lbl1 ?x ?rstr $?vars)
(MRS_info ?rel2 ?id _there_a_1|_yesterday_a_1|_today_a_1|_tomorrow_a_1 ?lbl2 ?ARG_0 $?v)
=>
(retract ?f)
(printout ?*rstr-rstd* "(Restr-Restricted     "?rstr  "  " ?lbl2 ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values defimplicitq  Restr-Restricted  "?rstr"  "?lbl2 ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted when neg is present
(defrule LTOP-neg-rstd
(MRS_info ?rel	?id neg ?lbl $?vars)
(not (Restr-Restricted-fact-generated))
=>
(printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values  LTOP-neg-rstd  Restr-Restricted  h0 "?lbl ")"crlf)
)

;Restrictor for ARG1 value of neg and LBL value of predicative adjective
;Ex. rAvaNa acCA nahIM hE.  Ravana is not good.
(defrule neg-pred_adj
(rel_name-ids	k1s	?kri	?adj)
(rel_name-ids	neg	?kri	?neg)
(MRS_info ?rel   ?neg neg ?lbl ?a0 ?a1)
(MRS_info ?rel1  ?adj ?mrs_adj ?l ?arg1 $?v)
(test (neq (str-index _a_ ?mrs_adj) FALSE))
=>
(printout ?*rstr-rstd* "(Restr-Restricted "?a1 " "?l")" crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values  neg-pred_adj  Restr-Restricted "?a1" "?l")"crlf)
)


; written by sakshi yadav (NIT Raipur) date- 02.06.19
;want to bind RSTR of def_explicit_q  with LBL of poss
(defrule defexpq
(rel_name-ids r6	?id  ?id1)
(MRS_info ?rel1 ?idposs poss ?lbl2 ?ARG_0 ?ARG1 ?ARG2)
?f<-(MRS_info ?rel2 ?id_q def_explicit_q ?lbl1 ?x ?rstr $?v)
=>
(retract ?f)
(printout ?*rstr-rstd* "(Restr-Restricted     "?rstr  "  " ?lbl2 ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values defexpq Restr-Restricted  "?rstr"  "?lbl2 ")"crlf)
)


;;Restrictor for LTOP Restrictor-Restricted default value
(defrule LTOP-rstd
(MRS_info ?rel	?id ?mrsCon ?lbl $?vars)
(rel_name-ids	main	0	?id)
(test (neq (str-index _v_ ?mrsCon) FALSE))
(not (Restr-Restricted-fact-generated))
(not (MRS_info ?rel1 ?id1 neg ?lbl1 $?v))
(not (id-causative ?id yes))
(not (id-stative ?id1 yes))
(not (id-double_causative	?id	yes))
(not (rel_name-ids	vmod_seq	?id	?kri_id))
(not (rel_name-ids	vmod_seq	?kri_id	?id))
(not (MRS_info ?rel2 ?id2  _make_v_cause ?lbl2 $?va))
(not(rel_name-ids vAkya_vn ?id_1 ?id_2))
=>
        (printout ?*rstr-rstd* "(Restr-Restricted  h0  "?lbl ")" crlf) 
        (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstd  Restr-Restricted  h0 "?lbl ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted default value vAkya_vn
;Ex. sUrya camakawA BI hE. The sun also shines.
(defrule LTOP-vAkya_vn
(rel_name-ids	vAkya_vn	?id1 ?id2)
(MRS_info id-MRS_concept-LBL-ARG0-ARG1 ?id2 ?mrsalso ?lbl ?arg0 $?vars)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-vAkya_vn Restr-Restricted  h0 "?lbl ")"crlf)
)

;Restrictor for  vAkya_vn
;Ex. sUrya camakawA BI hE. The sun also shines.
(defrule rstr-rstd_vakya_vn
(rel_name-ids vAkya_vn ?id1 ?id2)
(MRS_info ?rel1  ?id1  ?mrsV ?lbl ?arg0 ?arg1 $?var)
(MRS_info ?rel ?id2 ?mrsalso ?lbl1 ?arg10 ?arg20 $?vars)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg20 " "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values rstr-rstd-vAkya_vn Restr-Restricted  "?arg20 " "?lbl ")"crlf)
)


;Restrictor for  vk2
;Ex. sUrya camakawA BI hE. The sun also shines.
(defrule rstr-rstd_vk2
(rel_name-ids	vk2	?main	?vk2)
(MRS_info ?rel1  ?vk2  ?mrsV ?lbl ?arg0 ?arg1 $?var)
(MRS_info ?rel ?main ?mrsalso ?lbl1 ?arg10 ?arg20 ?arg30 $?vars)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg30 " "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values rstr-rstd-vk2 Restr-Restricted  "?arg30 " "?lbl ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted default value causative
(defrule LTOP-rstdc
(id-causative	?id	yes)
(MRS_info ?rel1  ?id  ?mrsV ?lbl1 $?var)
?f<-(MRS_info  id-MRS_concept-LBL-ARG0-ARG1-ARG2 ?id1 _make_v_cause ?lbl ?arg0 ?a1 ?a2)
(test (eq  (+ ?id 100) ?id1))
=>
(retract ?f)
 (printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdc Restr-Restricted  h0 "?lbl ")"crlf)

 (printout ?*rstr-rstd* "(Restr-Restricted  "?a2 " "?lbl1 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdc Restr-Restricted  "?a2 " "?lbl1 ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted default value double causative
(defrule LTOP-rstdd
(id-double_causative	?id	yes)
(MRS_info  id-MRS_concept-LBL-ARG0-ARG1-ARG2-ARG3 ?id1 _ask_v_1 ?lbl ?arg0 $?vars)
(test (eq  (+ ?id 200) ?id1))
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdc Restr-Restricted  h0 "?lbl ")"crlf)
)

;Restrictor for  causative
(defrule LTOP-rstdca
(iiiiiiid-causative       ?id1   yes)
(MRS_info ?rel ?id ?mrsCon ?lbl ?arg0 ?arg1 ?arg2 $?vars)
(MRS_info ?rel1  ?id1  ?mrsV ?lbl1 ?arg10 ?arg11 ?arg12 $?var)
(test (neq ?id ?id1))
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg2 " "?lbl1 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdca Restr-Restricted  "?arg2 " "?lbl1 ")"crlf)
)

;Restrictor for  double-causative
(defrule LTOP-rstdda
(id-double_causative	?id	yes)
(MRS_info  id-MRS_concept-LBL-ARG0-ARG1-ARG2-ARG3 ?id2 _ask_v_1 ?lbl1 ?arg10 ?arg20 ?arg30 ?arg40)
(MRS_info ?rel1  ?id  ?mrsV ?lbl ?arg0 ?arg1 ?arg2 $?var)
(MRS_info  id-MRS_concept-LBL-ARG0-ARG1-ARG2 ?id1 _make_v_cause ?lbl2 ?arg02 ?arg12 ?arg22)
(test (eq  (+ ?id 100) ?id1))
(test (eq  (+ ?id 200) ?id2))
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg40 " "?lbl2 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdda Restr-Restricted  "?arg40 " "?lbl2 ")"crlf)
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg22 " "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdda Restr-Restricted  "?arg12 " "?lbl ")"crlf)
)

(defrule LTOP-rstdsta
(id-stative	?id	yes)
(not (rel_name-ids	vmod_seq	?id	?kri))
(MRS_info  id-MRS_concept-LBL-ARG0-ARG1-ARG2 ?id1 _get_v_state ?lbl ?arg0 $?vars)
(test (eq  (+ ?id 100) ?id1))
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdsta Restr-Restricted  h0 "?lbl ")"crlf)
)

;Restrictor for  stative
(defrule LTOP-rstdst
(id-stative       ?id   yes)
(MRS_info ?rel ?id ?mrsCon ?lbl ?arg0 ?arg1 ?arg2 $?vars)
(MRS_info ?rel1  ?id1  ?mrsV ?lbl1 ?arg10 ?arg11 ?arg12 $?var)
(test (eq ?id1 (+ ?id 100)))
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg12 " "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdst Restr-Restricted  "?arg12 " "?lbl ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted default value subord
(defrule LTOP-subord
(not (id-stative ?id1 yes))
(rel_name-ids	vmod_seq	?id1	?id2)
(MRS_info id-MRS_concept-LBL-ARG0-ARG1-ARG2 -20000 subord ?lbl ?arg0 ?arg1 ?arg2)
(MRS_info ?rel1	?id1 ?mrsCon1 ?lbl1 $?var)
(MRS_info ?rel2	?id2 ?mrsCon2 ?lbl2 $?vars)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0  "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subord Restr-Restricted  h0 "?lbl ")"crlf)

(printout ?*rstr-rstd* "(Restr-Restricted  "?arg2 " "?lbl2 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subord Restr-Restricted  "?arg2 " "?lbl2 ")"crlf)

 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg1 " "?lbl1 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subord Restr-Restricted  "?arg1 " "?lbl1 ")"crlf)
)

(defrule LTOP-subordst
(id-stative ?id1 yes)
(rel_name-ids	vmod_seq	?id1	?id2)
(MRS_info id-MRS_concept-LBL-ARG0-ARG1-ARG2 -20000 subord ?lbl ?arg0 ?arg1 ?arg2)
(MRS_info ?rel1	?id1 ?mrsCon1 ?lbl1 $?var)
(MRS_info ?rel2	?id2 ?mrsCon2 ?lbl2 $?vars)
(MRS_info id-MRS_concept-LBL-ARG0-ARG1-ARG2 ?id3 _get_v_state ?lbl3 $?va)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0  "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subordst Restr-Restricted  h0 "?lbl ")"crlf)

 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg2 " "?lbl2 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subordst Restr-Restricted  "?arg2 " "?lbl2 ")"crlf)

 (printout ?*rstr-rstd* "(Restr-Restricted  "?arg1 " "?lbl3 ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-subordst Restr-Restricted  "?arg1 " "?lbl1 ")"crlf)
)


;(MRS_info id-MRS_concept-LBL-ARG0-ARG1 20100 _should_v_modal h7 e8 h9)
;(MRS_info id-MRS_concept-LBL-ARG0-ARG1 20000 _sleep_v_1 h10 e11 x2)
;;Restrictor for LTOP Restrictor-Restricted default value
(defrule LTOP-modal
(declare (salience 100))
(not (sentence_type	negative))
(not (sentence_type	interrogative))
(MRS_info ?rel  ?id ?mrsModal  ?lbl ?arg0 ?arg1 $?vars)
(MRS_info ?rel1  ?id1 ?mrsV ?lbl1 ?arg01 ?arg11 $?var)
(test (or (neq (str-index _v_modal ?mrsModal) FALSE) (neq (str-index _v_qmodal ?mrsModal) FALSE))) ;_used+to_v_qmodal
(test (neq (str-index _v_ ?mrsV) FALSE))
(test (neq ?id ?id1))
=>
    (assert (Restr-Restricted-fact-generated))
    (printout ?*rstr-rstd* "(Restr-Restricted h0 " ?lbl ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-modal  Restr-Restricted h0 "?lbl ")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg1 " "?lbl1 ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-modal  Restr-Restricted " ?arg1 " "?lbl1 ")"crlf)
)


(defrule LTOP-neg-modal
(declare (salience 100))
(sentence_type	negative)
(MRS_info ?rel  ?id ?mrsModal  ?lbl ?arg0 ?arg1 $?vars)
(MRS_info ?rel1  ?id1 ?mrsV ?lbl1 ?arg01 ?arg11 $?var)
(test (or (neq (str-index _v_modal ?mrsModal) FALSE) (neq (str-index _v_qmodal ?mrsModal) FALSE))) ;_used+to_v_qmodal
(test (neq (str-index _v_ ?mrsV) FALSE))
(test (neq ?id ?id1))
(not (Restr-Restricted-fact-generated))
=>
    (assert (Restr-Restricted-fact-generated))
    (printout ?*rstr-rstd* "(Restr-Restricted h0 " ?lbl ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-neg-modal  Restr-Restricted h0 "?lbl ")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg1 " "?lbl1 ")" crlf)
    (printout ?*rstr-rstd* "(rule-rel-values LTOP-neg-modal  Restr-Restricted " ?arg1 " "?lbl1 ")" crlf)

)

(defrule LTOP-it-modal
(declare (salience 100))
(sentence_type	interrogative)
(MRS_info ?rel  ?id ?mrsModal  ?lbl ?arg0 ?arg1 $?vars)
(MRS_info ?rel1  ?id1 ?mrsV ?lbl1 ?arg01 ?arg11 $?var)
(test (or (neq (str-index _v_modal ?mrsModal) FALSE) (neq (str-index _v_qmodal ?mrsModal) FALSE))) ;_used+to_v_qmodal
(test (neq (str-index _v_ ?mrsV) FALSE))
;(not (MRS_info ? ? neg $?))
(test (neq ?id ?id1))
=>
    (assert (Restr-Restricted-fact-generated))
    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg1 " "?lbl1 ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-int-modal  Restr-Restricted " ?arg1 " "?lbl1 ")"crlf)

)


;rAma sonA cAhawA hE.
;Rama wants to sleep.
(defrule LTOP-nA_cAhawA_hE
(declare (salience 100))
(MRS_info ?rel  ?id ?mrscon  ?lbl ?arg0 ?arg1 $?vars)
(MRS_info ?rel1  ?id1 ?mrsV ?lbl1 ?arg01 ?arg11 ?arg12 $?var)
(kriyA-TAM	?id	nA_cAhawA_hE_1|yA_gayA_1)
(test (neq (str-index _v_ ?mrsV) FALSE))
(test (eq (+ ?id 100) ?id1))
=>
    (assert (Restr-Restricted-fact-generated))
    (printout ?*rstr-rstd* "(Restr-Restricted h0 " ?lbl1 ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-nA_cAhawA_hE  Restr-Restricted h0 "?lbl1 ")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg12 " "?lbl ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-nA_cAhawA_hE  Restr-Restricted " ?arg12 " "?lbl ")"crlf)
)

;for compounds 
;Ex. 307:   usane basa+addA xeKA.
(defrule comp_udefq
(declare (salience 200))
(MRS_info ?rel   ?id  compound  ?cl $?vars)
?f<-(MRS_info ?rel1   ?id1 udef_q    ?ul ?ua0 ?urstr ?ubody)
?f1<-(MRS_info ?rel2  ?id2 ?mrs     ?tl ?ta0 ?trstr ?tbody)
(MRS_info      ?rel3  ?id3 ?dep_mrs  ?dep_lbl $?v)
(test (eq (sub-string 1 1 (str-cat ?id)) (sub-string 1 1 (str-cat ?id1))))
(test (eq (sub-string 1 1 (str-cat ?id)) (sub-string 1 1 (str-cat ?id3))))
(test (eq (+ ?id 998) ?id3))
(test (or (eq ?mrs  _the_q)
          (eq ?mrs  _a_q)))
(not (Restr-Restricted-fact-generated_for_comp ?id1))          
=>
(retract ?f ?f1)
    (assert (Restr-Restricted-fact-generated_for_comp ?id1))
    (assert (Restr-Restricted-fact-generated_for_comp ?id2))

    (printout ?*rstr-rstd* "(Restr-Restricted " ?trstr " "?cl ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values comp_udefq  Restr-Restricted "?trstr " "?cl ")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?urstr " "?dep_lbl ")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values comp_udefq  Restr-Restricted " ?urstr " "?dep_lbl ")"crlf)
)


;Restrictor for LTOP Restrictor-Restricted default value deictic
(defrule LTOP-rstdeic
(rel_name-ids deic ?id1    ?id)
(MRS_info id-MRS_concept-LBL-ARG0 ?id2 generic_entity ?lbl1 ?ARG01)
(MRS_info ?rel1 ?id _this_q_dem ?lbl ?ARG0 ?ARG1 ?ARG2)
=>
(printout ?*rstr-rstd* "(Restr-Restricted  "?ARG1 " "?lbl1 ")" crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdeic Restr-Restricted  "?ARG1 " "?lbl1 ")"crlf)
)


;Restrictor for LTOP Restrictor-Restricted  value deictic adj
(defrule LTOP-rstdeicad
(rel_name-ids deic ?obj    ?dem)
(rel_name-ids	dem	?obj	?dem)
(MRS_info id-MRS_concept-LBL-ARG0-RSTR-BODY ?dem ?mrs ?lbl ?ARG0 ?ARG1 ?ARG2)
(MRS_info ?rel ?obj ?mrs1 ?lbl1 $?var)
=>
(printout ?*rstr-rstd* "(Restr-Restricted  "?ARG1 " "?lbl1 ")" crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdeicad Restr-Restricted  "?ARG1 " "?lbl1 ")"crlf)
)

;Restrictor for LTOP Restrictor-Restricted default value deitic adj
(defrule LTOP-rstdaj
(rel_name-ids deic ?obj    ?dem)
(rel_name-ids	dem	?obj	?dem)
(rel_name-ids	samAnAXi	?obj  ?adj)
(id-guNavAcI	?adj	yes)
(MRS_info ?rel ?adj ?mrs ?lbl $?var)
=>
 (printout ?*rstr-rstd* "(Restr-Restricted  h0 "?lbl ")" crlf)
 (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-rstdc Restr-Restricted  h0 "?lbl ")"crlf)
)

;changing the ARG0 value (i.e. e*) of neg to i300
(defrule neg-arg0-i
(sentence_type  imperative)
(rel_name-ids neg ?kri  ?negId)
?f<-(MRS_info ?rel1 ?negId neg ?lbl ?arg0  ?ARG1)
(not (modified_ARG0_value_to_i ?negId))
=>
(retract ?f)
(assert (modified_ARG0_value_to_i ?negId))
(bind ?i (str-cat "i" (sub-string 2 (str-length ?arg0) ?arg0)))
(assert (MRS_info ?rel1 ?negId neg ?lbl ?i  ?ARG1))
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-arg0-i MRS_info "?rel1" "?negId" neg "?lbl" "?i" " ?ARG1")"crlf)
)



;Restrictor-Restricted between ARG1 value neg and LBL value of verb
;Ex. 236: "ayAn ne KAnA nahIM KAyA WA." = Ayan had not eaten food.
;    25: "ladake ne KAnA nahIM KAyA." = The boy did not eat food.       
(defrule neg-rstd
(rel_name-ids neg ?x    ?negId)
?f<-(MRS_info ?rel1 ?negId neg ?lbl ?  ?ARG1)
?f1<-(MRS_info ?rel3 ?m ?verbORprep ?V_lbl  ?V_A0  ?V_A1 $?vars)
(test (or (neq (str-index _v_ ?verbORprep) FALSE) (neq (str-index _p ?verbORprep) FALSE) ) )
=>
(retract ?f ?f1)
(printout ?*rstr-rstd* "(Restr-Restricted  h0 " ?lbl")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-rstd Restr-Restricted  h0 "?lbl")"crlf)

(printout ?*rstr-rstd* "(Restr-Restricted     "?ARG1  "  " ?V_lbl ")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-rstd Restr-Restricted  "?ARG1"  "?V_lbl")"crlf)
)

; Ex. mEM so nahIM sakawA hUz.
; Ex. I can not sleep. I cannot sleep. I can't sleep.
(defrule neg-modal
(declare (salience 1000))
?f<-(MRS_info ?rel1 ?id1 ?modal ?lbl ?ARG0  ?ARG1)
?f1<-(MRS_info ?rel2 ?id2 neg ?lbl2 ?ARG0_2 ?ARG1_2 $?vars)
?f2<-(MRS_info ?rel3 ?id3 ?v ?lbl3 ?ARG0_3 ?ARG1_3 $?var)
(test (neq (str-index _v_modal ?modal) FALSE))
(test (neq (str-index _v_ ?v) FALSE))
(test (neq ?id1 ?id3))
(test (neq ?id2 ?id3))
=>
(retract ?f ?f1 ?f2)
(printout ?*rstr-rstd* "(Restr-Restricted   h0 " ?lbl2 ")" crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-modal  Restr-Restricted  h0 "?lbl2")"crlf)

(printout ?*rstr-rstd* "(Restr-Restricted     "?ARG1_2" "?lbl")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-modal  Restr-Restricted  "?ARG1_2" "?lbl")"crlf)

(printout ?*rstr-rstd* "(Restr-Restricted     "?ARG1" "?lbl3")"crlf)
(printout ?*rstr-rstd-dbg* "(rule-rel-values neg-modal  Restr-Restricted  "?ARG1" "?lbl3")"crlf)
)

(defrule LTOP-modal-neg-intero
(declare (salience 3000))
(sentence_type     interrogative)
?f2<-(MRS_info ?rel  ?id ?mrsModal  ?lbl ?arg0 ?arg1 $?vars)
?f<-(MRS_info ?rel1  ?id1 ?mrsV ?lbl1 ?arg01 ?arg11 $?var)
?f1<-(MRS_info ?rel2  ?id2 neg ?nl ?n0 ?na1)
(test (or (neq (str-index _v_modal ?mrsModal) FALSE) (neq (str-index _v_qmodal ?mrsModal) FALSE))) ;_used+to_v_qmodal
(test (neq (str-index _v_ ?mrsV) FALSE))
(not (sentence_type     negative))
(test (neq ?id ?id1))
=>
(retract ?f ?f1 ?f2)
    (printout ?*rstr-rstd* "(Restr-Restricted h0 " ?lbl")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-modal-neg-intero  Restr-Restricted h0 "?lbl")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg1 " "?nl")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-modal-neg-intero  Restr-Restricted " ?arg1 " "?nl")"crlf)

    (printout ?*rstr-rstd* "(Restr-Restricted " ?na1 " "?lbl1")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values LTOP-modal-neg-intero  Restr-Restricted " ?na1 " "?lbl1")"crlf)
)


;Rule to generate Rester-Restricted values for the verb want when it takes a verb as k2
;Ex. Rama wants to sleep.
(defrule want-k2-rstr
(rel_name-ids k2   ?kri ?k2)
(MRS_info ?rel ?kri _want_v_1 $?vars ?arg2)
?f1<-(MRS_info ?r ?k2  ?k2v ?l  $?v)
(test (neq (str-index _v_ ?k2v) FALSE))
=>
(retract ?f1)
    (printout ?*rstr-rstd* "(Restr-Restricted " ?arg2 " "?l")" crlf)
    (printout ?*rstr-rstd-dbg* "(rule-rel-values want-k2-rstr  Restr-Restricted " ?arg2 " "?l")"crlf)

)
