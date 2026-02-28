--------------------------- MODULE RailwayCrossing ---------------------------
(* Railway Crossing Model Checking Example                                    *)
(* Using TLA+ / TLC Model Checker                                            *)
(*                                                                            *)
(* Same system as the Promela / NuSMV versions:                               *)
(*   - A train approaches a crossing with a gate                              *)
(*   - Safety: gate must be closed when train crosses                         *)
(*   - Liveness: train eventually passes through                              *)
(*                                                                            *)
(* TLA+ models systems as state machines with an Init predicate               *)
(* and a Next-state relation. Properties are expressed in temporal logic.      *)
(* TLC (the model checker) exhaustively explores reachable states.            *)

VARIABLES train_position, gate_state

vars == << train_position, gate_state >>

(* ------------------------------------------------------------------ *)
(* Type invariant: constrains possible values                          *)
(* ------------------------------------------------------------------ *)
TypeOK ==
    /\ train_position \in { "far", "near", "crossing", "gone" }
    /\ gate_state     \in { "open", "closed" }

(* ------------------------------------------------------------------ *)
(* Initial state                                                       *)
(* ------------------------------------------------------------------ *)
Init ==
    /\ train_position = "far"
    /\ gate_state     = "open"

(* ------------------------------------------------------------------ *)
(* Train actions                                                       *)
(* ------------------------------------------------------------------ *)
TrainApproach ==
    /\ train_position = "far"
    /\ train_position' = "near"
    /\ UNCHANGED gate_state

TrainEnter ==
    /\ train_position = "near"
    /\ gate_state = "closed"
    /\ train_position' = "crossing"
    /\ UNCHANGED gate_state

TrainPass ==
    /\ train_position = "crossing"
    /\ train_position' = "gone"
    /\ UNCHANGED gate_state

TrainReset ==
    /\ train_position = "gone"
    /\ train_position' = "far"
    /\ UNCHANGED gate_state

(* ------------------------------------------------------------------ *)
(* Gate actions                                                        *)
(* ------------------------------------------------------------------ *)
GateClose ==
    /\ train_position = "near"
    /\ gate_state = "open"
    /\ gate_state' = "closed"
    /\ UNCHANGED train_position

GateOpen ==
    /\ train_position \in { "gone", "far" }
    /\ gate_state = "closed"
    /\ gate_state' = "open"
    /\ UNCHANGED train_position

(* ------------------------------------------------------------------ *)
(* Next-state relation: any one action can fire                        *)
(* ------------------------------------------------------------------ *)
Next ==
    \/ TrainApproach
    \/ TrainEnter
    \/ TrainPass
    \/ TrainReset
    \/ GateClose
    \/ GateOpen

(* ------------------------------------------------------------------ *)
(* Fairness: both processes must eventually get a turn                  *)
(* Without this, TLC could find a path where the gate never closes.    *)
(* ------------------------------------------------------------------ *)
Fairness ==
    /\ WF_vars(TrainApproach)
    /\ WF_vars(TrainEnter)
    /\ WF_vars(TrainPass)
    /\ WF_vars(TrainReset)
    /\ WF_vars(GateClose)
    /\ WF_vars(GateOpen)

(* ------------------------------------------------------------------ *)
(* Complete specification                                              *)
(* ------------------------------------------------------------------ *)
Spec == Init /\ [][Next]_vars /\ Fairness

(* ------------------------------------------------------------------ *)
(* SAFETY: The train is never crossing when the gate is open           *)
(* (checked as an invariant — TLC verifies this for all reachable      *)
(* states without needing temporal operators)                           *)
(* ------------------------------------------------------------------ *)
Safety ==
    train_position = "crossing" => gate_state = "closed"

(* ------------------------------------------------------------------ *)
(* LIVENESS: If the train is near, it will eventually be gone          *)
(* (this is a temporal property — requires fairness)                   *)
(* ------------------------------------------------------------------ *)
Liveness ==
    train_position = "near" ~> train_position = "gone"

=============================================================================
