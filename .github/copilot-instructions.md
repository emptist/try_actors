# Copilot Instructions for try_actors

## Project Overview
This is a Gleam library demonstrating actor-based concurrency using Gleam's OTP framework. The main module (`src/try_actors.gleam`) provides a simple example of starting an actor, sending messages, and handling replies.

## Architecture
- **Core Component**: Single module with actor demonstration
- **Dependencies**: `gleam_otp` for actor system, `gleam_erlang` for Erlang integration
- **Pattern**: Functional actor model with message passing

## Key Patterns
- **Actor Creation**: Use `actor.new(initial_state) |> actor.on_message(handler) |> actor.start`
- **Message Handling**: Define `handle_message(state, message)` returning `actor.Next(new_state, message)`
- **Message Types**: Custom types like `Add(Int)` for updates, `Get(Subject(reply_type))` for queries
- **Communication**: `actor.send(subject, message)` for fire-and-forget, `actor.call(subject, timeout, message)` for replies
- **Styling**: Use `use` for function composition and pipes (`|>`) for chaining operations (see Gleam language tour)
- **Integration**: When introducing new external functions or types, suggest glue code for integration (wrappers, usage examples)

Example from `src/try_actors.gleam`:
```gleam
pub fn handle_message(state: Int, message: Message) -> actor.Next(Int, Message) {
  case message {
    Add(i) -> actor.continue(state + i)
    Get(reply) -> {
      actor.send(reply, state)
      actor.continue(state)
    }
  }
}
```

## Development Workflow
- **Dependencies**: Run `gleam deps download` after cloning
- **Testing**: `gleam test` (uses gleeunit framework)
- **Formatting**: `gleam format --check src test` in CI
- **Running**: `gleam run` executes the main function
- **Updates**: `gleam update` to refresh dependencies

## Conventions
- **File Structure**: Standard Gleam layout with `src/`, `test/`, `gleam.toml`
- **Naming**: Snake_case for functions/variables, PascalCase for types
- **Error Handling**: Use `assert` for examples, `let assert Ok(value) =` for fallible operations
- **Imports**: Group by package (e.g., `gleam/erlang/process`, `gleam/otp/actor`)
- **Modules**: Internal modules can be used for organization; refer to Gleam language tour for patterns

## Testing
- Tests in `test/` with `_test` suffix
- Use gleeunit's `assert` for checks
- Current tests are placeholders; add actor-specific tests for state changes and message handling

## CI/CD
- GitHub Actions on push/PR to main/master
- Erlang OTP 28, Gleam 1.13.0
- Runs `gleam deps download`, `gleam test`, `gleam format --check`

## Resources
- [Gleam Language Tour](https://gleam.run/book/tour/) for advanced patterns like `use`, pipes, and internal modules