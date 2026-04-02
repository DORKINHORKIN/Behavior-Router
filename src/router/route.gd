class_name Route
extends Resource

@export var path: String = ""

func enter(context: RoutingContext):
	pass

func exit(context: RoutingContext):
	pass

func execute(context: RoutingContext, delta:=0.0):
	pass
