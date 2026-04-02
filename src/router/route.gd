# route.gd
class_name Route
extends Resource

@export var path: String = "/"
@export var extra_paths: Array[String] = []

const ProcessResult = Router.ProcessResult


func _ctx(r: Router) -> RouteContext:
	return r.get_current_context()


func _state(ctx: RouteContext) -> Dictionary:
	if not ctx.state:
		ctx.state = {}
	return ctx.state


func _init_extra(r: Router, ctx: RouteContext) -> void:
	var state := _state(ctx)

	if state.has("_extra"):
		return

	state["_extra"] = {}

	for path: String in extra_paths:
		state["_extra"][path] = r.make_context(path, r.route_map)


func _process_extra(r: Router, delta: float, ctx: RouteContext) -> void:
	var state := _state(ctx)

	for extra_ctx in state.get("_extra", {}).values():
		r.process(delta, extra_ctx)


func _end_extra(r: Router, ctx: RouteContext) -> void:
	var state := _state(ctx)

	for extra_ctx in state.get("_extra", {}).values():
		if extra_ctx.route:
			extra_ctx.route.end(r)

	state.erase("_extra")


# Lifecycle API

func enter(r: Router):
	var ctx := _ctx(r)
	_init_extra(r, ctx)
	return ProcessResult.Continue


func execute(r: Router, delta := 0.0) -> ProcessResult:
	var ctx := _ctx(r)
	_process_extra(r, delta, ctx)
	return ProcessResult.Continue


func end(r: Router):
	var ctx := _ctx(r)
	_end_extra(r, ctx)
	return ProcessResult.Continue
