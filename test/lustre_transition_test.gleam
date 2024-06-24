import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import transition

pub fn main() {
  gleeunit.main()
}

// Next will transition the state from EnterInit to Enter or LeaveInit to Leave
// All other states will remain unchanged.
pub fn next_test() {
  Some(transition.EnterInit)
  |> transition.next
  |> should.equal(transition.Enter)

  Some(transition.LeaveInit)
  |> transition.next
  |> should.equal(transition.Leave)

  Some(transition.Enter)
  |> transition.next
  |> should.equal(transition.Enter)

  Some(transition.Leave)
  |> transition.next
  |> should.equal(transition.Leave)

  Some(transition.Init)
  |> transition.next
  |> should.equal(transition.Init)

  None
  |> transition.next
  |> should.equal(transition.Init)
}

// Toggle will Switch form any leaving state to EnterInit or any entering state to LeaveInit
pub fn toggle_test() {
  Some(transition.Init)
  |> transition.toggle
  |> should.equal(transition.EnterInit)

  Some(transition.Leave)
  |> transition.toggle
  |> should.equal(transition.EnterInit)

  Some(transition.LeaveInit)
  |> transition.toggle
  |> should.equal(transition.EnterInit)

  Some(transition.EnterInit)
  |> transition.toggle
  |> should.equal(transition.LeaveInit)

  Some(transition.Enter)
  |> transition.toggle
  |> should.equal(transition.LeaveInit)
}

// Apply will apply the state to the transition classes and return the appropriate string
pub fn apply_test() {
  let classes =
    transition.Classes(enter: #("aaa", "bbb", "ccc"), leave: #(
      "ddd",
      "eee",
      "fff",
    ))

  classes |> transition.apply(transition.Init) |> should.equal("hidden")
  classes |> transition.apply(transition.LeaveInit) |> should.equal("ddd eee")
  classes |> transition.apply(transition.Leave) |> should.equal("ddd fff")
  classes |> transition.apply(transition.EnterInit) |> should.equal("aaa bbb")
  classes |> transition.apply(transition.Enter) |> should.equal("aaa ccc")
}

// End will switch the the Init state from leave only
pub fn end_test() {
  Some(transition.Leave)
  |> transition.end
  |> should.equal(transition.Init)

  Some(transition.EnterInit)
  |> transition.end
  |> should.equal(transition.EnterInit)

  Some(transition.Enter)
  |> transition.end
  |> should.equal(transition.Enter)

  Some(transition.LeaveInit)
  |> transition.end
  |> should.equal(transition.LeaveInit)

  Some(transition.Init)
  |> transition.end
  |> should.equal(transition.Init)

  None
  |> transition.end
  |> should.equal(transition.Init)
}
// not sure how to test the start function, it should return an effect that will trigger on request_animation_frame
