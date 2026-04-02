class_name TestRoute
extends Route

const ParamAPI := Router.ParamAPI

func execute(r: Router, _delta:=0.0):
	var req: RequestData = r.get_current_request()

	var force = ParamAPI.toVector3(req.params, "force")
	req.state["velocity"] = req.state.get("velocity", Vector3()) + force

	print(req.state)
