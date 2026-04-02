# Behavior-Router

A Godot 4.4 GDScript library that replaces state machines with a URL-style hierarchical routing system.

---

## Architectural Overview

### 1. Engine Version & Project Configuration

**Godot 4.4** — confirmed at `project.godot:15`:
```
config/features=PackedStringArray("4.4")
```

- **Project name**: `"Behavior Router"` (`project.godot:13`)
- **Main scene**: `uid://laj1hechb6dk` → `res://src/main.tscn` (`project.godot:14`)
- **No autoloads/singletons** — no `[autoload]` section in `project.godot`
- **No export presets** — `export_presets.cfg` does not exist
- **No addons folder**
- **VS Code tooling** via `.vscode/launch.json` + `.vscode/settings.json` pointing to Godot 4.4.1 win64 exe

---

### 2. Folder Structure

```
Behavior-Router/
├── project.godot              # Godot 4.4 project config
├── icon.svg                   # Project icon
├── notes.md                   # Design notes / rationale
├── .vscode/
│   ├── launch.json            # GDScript debugger config
│   └── settings.json          # Godot editor path
└── src/
    ├── main.gd                # Trivial Node script (entry point stub)
    ├── main.tscn              # Main scene (wraps RouterTest)
    ├── router.zip             # Archived snapshot of router module
    └── router/
        ├── route.gd           # Route base class (Resource)
        ├── router.gd          # Placeholder (empty RefCounted)
        ├── router_context.gd  # Core: Router class
        ├── request_data.gd    # RequestData struct (Resource)
        └── test/
            ├── test.gd        # Test Node scene script
            ├── test_route.gd  # Concrete Route implementation
            ├── test_route.tres# Test route resource file
            └── router_test.tscn # Test scene
```

---

### 3. Scene Hierarchy & Runtime Entry Point

**Boot sequence:**

1. Godot loads `res://src/main.tscn` (per `project.godot:14`)
2. `main.tscn` contains a root `Node` ("Main") with `main.gd` (`extends Node`, empty)
3. It instances `res://src/router/test/router_test.tscn` as a child, injecting `request_path = "/:lol=1"` (`main.tscn:7-8`)
4. `router_test.tscn` contains a single `Node` ("RouterTest") with `test.gd` attached, pre-loaded with `initial_routes = [TestRoute{path="/:lol"}]`

No autoloads run before this. The main scene *is* the test harness.

---

### 4. Core Classes & Responsibilities

#### `Route` — `src/router/route.gd`
```gdscript
class_name Route
extends Resource
```
- **Base class** for all route handlers (lines 1–13)
- Exported property: `path: String` — the route path pattern
- Three virtual methods:
  - `enter(context: Router)` — called on route activation
  - `exit(context: Router)` — called on route deactivation
  - `execute(context: Router, delta:=0.0)` — called each frame

Routes are **Godot Resources**, meaning they can be serialized to `.tres` files and configured in the Inspector.

---

#### `RequestData` — `src/router/request_data.gd`
```gdscript
class_name RequestData
extends Resource
```
- **Struct** holding one parsed path segment's data (lines 1–11)
- Fields: `path: String`, `params: Dictionary[String, String]`, `route: Route`
- Constructor looks up the matching Route from a `route_map` dictionary

---

#### `Router` — `src/router/router_context.gd`
```gdscript
class_name Router
extends Resource
```
The **central hub** of the system (lines 1–76).

| Method | Purpose |
|---|---|
| `_init(_routes)` | Builds `route_map` from an `Array[Route]` |
| `request(route_path)` | Parses a path string → `Array[RequestData]` |
| `process_request(data, delta)` | Iterates RequestData, calls `.execute()` on each Route |
| `generate_route_map(routes)` *(static)* | Converts route array to `Dictionary[String, Route]` |
| `generate_request_data(path, map)` *(static)* | Parses path string into RequestData array |

**Nested utility class** `PathParams` (lines 44–73) provides typed parameter conversions:
- `toVector3(params, key)` — `"1,2,3"` → `Vector3`
- `toFloat(params, key)` — `"3.14"` → `float`
- `toInt(params, key)` — `"42"` → `int`

**Nested stub** `Router` (lines 75–76) — empty `RefCounted`, future placeholder.

---

#### `router.gd` — `src/router/router.gd`
Completely empty `extends RefCounted`. Reserved for future top-level router logic.

---

#### `TestRoute` — `src/router/test/test_route.gd`
```gdscript
class_name TestRoute
extends Route
```
Overrides `execute()` to `print("Executing TestRoute with path: ", path)` (lines 1–6). Sole concrete route implementation.

---

#### `test.gd` (RouterTest node) — `src/router/test/test.gd`
The **test driver** (lines 1–33):
- `@export var request_path: String` — set to `"/:lol=1"` in `main.tscn:8`
- `@export var initial_routes: Array[Route]` — populated in `router_test.tscn`
- `@onready var context := Router.new(initial_routes)` — builds context at scene ready
- `_ready()`: fires first request
- `_process(delta)`: re-fires every frame → routes execute continuously

---

### 5. Communication Architecture

There are **no signals**, **no groups**, **no message bus**, and **no dependency injection framework**. Communication is direct method calls:

```
test.gd
  └─ holds Router (created inline with @onready)
       └─ holds Dictionary[String, Route]
            └─ Route.execute(context, delta)  ← called by process_request
```

The `Router` reference is passed *into* route methods as the `context` argument — this is the only coupling point between routes and the context.

---

### 6. Path Parsing & Routing Algorithm

Path format (Express.js-inspired):
```
/segment/:paramName=defaultValue/:another=val
```

`generate_request_data()` at `router_context.gd:27–40`:
1. `rsplit("/", false)` splits path into segments
2. Each segment starting with `:` is a **parameter** — split on `=` to get name and default value
3. Builds a *cumulative* `walked` path after each segment
4. Appends a `RequestData` for each segment with that segment's params and the matching Route

**Example** — path `"/lol/:velocity=1,2,3"`:

| Step | `walked` | `params` |
|---|---|---|
| 1 | `/lol` | `{}` |
| 2 | `/lol/:velocity` | `{velocity: "1,2,3"}` |

This means the router fires routes **at every path level** — ancestor routes always execute before descendants. This is the behavioral-routing pattern: the path encodes a hierarchy of "behaviors" active simultaneously.

---

### 7. Behavior-Router / AI System Design

This is **not a traditional behavior tree or FSM**. The design intent (documented in `notes.md`) is:

> *"A context object that facilitates communication between states, router, and engine. Use a router pattern in place of a state machine."*

The conceptual model maps onto hierarchical path-routing:
- **Path segments = active behavior layers** (e.g., `/combat/:stance=aggressive` — both `/combat` and `/:stance` routes execute)
- **Parameters = typed data injected into behaviors** (e.g., velocity as Vector3, enum flags as int)
- **Route.execute() = per-frame behavior tick**
- **Route.enter()/exit() = lifecycle hooks** (defined but not yet called by any code)

The design replaces:
- State machine states → Route resources
- Transitions → `context.request(new_path)` calls
- State data → path parameters parsed by PathParams

---

### 8. Testing & Dev Tooling

- **No unit test framework** (GUT, WAT, etc.) is installed
- `test.gd` is a manual/visual test node; `_test()` method is never called by the scene, it only `print()`s to the Godot output console
- `router_test.tscn` + `main.tscn` serve as an interactive testbed
- **VS Code** with `godot-tools` extension is the assumed editor (`.vscode/` config present)
- `.gitignore` excludes `.godot/` (Godot's compiled cache)

---

### 9. Coding Conventions

- `class_name` declared at top of every major script
- `extends Resource` for data/logic classes, `extends Node` only for scene nodes
- Typed dictionary syntax: `Dictionary[String, Route]` (Godot 4 typed collections)
- Static utility methods grouped as nested inner classes (e.g., `PathParams`, `Router`)
- `@export` used for Inspector-configurable arrays (routes, paths)
- `@onready` for lazy node-bound initialization
- No comments in code; design rationale lives in `notes.md`

---

### 10. Component Diagram

```
[project.godot]
    └─ main_scene ──► [main.tscn]
                          │
                          └─ Node "Main" (main.gd, empty)
                               └─ Node "RouterTest" (test.gd)
                                    │  @export initial_routes: [TestRoute{path="/:lol"}]
                                    │  @export request_path: "/:lol=1"
                                    │
                                    ├─ @onready context = Router.new(initial_routes)
                                    │                        │
                                    │                    route_map: {"/:lol" → TestRoute}
                                    │
                                    ├─ _ready()  ──► context.request("/:lol=1")
                                    │                   │
                                    │              generate_request_data()
                                    │                   │
                                    │              [RequestData{path="/:lol", params={lol:"1"}}]
                                    │                   │
                                    │              process_request()
                                    │                   │
                                    │              TestRoute.execute(context, delta)
                                    │                   │
                                    │              print("Executing TestRoute with path: /:lol")
                                    │
                                    └─ _process(delta) ── (same flow, every frame)
```

---

### Summary

Behavior-Router is a **proof-of-concept, early-stage Godot 4.4 library** that replaces state machines with a URL-style hierarchical routing system. Routes are Godot `Resource` objects with path strings and an `execute(context, delta)` callback. A `Router` manages the route map and dispatches requests by parsing path strings into typed `RequestData` objects. The path format allows embedding typed parameters inline (`/:velocity=1,2,3`) which are converted to GDScript types via the `PathParams` utility. The `enter`/`exit` lifecycle hooks are defined but not yet wired up, the top-level `Router` class is an empty stub, and the only test is a manual print-based scene. There are no signals, no autoloads, no addons, and no test framework.
