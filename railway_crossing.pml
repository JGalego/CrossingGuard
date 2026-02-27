/* 
 * Railway Crossing Model Checking Example
 * Using Promela (SPIN Model Checker)
 * 
 * System: A simple railway crossing with a train and a gate
 * Safety Property: The gate must be closed when the train crosses
 */

// Train states
#define FAR     0
#define NEAR    1
#define CROSSING 2
#define GONE    3

// Gate states
#define OPEN    0
#define CLOSING 1
#define CLOSED  2
#define OPENING 3

byte train_position = FAR;
byte gate_state = OPEN;

// Train process
active proctype Train() {
    do
    :: train_position == FAR ->
        printf("Train: Approaching (FAR -> NEAR)\n");
        train_position = NEAR;
        
    :: train_position == NEAR ->
        // Wait for gate to be closed before crossing
        (gate_state == CLOSED);
        printf("Train: Entering crossing (NEAR -> CROSSING)\n");
        train_position = CROSSING;
        
    :: train_position == CROSSING ->
        printf("Train: Passed crossing (CROSSING -> GONE)\n");
        train_position = GONE;
        
    :: train_position == GONE ->
        printf("Train: Reset (GONE -> FAR)\n");
        train_position = FAR;
    od
}

// Gate controller process
active proctype GateController() {
    do
    :: train_position == NEAR && gate_state == OPEN ->
        printf("Gate: Start closing\n");
        gate_state = CLOSING;
        
    :: gate_state == CLOSING ->
        printf("Gate: Now closed\n");
        gate_state = CLOSED;
        
    :: train_position == GONE && gate_state == CLOSED ->
        printf("Gate: Start opening\n");
        gate_state = OPENING;
        
    :: gate_state == OPENING ->
        printf("Gate: Now open\n");
        gate_state = OPEN;
    od
}

// SAFETY PROPERTY: Train must never be crossing when gate is not closed
ltl safety {
    [] (train_position == CROSSING -> gate_state == CLOSED)
}

// LIVENESS PROPERTY: Train will eventually pass the crossing
ltl progress {
    [] (train_position == NEAR -> <> train_position == GONE)
}
