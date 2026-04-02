extends Node

@export var request_path: String = "/lol/:velocity=1,2,3/:lol=4/:ha=lmao"
@export var initial_routes: Array[Route]

@onready var context := RoutingContext.new(initial_routes)

static func request(_path) -> Array[RequestData]:
	return RoutingContext.generate_request_data(_path)
const PathParams := RoutingContext.PathParams

func _ready():
	context.process_request(context.request(request_path))

func _process(_delta):
	context.process_request(context.request(request_path), _delta)


func _test():
	var path_data = request(request_path)
	for data in path_data:
		print("Path: ", data.path)

		if (data.params.get("velocity") != null):
			print("Velocity: ", PathParams.toVector3(data.params, "velocity"))

		if (data.params.get("lol") != null):
			print("Lol: ", PathParams.toInt(data.params, "lol"))

		if (data.params.get("ha") != null):
			print("Ha: ", data.params.get("ha"))
