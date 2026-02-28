# Railway Crossing / Model Checking Example

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

## Implementations

The same railway crossing is modeled in four different tools, each with its own strengths:

| File | Tool | Logic | Key Feature |
|------|------|-------|-------------|
| `railway_crossing.pml` | SPIN | LTL | Explicit-state, asynchronous concurrency |
| `railway_crossing.smv` | NuSMV | CTL + LTL | Symbolic (BDD-based), synchronous |
| `RailwayCrossing.tla` | TLA+ / TLC | TLA+ | Action-based specs, fairness constraints |
| `railway_crossing.xml` | UPPAAL | TCTL | Real-time clocks and timed automata |

---

### SPIN (Promela)

```bash
# Install
sudo apt-get install spin   # or: brew install spin

# Verify
spin -a railway_crossing.pml
gcc -o pan pan.c
./pan -a -N safety
./pan -a -N progress
```

### NuSMV

```bash
# Install: https://nusmv.fbk.eu/ (or nuXmv: https://nuxmv.fbk.eu/)

# Verify all properties at once
NuSMV railway_crossing.smv

# Interactive mode
NuSMV -int railway_crossing.smv
```

### TLA+ (TLC)

```bash
# Install: https://github.com/tlaplus/tlaplus/releases
# Or use the VS Code TLA+ extension

# Verify (cfg file specifies invariants and properties)
java -jar tla2tools.jar -config RailwayCrossing.cfg RailwayCrossing.tla
```

### UPPAAL

```bash
# Install: https://uppaal.org/ (GUI-based tool)

# Open railway_crossing.xml in UPPAAL
# Load queries from railway_crossing.q in the Verifier tab
# Or use command-line verifier:
verifyta railway_crossing.xml railway_crossing.q
```

## Tool Comparison

| Aspect | SPIN | NuSMV | TLA+ | UPPAAL |
|--------|------|-------|------|--------|
| **State representation** | Explicit | Symbolic (BDD) | Explicit | Zones (DBM) |
| **Temporal logic** | LTL | CTL + LTL | TLA+ | TCTL |
| **Concurrency** | Async (interleaving) | Sync (lock-step) | Async (actions) | Async (timed) |
| **Real-time clocks** | No | No | No | Yes |
| **Fairness** | Weak (acceptance cycles) | CTL fairness | WF/SF built-in | Urgent channels |
| **Typical use** | Protocols, concurrency | Hardware, protocols | Distributed systems | Real-time, embedded |

## Key Concepts by Tool

### Promela / SPIN

- `atomic { }` prevents interleaving between guard and body
- LTL temporal operators need explicit parentheses: `<>(expr)`
- `active proctype` spawns concurrent processes

### NuSMV

- Synchronous: all `ASSIGN` rules fire simultaneously each step
- Supports both CTL (`AG`, `EF`, `AF`, `EG`) and LTL (`G`, `F`, `X`, `U`)
- `case/esac` blocks define conditional next-state transitions

### TLA+

- Actions are predicates over current and next state (primed variables)
- `WF_vars(Action)` = weak fairness (if action is continuously enabled, it eventually fires)
- `~>` (leads-to) is syntactic sugar for `[](P => <>Q)`
- Safety checked as an invariant, liveness as a temporal property

### UPPAAL

- Timed automata with clock variables and location invariants
- `chan` synchronization (sender `!` / receiver `?`) for process coordination
- Location invariants force progress (e.g., `x <= 10` means "must leave within 10 t.u.")
- TCTL queries: `A[]` (always), `A<>` (always eventually), `E<>` (reachable)

## Experiments

Try modifying any model to introduce bugs:
- Remove the gate-closed guard from the train — the safety property will fail
- Remove fairness (TLA+) or `atomic` (SPIN) — watch for liveness violations
- In UPPAAL, change the clock bound — the real-time constraint will break

The model checker will detect these violations!

## Further Reading

- [SPIN Model Checker](http://spinroot.com/)
- [NuSMV](https://nusmv.fbk.eu/) / [nuXmv](https://nuxmv.fbk.eu/)
- [TLA+ Home](https://lamport.azurewebsites.net/tla/tla.html) / [Learn TLA+](https://learntla.com/)
- [UPPAAL](https://uppaal.org/)
- LTL Operators: `[]` = always, `<>` = eventually, `->` = implies
- CTL Operators: `AG` = always, `EF` = possibly eventually, `AF` = inevitably, `EG` = possibly always
- Real railway systems (e.g. ERTMS/ETCS) use similar formal methods for safety certification
