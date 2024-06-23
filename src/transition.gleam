import gleam/option.{type Option, None, Some}
import lustre/effect.{type Effect}

/// Move the state on from Init, e.g. EnterInit -> Enter, LeaveInit -> Leave
pub fn next(state: Option(State)) -> State {
  case state {
    None -> Left
    Some(state) ->
      case state {
        EnterInit -> Enter
        LeaveInit -> Leave
        _ -> state
      }
  }
}

/// Toggle the state from any Leave state to EnterInit, or any Enter state to LeaveInit
pub fn toggle(state: Option(State)) -> State {
  case state {
    None -> Left
    Some(state) ->
      case state {
        Left | Leave | LeaveInit -> EnterInit
        _ -> LeaveInit
      }
  }
}

/// 
pub fn start(msg: a) -> Effect(a) {
  use dispatch <- effect.from
  use _ts <- request_animation_frame
  msg |> dispatch
}

pub fn apply(classes: Classes, state: State) -> String {
  case state {
    Left -> "hidden"
    EnterInit -> classes.enter.0 <> " " <> classes.enter.1
    Enter -> classes.enter.0 <> " " <> classes.enter.2
    LeaveInit -> classes.leave.0 <> " " <> classes.leave.1
    Leave -> classes.leave.0 <> " " <> classes.leave.2
  }
}

pub fn end(state: Option(State)) -> State {
  case state {
    Some(state) ->
      case state {
        Leave -> Left
        _ -> state
      }
    _ -> Left
  }
}

pub type Transition {
  Transition(state: State, classes: Classes)
}

pub type State {
  Left
  EnterInit
  Enter
  LeaveInit
  Leave
}

pub fn state_to_string(state: State) {
  case state {
    Left -> "Left"
    EnterInit -> "Enter Init"
    Enter -> "Enter"
    LeaveInit -> "Leave Init"
    Leave -> "Leave"
  }
}

pub type Classes {
  Classes(enter: #(String, String, String), leave: #(String, String, String))
}

type RequestID =
  Nil

@external(javascript, "./ffi.mjs", "requestAnimationFrame")
fn request_animation_frame(callback: fn(Float) -> Nil) -> RequestID
