(* -*- coding: utf-8 -*- *)
(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2012     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* File Eqdep.v created by Christine Paulin-Mohring in Coq V5.6, May 1992 *)
(* Further documentation and variants of eq_rect_eq by Hugo Herbelin,
   Apr 2003 *)
(* Abstraction with respect to the eq_rect_eq axiom and renaming to
   EqdepFacts.v by Hugo Herbelin, Mar 2006 *)
(* Modified by Jason Gross to not need full decidable equality on all pairs, April 2013 *)

(** This file defines dependent equality and shows its equivalence with
    equality on dependent pairs (inhabiting sigma-types). It derives
    the consequence of axiomatizing the invariance by substitution of
    reflexive equality proofs and shows the equivalence between the 4
    following statements

    - Invariance by Substitution of Reflexive Equality Proofs.
    - Injectivity of Dependent Equality
    - Uniqueness of Identity Proofs
    - Uniqueness of Reflexive Identity Proofs
    - Streicher's Axiom K

  These statements are independent of the calculus of constructions [2].

  References:

  [1] T. Streicher, Semantical Investigations into Intensional Type Theory,
      Habilitationsschrift, LMU MÃ¼nchen, 1993.
  [2] M. Hofmann, T. Streicher, The groupoid interpretation of type theory,
      Proceedings of the meeting Twenty-five years of constructive
      type theory, Venice, Oxford University Press, 1998

Table of contents:

1. Definition of dependent equality and equivalence with equality of
   dependent pairs and with dependent pair of equalities

2. Eq_rect_eq <-> Eq_dep_eq <-> UIP <-> UIP_refl <-> K

3. Definition of the functor that builds properties of dependent
   equalities assuming axiom eq_rect_eq

*)

(************************************************************************)
(** * Definition of dependent equality and equivalence with equality of dependent pairs *)

Import EqNotations.

Section Dependent_Equality.

  Variable U : Type.
  Variable P : U -> Type.

  (** Dependent equality *)

  Inductive eq_dep (p:U) (x:P p) : forall q:U, P q -> Prop :=
    eq_dep_intro : eq_dep p x p x.
  Hint Constructors eq_dep: core.

  Lemma eq_dep_refl : forall (p:U) (x:P p), eq_dep p x p x.
  Proof eq_dep_intro.

  Lemma eq_dep_sym :
    forall (p q:U) (x:P p) (y:P q), eq_dep p x q y -> eq_dep q y p x.
  Proof.
    destruct 1; auto.
  Qed.
  Hint Immediate eq_dep_sym: core.

  Lemma eq_dep_trans :
    forall (p q r:U) (x:P p) (y:P q) (z:P r),
      eq_dep p x q y -> eq_dep q y r z -> eq_dep p x r z.
  Proof.
    destruct 1; auto.
  Qed.

  Scheme eq_indd := Induction for eq Sort Prop.

  (** Equivalent definition of dependent equality as a dependent pair of
      equalities *)

  Inductive eq_dep1 (p:U) (x:P p) (q:U) (y:P q) : Prop :=
    eq_dep1_intro : forall h:q = p, x = rew h in y -> eq_dep1 p x q y.

  Lemma eq_dep1_dep :
    forall (p:U) (x:P p) (q:U) (y:P q), eq_dep1 p x q y -> eq_dep p x q y.
  Proof.
    destruct 1 as (eq_qp, H).
    destruct eq_qp using eq_indd.
    rewrite H.
    apply eq_dep_intro.
  Qed.

  Lemma eq_dep_dep1 :
    forall (p q:U) (x:P p) (y:P q), eq_dep p x q y -> eq_dep1 p x q y.
  Proof.
    destruct 1.
    apply eq_dep1_intro with (eq_refl p).
    simpl; trivial.
  Qed.

End Dependent_Equality.

Arguments eq_dep  [U P] p x q _.
Arguments eq_dep1 [U P] p x q y.

(** Dependent equality is equivalent to equality on dependent pairs *)

Lemma eq_sigT_eq_dep :
  forall (U:Type) (P:U -> Type) (p q:U) (x:P p) (y:P q),
    existT P p x = existT P q y -> eq_dep p x q y.
Proof.
  intros.
  dependent rewrite H.
  apply eq_dep_intro.
Qed.

Notation eq_sigS_eq_dep := eq_sigT_eq_dep (compat "8.2"). (* Compatibility *)

Lemma eq_dep_eq_sigT :
  forall (U:Type) (P:U -> Type) (p q:U) (x:P p) (y:P q),
    eq_dep p x q y -> existT P p x = existT P q y.
Proof.
  destruct 1; reflexivity.
Qed.

Lemma eq_sigT_iff_eq_dep :
  forall (U:Type) (P:U -> Type) (p q:U) (x:P p) (y:P q),
    existT P p x = existT P q y <-> eq_dep p x q y.
Proof.
  split; auto using eq_sigT_eq_dep, eq_dep_eq_sigT.
Qed.

Notation equiv_eqex_eqdep := eq_sigT_iff_eq_dep (only parsing). (* Compat *)

Lemma eq_sig_eq_dep :
  forall (U:Prop) (P:U -> Prop) (p q:U) (x:P p) (y:P q),
    exist P p x = exist P q y -> eq_dep p x q y.
Proof.
  intros.
  dependent rewrite H.
  apply eq_dep_intro.
Qed.

Lemma eq_dep_eq_sig :
  forall (U:Prop) (P:U -> Prop) (p q:U) (x:P p) (y:P q),
    eq_dep p x q y -> exist P p x = exist P q y.
Proof.
  destruct 1; reflexivity.
Qed.

Lemma eq_sig_iff_eq_dep :
  forall (U:Prop) (P:U -> Prop) (p q:U) (x:P p) (y:P q),
    exist P p x = exist P q y <-> eq_dep p x q y.
Proof.
  split; auto using eq_sig_eq_dep, eq_dep_eq_sig.
Qed.

(** Dependent equality is equivalent to a dependent pair of equalities *)

Set Implicit Arguments.

Lemma eq_sigT_sig_eq : forall X P (x1 x2:X) H1 H2, existT P x1 H1 = existT P x2 H2 <-> {H:x1=x2 | rew H in H1 = H2}.
Proof.
  intros; split; intro H.
  - change x2 with (projT1 (existT P x2 H2)).
    change H2 with (projT2 (existT P x2 H2)) at 5.
    destruct H. simpl.
    exists eq_refl.
    reflexivity.
  - destruct H as (->,<-).
    reflexivity.
Defined.

Lemma eq_sigT_fst :
  forall X P (x1 x2:X) H1 H2 (H:existT P x1 H1 = existT P x2 H2), x1 = x2.
Proof.
  intros.
  change x2 with (projT1 (existT P x2 H2)).
  destruct H.
  reflexivity.
Defined.

Lemma eq_sigT_snd :
  forall X P (x1 x2:X) H1 H2 (H:existT P x1 H1 = existT P x2 H2), rew (eq_sigT_fst H) in H1 = H2.
Proof.
  intros.
  unfold eq_sigT_fst.
  change x2 with (projT1 (existT P x2 H2)).
  change H2 with (projT2 (existT P x2 H2)) at 3.
  destruct H.
  reflexivity.
Defined.

Lemma eq_sig_fst :
  forall X P (x1 x2:X) H1 H2 (H:exist P x1 H1 = exist P x2 H2), x1 = x2.
Proof.
  intros.
  change x2 with (proj1_sig (exist P x2 H2)).
  destruct H.
  reflexivity.
Defined.

Lemma eq_sig_snd :
  forall X P (x1 x2:X) H1 H2 (H:exist P x1 H1 = exist P x2 H2), rew (eq_sig_fst H) in H1 = H2.
Proof.
  intros.
  unfold eq_sig_fst, eq_ind.
  change x2 with (proj1_sig (exist P x2 H2)).
  change H2 with (proj2_sig (exist P x2 H2)) at 3.
  destruct H.
  reflexivity.
Defined.

Unset Implicit Arguments.

(** Exported hints *)

Hint Resolve eq_dep_intro: core.
Hint Immediate eq_dep_sym: core.

(************************************************************************)
(** * Eq_rect_eq <-> Eq_dep_eq <-> UIP <-> UIP_refl <-> K          *)

Section Equivalences.

  Variable U:Type.

  Variable p:U.

  (** Invariance by Substitution of Reflexive Equality Proofs *)

  Definition Eq_rect_eq :=
    forall (Q:U -> Type) (x:Q p) (h:p = p), x = eq_rect p Q x p h.

  (** Injectivity of Dependent Equality *)

  Definition Eq_dep_eq :=
    forall (P:U->Type) (x y:P p), eq_dep p x p y -> x = y.

  (** Uniqueness of Identity Proofs (UIP) *)

  Definition UIP_ :=
    forall (y:U) (p1 p2:p = y), p1 = p2.

  (** Uniqueness of Reflexive Identity Proofs *)

  Definition UIP_refl_ :=
    forall (H:p = p), H = eq_refl p.

  (** Streicher's axiom K *)

  Definition Streicher_K_ :=
    forall (P:p = p -> Prop), P (eq_refl p) -> forall H:p = p, P H.

  (** Injectivity of Dependent Equality is a consequence of *)
  (** Invariance by Substitution of Reflexive Equality Proof *)

  Lemma eq_rect_eq__eq_dep1_eq :
    Eq_rect_eq -> forall (P:U->Type) (x y:P p), eq_dep1 p x p y -> x = y.
  Proof.
    intro eq_rect_eq.
    simple destruct 1; intro.
    rewrite <- eq_rect_eq; auto.
  Qed.

  Lemma eq_rect_eq__eq_dep_eq : Eq_rect_eq -> Eq_dep_eq.
  Proof.
    intros eq_rect_eq; red; intros.
    apply (eq_rect_eq__eq_dep1_eq eq_rect_eq); apply eq_dep_dep1; trivial.
  Qed.

  (** Uniqueness of Identity Proofs (UIP) is a consequence of *)
  (** Injectivity of Dependent Equality *)
  Lemma sym_iff0 T (x y : T) (p1 : x = y) (p2 : y = x) : p1 = eq_sym p2 <-> p2 = eq_sym p1.
    split; intros; (subst p1 || subst p2); simpl; (destruct p1 || destruct p2); simpl; reflexivity.
  Qed.
  Lemma sym_iff T (x y : T) (p1 p2 : x = y) : p1 = p2 <-> eq_sym p1 = eq_sym p2.
    split; intros; try solve [ subst; trivial ]; simpl in *.
    transitivity (eq_sym (eq_sym p2));
      (apply sym_iff0 || (symmetry; apply sym_iff0)); intuition.
  Qed.

  Lemma eq_dep_eq__UIP : Eq_dep_eq -> UIP_.
  Proof.
    intro eq_dep_eq; red.
    intro y.
    intros; apply sym_iff; apply eq_dep_eq with (P := fun y0 => y = y0).
    elim (eq_sym p2) using eq_indd.
    elim (eq_sym p1) using eq_indd.
    apply eq_dep_intro.
  Qed.

  (** Uniqueness of Reflexive Identity Proofs is a direct instance of UIP *)

  Lemma UIP__UIP_refl : UIP_ -> UIP_refl_.
  Proof.
    intro UIP; red; intros; apply UIP.
  Qed.

  (** Streicher's axiom K is a direct consequence of Uniqueness of
      Reflexive Identity Proofs *)

  Lemma UIP_refl__Streicher_K : UIP_refl_ -> Streicher_K_.
  Proof.
    intro UIP_refl; red; intros; rewrite UIP_refl; assumption.
  Qed.

  (** We finally recover from K the Invariance by Substitution of
      Reflexive Equality Proofs *)

  Lemma Streicher_K__eq_rect_eq : Streicher_K_ -> Eq_rect_eq.
  Proof.
    intro Streicher_K; red; intros.
    apply Streicher_K with (H := h).
    reflexivity.
  Qed.

(** Remark: It is reasonable to think that [eq_rect_eq] is strictly
    stronger than [eq_rec_eq] (which is [eq_rect_eq] restricted on [Set]):

   [Definition Eq_rec_eq :=
      forall (P:U -> Set) (p:U) (x:P p) (h:p = p), x = eq_rec p P x p h.]

    Typically, [eq_rect_eq] allows to prove UIP and Streicher's K what
    does not seem possible with [eq_rec_eq]. In particular, the proof of [UIP]
    requires to use [eq_rect_eq] on [fun y -> x=y] which is in [Type] but not
    in [Set].
*)

End Equivalences.


(** UIP_refl is downward closed (a short proof of the key lemma of Voevodsky's
    proof of inclusion of h-level n into h-level n+1; see hlevelntosn
    in https://github.com/vladimirias/Foundations.git). *)

Theorem UIP_shift : forall U (x:U), UIP_refl_ U x -> forall H, UIP_refl_ (x = x) H.
Proof.
  intros X x UIP_refl y.
  rewrite (UIP_refl y).
  intros z.
  assert (UIP:forall y' y'' : x = x, y' = y'').
  { intros. apply eq_trans with (eq_refl x). apply UIP_refl.
    symmetry. apply UIP_refl. }
  transitivity (eq_trans (eq_trans (UIP (eq_refl x) (eq_refl x)) z)
                         (eq_sym (UIP (eq_refl x) (eq_refl x)))).
  - destruct z. unfold e. destruct (UIP _ _). reflexivity.
  - change
      (match eq_refl x as y' in _ = x' return y' = y' -> Type with
       | eq_refl => fun z => z = (eq_refl (eq_refl x))
       end (eq_trans (eq_trans (UIP (eq_refl x) (eq_refl x)) z)
                     (eq_sym (UIP (eq_refl x) (eq_refl x))))).
    destruct z. unfold e. destruct (UIP _ _). reflexivity.
Qed.

Section Corollaries.

  Variable U:Type.

  Variable p:U.

  (** UIP implies the injectivity of equality on dependent pairs in Type *)

 Definition Inj_dep_pair :=
   forall (P:U -> Type) (x y:P p), existT P p x = existT P p y -> x = y.

 Lemma eq_dep_eq__inj_pair2 : Eq_dep_eq U p -> Inj_dep_pair.
 Proof.
   intro eq_dep_eq; red; intros.
   apply eq_dep_eq.
   apply eq_sigT_eq_dep.
   assumption.
 Qed.

End Corollaries.

Notation Inj_dep_pairS := Inj_dep_pair.
Notation Inj_dep_pairT := Inj_dep_pair.
Notation eq_dep_eq__inj_pairT2 := eq_dep_eq__inj_pair2.


(************************************************************************)
(** * Definition of the functor that builds properties of dependent equalities assuming axiom eq_rect_eq *)

Module Type EqdepElimination.

  Axiom eq_rect_eq :
    forall (U:Type) (p:U) (Q:U -> Type) (x:Q p) (h:p = p),
      x = eq_rect p Q x p h.

End EqdepElimination.

Module EqdepTheory (M:EqdepElimination).

  Section Axioms.

    Variable U:Type.

(** Invariance by Substitution of Reflexive Equality Proofs *)

Lemma eq_rect_eq :
  forall (p:U) (Q:U -> Type) (x:Q p) (h:p = p), x = eq_rect p Q x p h.
Proof M.eq_rect_eq U.

Lemma eq_rec_eq :
  forall (p:U) (Q:U -> Set) (x:Q p) (h:p = p), x = eq_rec p Q x p h.
Proof (fun p Q => M.eq_rect_eq U p Q).

(** Injectivity of Dependent Equality *)

Lemma eq_dep_eq : forall (P:U->Type) (p:U) (x y:P p), eq_dep p x p y -> x = y.
Proof (fun P p => @eq_rect_eq__eq_dep_eq U p (eq_rect_eq p) P).

(** Uniqueness of Identity Proofs (UIP) is a consequence of *)
(** Injectivity of Dependent Equality *)

Lemma UIP : forall (x y:U) (p1 p2:x = y), p1 = p2.
Proof (fun p => @eq_dep_eq__UIP U p (fun P => @eq_dep_eq P p)).

(** Uniqueness of Reflexive Identity Proofs is a direct instance of UIP *)

Lemma UIP_refl : forall (x:U) (p:x = x), p = eq_refl x.
Proof (fun x => @UIP__UIP_refl U x (UIP x)).

(** Streicher's axiom K is a direct consequence of Uniqueness of
    Reflexive Identity Proofs *)

Lemma Streicher_K :
  forall (x:U) (P:x = x -> Prop), P (eq_refl x) -> forall p:x = x, P p.
Proof (fun x => UIP_refl__Streicher_K U x (UIP_refl x)).

End Axioms.

(** UIP implies the injectivity of equality on dependent pairs in Type *)

Lemma inj_pair2 :
 forall (U:Type) (P:U -> Type) (p:U) (x y:P p),
   existT P p x = existT P p y -> x = y.
Proof (fun U P p => eq_dep_eq__inj_pair2 U p (fun P => eq_dep_eq U P p) P).

Notation inj_pairT2 := inj_pair2.

End EqdepTheory.

Arguments eq_dep  U P p x q _ : clear implicits.
Arguments eq_dep1 U P p x q y : clear implicits.
