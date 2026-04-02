# test_route.gd
class_name TestRoute
extends Route

const ParamAPI := Router.ParamAPI


func execute(r: Router, delta := 0.0):
	var result := super.execute(r, delta)

	var ctx: RouteContext = r.get_current_context()
	var state := ctx.state if ctx.state else {}

	var force := ParamAPI.toVector3(ctx.params, "force")
	state["velocity"] = state.get("velocity", Vector3()) + force

	ctx.state = state

	print(state)
	return result
