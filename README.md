# Railway Crossing Model Checking Example

This is a simple example demonstrating formal verification using model checking for a railway safety-critical system.

## Problem Description

A train approaches a railway crossing with a gate. The system must ensure:
- **Safety**: The train never crosses while the gate is open
- **Liveness**: The train eventually completes its crossing

## Model Components

### States
- **Train positions**: FAR → NEAR → CROSSING → GONE
- **Gate states**: OPEN → CLOSING → CLOSED → OPENING

### Processes
1. **Train**: Moves through positions, waits for gate to close before crossing
2. **GateController**: Opens and closes the gate based on train position

### Properties to Verify

1. **Safety (LTL)**: `[] (train_position == CROSSING -> gate_state == CLOSED)`
   - "Always, if the train is crossing, then the gate is closed"
   - This prevents accidents

2. **Liveness (LTL)**: `[] (train_position == NEAR -> <> train_position == GONE)`
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

# Run verification
./pan -a

# Check for deadlocks
./pan -l

# Check specific LTL property
./pan -a -N safety
./pan -a -N progress
```

## Expected Results

✅ The model should verify successfully:
- No safety violations (train never crosses with gate open)
- No deadlocks
- Progress property holds

## Learning Points

1. **Concurrency**: Two processes running simultaneously
2. **Synchronization**: Train waits for gate to close
3. **Temporal Logic**: LTL formulas express safety and liveness
4. **Exhaustive Search**: SPIN explores all possible execution paths

## Potential Issues to Explore

Try modifying the model to introduce bugs:
- Remove the wait condition `(gate_state == CLOSED)` in the Train process
- Change the gate controller logic
- Add sensor failures or delays

The model checker will detect these violations!

## Further Reading

- [SPIN Model Checker](http://spinroot.com/)
- LTL Operators:
  - `[]` = "always" (globally)
  - `<>` = "eventually" (finally)
  - `->` = "implies"
- Real railway systems use similar formal methods for safety certification
