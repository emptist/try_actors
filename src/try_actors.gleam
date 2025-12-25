import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/string

/// Actor-based state management system using Gleam's OTP library
///
/// This module demonstrates the actor pattern for concurrent programming,
/// where state is maintained safely across processes through message passing.
/// The actor maintains an integer state and processes two types of messages:
/// adding values to the state and retrieving the current state.
/// Message types for actor communication
pub type Message {
  /// Add a value to the actor's current state
  ///
  /// # Parameters
  /// - `Int`: The value to add to the current state
  Add(Int)

  /// Request the current state via a reply channel
  ///
  /// # Parameters
  /// - `Subject(Int)`: The reply channel to send the state to
  Get(Subject(Int))
}

/// Display state changes and operation details
///
/// # Parameters
/// - `operation: Message` - The message being processed (or Nil for initial state)
/// - `old_state: Int` - State before the operation
/// - `new_state: Int` - State after the operation (if applicable)
///
/// # Returns
/// `Nil` - Unit value, used for side effects only
pub fn display_state_change(
  operation: Result(Message, Nil),
  old_state: Int,
  new_state: Int,
) -> Nil {
  let operation_type = case operation {
    Ok(Add(value)) -> {
      let message = "Adding " <> string.inspect(value) <> " to state"
      echo message
      "State after Add: "
    }
    Ok(Get(_)) -> {
      echo "Getting current state"
      "Current state: "
    }
    Error(Nil) -> {
      echo "Initial state"
      "Initial state: "
    }
  }

  let message =
    operation_type
    <> string.inspect(old_state)
    <> " -> "
    <> string.inspect(new_state)
  echo message
  Nil
}

/// Message handler for the actor state machine
///
/// Processes incoming messages and returns the next state with continuation.
/// This function follows the actor pattern: receives current state and message,
/// processes the message, and returns the updated state for the next message.
///
/// # Parameters
/// - `state: Int` - Current integer state of the actor
/// - `message: Message` - Message to process
///
/// # Returns
/// `actor.Next(Int, Message)` - Continuation with updated state
pub fn handle_message(state: Int, message: Message) -> actor.Next(Int, Message) {
  case message {
    Add(i) -> {
      let new_state = state + i
      display_state_change(Ok(Add(i)), state, new_state)
      actor.continue(new_state)
    }

    Get(reply) -> {
      // State does NOT change within this block
      // The current state is only read and sent via reply channel
      display_state_change(Ok(Get(reply)), state, state)
      actor.send(reply, state)
      actor.continue(state)
    }
  }
}

/// Handle Add message: increment state and log changes
/// 
/// Steps:
/// 1. Display current state before addition
/// 2. Calculate new state by adding the provided value
/// 3. Display the updated state
/// 4. Return continuation with new state
/// Handle Get message: send current state via reply channel
/// 
/// Steps:
/// 1. Display current state being retrieved
/// 2. Send current state to the provided reply channel
/// 3. Return continuation with unchanged state
/// Demonstration of actor usage and message passing
/// 
/// This main function showcases:
/// 1. Creating an actor with initial state 0
/// 2. Sending asynchronous Add messages to modify state
/// 3. Sending a synchronous Get message to retrieve final state
/// 4. Displaying all state changes throughout the process
/// 
/// Expected result: Actor state starts at 0, adds 5 (state = 5), 
/// adds 3 (state = 8), and final Get returns 8
pub fn main() {
  // Display initial state
  display_state_change(Error(Nil), 0, 0)

  // Start an actor with initial state 0 and our message handler
  let assert Ok(actor) =
    actor.new(0)
    |> actor.on_message(handle_message)
    |> actor.start

  // Send some messages to the actor (asynchronous)
  actor.send(actor.data, Add(5))
  actor.send(actor.data, Add(3))

  // Send a message and get a reply (synchronous call)
  // Waits up to 10 milliseconds for response
  assert actor.call(actor.data, waiting: 10, sending: Get) == 8
}
