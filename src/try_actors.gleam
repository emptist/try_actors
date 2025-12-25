import gleam/erlang/process.{type Subject}
import gleam/otp/actor

pub type Message {
  Add(Int)
  Get(Subject(Int))
}

pub fn handle_message(state: Int, message: Message) -> actor.Next(Int, Message) {
  case message {
    Add(i) -> {
      echo state
      let state = state + i
      echo state
      actor.continue(state)
    }
    Get(reply) -> {
      // echo reply
      // echo state
      actor.send(reply, state)
      actor.continue(state)
    }
  }
}

pub fn main() {
  // Start an actor
  let assert Ok(actor) =
    actor.new(0)
    |> actor.on_message(handle_message)
    |> actor.start

  // Send some messages to the actor
  actor.send(actor.data, Add(5))
  actor.send(actor.data, Add(3))

  // Send a message and get a reply
  assert actor.call(actor.data, waiting: 10, sending: Get) == 8
}
