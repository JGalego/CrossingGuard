/* 
 * Railway Crossing Model Checking Example
 * Using Promela (SPIN Model Checker)
 * 
 * System: A simple railway crossing with a train and a gate
 * Safety Property: The gate must be closed when the train crosses
 *
 * Key Promela notes:
 *   - In a do-loop, the guard (:: cond ->) and body are separate steps;
 *     other processes CAN interleave between them.
 *   - Wrapping guard + body in atomic { } prevents interleaving.
 *   - LTL temporal operators need explicit parentheses around their
 *     operand, e.g. <>(expr), not <> expr.
 */

// Train states
#define FAR      0
#define NEAR     1
#define CROSSING 2
#define GONE     3

// Gate states
#define OPEN     0
#define CLOSED   1

byte train_position = FAR;
byte gate_state = OPEN;

// Train process
active proctype Train() {
    do
    :: atomic { train_position == FAR ->
        printf("Train: Approaching (FAR -> NEAR)\n");
        train_position = NEAR
       }

    :: atomic { train_position == NEAR && gate_state == CLOSED ->
        printf("Train: Entering crossing (NEAR -> CROSSING)\n");
        train_position = CROSSING
       }

    :: atomic { train_position == CROSSING ->
        printf("Train: Passed crossing (CROSSING -> GONE)\n");
        train_position = GONE
       }

    :: atomic { train_position == GONE ->
        printf("Train: Reset (GONE -> FAR)\n");
        train_position = FAR
       }
    od
}

// Gate controller process
// Gate closes when train is NEAR; opens only when train has left
// (GONE or FAR) and is definitely not on the crossing.
active proctype GateController() {
    do
    :: atomic { train_position == NEAR && gate_state == OPEN ->
        printf("Gate: Closing\n");
        gate_state = CLOSED
       }

    :: atomic { (train_position == GONE || train_position == FAR) && gate_state == CLOSED ->
        printf("Gate: Opening\n");
        gate_state = OPEN
       }
    od
}

// SAFETY PROPERTY: Train must never be crossing when gate is not closed
ltl safety {
    [] ((train_position == CROSSING) -> (gate_state == CLOSED))
}

// LIVENESS PROPERTY: Whenever the train is near, it eventually passes
ltl progress {
    [] ((train_position == NEAR) -> (<>(train_position == GONE)))
}
