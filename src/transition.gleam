import gleam/option.{type Option, None, Some}
import lustre/effect.{type Effect}

/// Move the state on from `Init`, e.g. `EnterInit` -> `Enter`, `LeaveInit` -> `Leave`.
pub fn next(state: Option(State)) -> State {
  case state {
    None -> Init
    Some(state) ->
      case state {
        EnterInit -> Enter
        LeaveInit -> Leave
        _ -> state
      }
  }
}

/// Toggle the state from any `Leave` state to `EnterInit`, or any `Enter` state to `LeaveInit`.
pub fn toggle(state: Option(State)) -> State {
  case state {
    None -> Init
    Some(state) ->
      case state {
        Init | Leave | LeaveInit -> EnterInit
        _ -> LeaveInit
      }
  }
}

/// Used to trigger the start of an animation. `Msg` will be dispatched on the next frame. 
pub fn start(msg: a) -> Effect(a) {
  use dispatch <- effect.from
  use _ts <- request_animation_frame
  msg |> dispatch
}

/// Use the supplied state to select the correct classes to display on the element.
pub fn apply(classes: Classes, state: State) -> String {
  case state {
    Init -> "hidden"
    EnterInit -> classes.enter.0 <> " " <> classes.enter.1
    Enter -> classes.enter.0 <> " " <> classes.enter.2
    LeaveInit -> classes.leave.0 <> " " <> classes.leave.1
    Leave -> classes.leave.0 <> " " <> classes.leave.2
  }
}

/// Use the `transitionend` event to call this, it will update the state back to `Init`.
pub fn end(state: Option(State)) -> State {
  case state {
    Some(state) ->
      case state {
        Leave -> Init
        _ -> state
      }
    _ -> Init
  }
}

/// Stores the complete information about a transition, it's state and all the classes that will be applied.
pub type Transition {
  Transition(state: State, classes: Classes)
}

pub type State {
  /// Starting state.
  Init

  /// First frame of `Enter` transition.
  EnterInit

  /// `Enter` transition from after second frame until the end of transition.
  Enter

  /// First frame of `Leave` transition.
  LeaveInit

  /// `Leave` transition from after second frame until the end of transition.
  Leave
}

/// Convert the state to a string for debugging purposes.
pub fn state_to_string(state: State) {
  case state {
    Init -> "Init"
    EnterInit -> "Enter Init"
    Enter -> "Enter"
    LeaveInit -> "Leave Init"
    Leave -> "Leave"
  }
}

/// Used to define what classes will be applied to your element through each stage of a transition.
pub type Classes {
  Classes(enter: #(String, String, String), leave: #(String, String, String))
}

type RequestID =
  Nil

@external(javascript, "./ffi.mjs", "requestAnimationFrame")
fn request_animation_frame(callback: fn(Float) -> Nil) -> RequestID
