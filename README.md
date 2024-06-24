# lustre_transition

[![Package Version](https://img.shields.io/hexpm/v/lustre_transition)](https://hex.pm/packages/lustre_transition)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_transition/)

## Installation

1. Add lustre to your project

Lustre is published on [Hex](https://hex.pm/packages/lustre)! You can add it to
your Gleam projects from the command line:

```sh
gleam add lustre
```

2. Add lustre_transitions to your project

```sh
gleam add lustre_transitions
```

2. Add lustre_dev_tools to your project

Lustre's dev tools are published on [Hex](https://hex.pm/packages/lustre_dev_tools)!
You can add them as a dev dependency to your Gleam projects from the command line:

> **Note**: currently one of lustre_dev_tools' dependencies is not compatible with
> the most recent version of `gleam_json`, making it impossible to install. To fix
> this, add `gleam_json = "1.0.1"` as a dependency in your `gleam.toml` file.

```sh
gleam add lustre_dev_tools --dev
```

3. Add tailwind support

Download a platform-appropriate version of the Tailwind binary.

```sh
gleam run -m lustre/dev add tailwind
```

4. Serve your project

Start a development server for your Lustre project. This
command will compile your application and serve it on a local server.

```sh
gleam run -m lustre/dev start
```

## Example

<img src="https://github.com/codemonkey76/lustre_transition/blob/main/screenshots/example.gif?raw=true">

```gleam
import gleam/dynamic
import gleam/option.{Some}
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import transition.{type State}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

type Model {
  Model(panel_state: transition.State)
}

pub opaque type Msg {
  UserClickedButton
  TransitionStarted
  TransitionEnded(String)
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(transition.Init), effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedButton -> #(
      Model(panel_state: transition.toggle(Some(model.panel_state))),
      transition.start(TransitionStarted),
    )
    TransitionStarted -> #(
      Model(panel_state: transition.next(Some(model.panel_state))),
      effect.none(),
    )
    TransitionEnded(_) -> #(
      Model(panel_state: transition.end(Some(model.panel_state))),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("p-4")], [
    html.button(
      [
        event.on_click(UserClickedButton),
        attribute.class(
          "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focusivisible:outline-2 focus-visible:outline-indigo-600",
        ),
      ],
      [element.text("Click Me!")],
    ),
    panel(model.panel_state),
  ])
}

fn panel(state: State) {
  // "hidden" - we need to add this here so that tailwind doesn't strip out this class
  let classes =
    transition.Classes(
      enter: #(
        "transition ease-out duration-300",
        "opacity-0 scale-90",
        "opacity-100 scale-100",
      ),
      leave: #(
        "transition ease-in duration-300",
        "opacity-100 scale-100",
        "opacity-0 scale-90",
      ),
    )
    |> transition.apply(state)
  html.div(
    [
      attribute.class(classes),
      attribute.id("hello"),
      event.on("transitionend", handle_transition_end),
    ],
    [element.text("Hello World!")],
  )
}

fn handle_transition_end(event) -> Result(Msg, List(dynamic.DecodeError)) {
  use target <- result.try(dynamic.field("target", dynamic.dynamic)(event))
  use id <- result.try(dynamic.field("id", dynamic.string)(target))
  Ok(TransitionEnded(id))
}
```


Further documentation can be found at <https://hexdocs.pm/lustre_transition>.

