/*
 * Railway Crossing — Dafny Implementation
 *
 * This is a verified implementation derived from the formal models.
 * Dafny proves at compile time that:
 *   - The safety invariant holds after every method call
 *   - All methods terminate
 *   - No array out-of-bounds, division by zero, etc.
 *
 * Compile & verify:
 *   dafny verify RailwayCrossing.dfy
 *
 * Run:
 *   dafny run RailwayCrossing.dfy
 */

datatype TrainPosition = Far | Near | Crossing | Gone
datatype GateState     = Open | Closed

// The system state
class RailwayCrossing {
    var train_position: TrainPosition
    var gate_state: GateState

    // --- CLASS INVARIANT (safety property) ---
    // "If the train is crossing, the gate must be closed."
    // Dafny checks this holds at the end of every method.
    ghost predicate Valid()
        reads this
    {
        train_position == Crossing ==> gate_state == Closed
    }

    // --- CONSTRUCTOR ---
    constructor()
        ensures Valid()
        ensures train_position == Far
        ensures gate_state == Open
    {
        train_position := Far;
        gate_state := Open;
    }

    // --- TRAIN ACTIONS ---

    method TrainApproach()
        requires Valid()
        requires train_position == Far
        modifies this
        ensures Valid()
        ensures train_position == Near
        ensures gate_state == old(gate_state)
    {
        train_position := Near;
    }

    method TrainEnter()
        requires Valid()
        requires train_position == Near
        requires gate_state == Closed  // <-- safety precondition
        modifies this
        ensures Valid()
        ensures train_position == Crossing
        ensures gate_state == Closed
    {
        train_position := Crossing;
    }

    method TrainPass()
        requires Valid()
        requires train_position == Crossing
        modifies this
        ensures Valid()
        ensures train_position == Gone
        ensures gate_state == old(gate_state)
    {
        train_position := Gone;
    }

    method TrainReset()
        requires Valid()
        requires train_position == Gone
        modifies this
        ensures Valid()
        ensures train_position == Far
        ensures gate_state == old(gate_state)
    {
        train_position := Far;
    }

    // --- GATE ACTIONS ---

    method GateClose()
        requires Valid()
        requires train_position == Near
        requires gate_state == Open
        modifies this
        ensures Valid()
        ensures gate_state == Closed
        ensures train_position == old(train_position)
    {
        gate_state := Closed;
    }

    method GateOpen()
        requires Valid()
        requires train_position == Gone || train_position == Far
        requires gate_state == Closed
        modifies this
        ensures Valid()
        ensures gate_state == Open
        ensures train_position == old(train_position)
    {
        gate_state := Open;
    }
}

// --- DEMO: one full cycle ---
method Main()
{
    var rc := new RailwayCrossing();
    print "Initial:  train=Far,      gate=Open\n";

    rc.TrainApproach();
    print "Approach: train=Near,     gate=Open\n";

    rc.GateClose();
    print "Close:    train=Near,     gate=Closed\n";

    rc.TrainEnter();
    print "Enter:    train=Crossing, gate=Closed\n";

    rc.TrainPass();
    print "Pass:     train=Gone,     gate=Closed\n";

    rc.GateOpen();
    print "Open:     train=Gone,     gate=Open\n";

    rc.TrainReset();
    print "Reset:    train=Far,      gate=Open\n";

    print "\nAll transitions verified by Dafny!\n";
}
