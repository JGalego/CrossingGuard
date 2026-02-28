# Railway Crossing Model Checking Example

A simple example demonstrating formal verification using model checking for a railway safety-critical system.

![](train.gif)

## Problem Description

A train approaches a railway crossing with a gate. The system must ensure:
- **Safety**: The train never crosses while the gate is open
- **Liveness**: The train eventually completes its crossing

## Model Components

### States

- **Train positions**: FAR → NEAR → CROSSING → GONE (cyclic)
- **Gate states**: OPEN ↔ CLOSED

### Processes

1. **Train**: Moves through positions, waits for gate to close before crossing
2. **GateController**: Opens and closes the gate based on train position

### Properties to Verify

1. **Safety (LTL)**: `[] ((train_position == CROSSING) -> (gate_state == CLOSED))`
   - "Always, if the train is crossing, then the gate is closed"
   - This prevents accidents

2. **Liveness (LTL)**: `[] ((train_position == NEAR) -> (<>(train_position == GONE)))`
   - "Always, if the train is near, eventually it will be gone"
   - This prevents deadlock/starvation

## How to Run (using SPIN)

### Install SPIN

```bash
# Ubuntu/Debian
sudo apt-get install spin

# macOS
brew install spin
```

### Verify the Model

```bash
# Generate verifier
spin -a railway_crossing.pml

# Compile
gcc -o pan pan.c

# Verify safety property (no errors expected)
./pan -a -N safety

# Verify liveness/progress property (no errors expected)
./pan -a -N progress
```

## Expected Results

The model should verify successfully:
- No safety violations (train never crosses with gate open)
- No deadlocks
- Progress property holds

## Key Promela Concepts

1. **Atomicity matters**: In Promela, a guard (`:: cond ->`) and its body are
   separate steps - other processes can interleave between them. Use `atomic { }`
   to wrap guard + body when you need them to execute without interruption.

2. **LTL parentheses**: Temporal operators like `<>` bind tightly.
   Write `<>(expr)` not `<> expr`, otherwise SPIN may misparse the formula.

3. **Concurrency**: Two `active proctype` processes run with arbitrary interleaving.
   SPIN exhaustively explores all possible schedules.

4. **Exhaustive search**: Unlike testing, model checking verifies *every* reachable
   state - if a bug exists in any execution path, SPIN will find it.

## Experiments

Try modifying the model to introduce bugs:
- Remove the `atomic` wrapper from a transition - SPIN will find the race condition
- Remove the `gate_state == CLOSED` guard from the Train - the safety property will fail
- Change the gate opening condition - watch for deadlocks

The model checker will detect these violations!

## Further Reading

- [SPIN Model Checker](http://spinroot.com/)
- LTL Operators:
  - `[]` = "always" (globally)
  - `<>` = "eventually" (finally)
  - `->` = "implies"
- Real railway systems (e.g. ERTMS/ETCS) use similar formal methods for safety certification
