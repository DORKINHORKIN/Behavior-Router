class_name TestRoute
extends Route


func execute(r: Router, _delta:=0.0):
	var this = r.data[r.data.size()-1]
	var state = this["state"]
	var params = {
		force = Router.PathParams.toVector3(this.params, "force")
	}

	this.state.set("velocity", this.state.get("velocity", Vector3()) + params.force)
	print(this["state"])
	pass
