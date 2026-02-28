# Contributing to CrossingGuard 🚂🚧✅

Thanks for your interest in contributing! This project models a railway crossing in multiple formal verification tools, so contributions can range from new models to documentation fixes.

## Ways to Contribute

### 🐛 Bug Reports

- Found a property that doesn't verify? Open an issue with the tool name, version, and error output.

### 🔧 New Models or Implementations

Want to add the railway crossing in a new tool? Great! Please ensure:
1. The model uses the **same states** (FAR → NEAR → CROSSING → GONE for the train, OPEN ↔ CLOSED for the gate)
2. The **safety property** is verified: *the gate is closed whenever the train is crossing*
3. The **liveness property** is verified: *if the train is near, it eventually passes*
4. Add a section to the README with install/verify instructions
5. Place files under `models/<tool>/` or `implementations/<language>/`

### 📖 Documentation

- Improvements to the README, diagrams, or explanations are always welcome
- If you find a concept that's confusing, a clarification PR is valuable

### 🧪 Experiments / Mutants

- Add intentionally broken variants under `experiments/` to demonstrate how model checkers catch bugs

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b add-<tool>-model`
3. Make your changes
4. Test your model/implementation with the relevant tool (see README for commands)
5. Open a Pull Request with a clear description

## Docker

The `Dockerfile` provides an all-in-one environment with SPIN, NuSMV, and TLA+/TLC pre-installed. You can use it to verify your changes:

```bash
docker build -t model-checker .
docker run --rm -v "$(pwd)":/models -w /models model-checker
```

## Code Style

- **Models**: Follow the conventions of each tool (Promela, SMV, TLA+, etc.)
- **Implementations**: Follow the idiomatic style of each language (Dafny, Ada, Lustre)
- **Comments**: Each file should have a header explaining what it is and how to run/verify it

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
