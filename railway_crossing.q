// UPPAAL query file for railway crossing model
// Load in UPPAAL alongside railway_crossing.xml

// Safety: gate is always closed when train is crossing
A[] (train.Crossing imply gate_state == 1)

// Liveness: the train always eventually reaches Gone
A<> (train.Gone)

// Reachability: it is possible for the train to cross
E<> (train.Crossing)

// Deadlock freedom
A[] not deadlock

// Bounded response: train never waits more than 10 t.u. at Near
// (enforced structurally by the location invariant on Near)
A[] (train.Near imply train.x <= 10)
