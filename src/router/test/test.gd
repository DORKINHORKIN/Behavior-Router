extends Node

@export var request_path: String:
	set(value):
		request_path = value
		if (router):
			router.request(value)
		request_path_changed.emit(value)

signal request_path_changed(path: String)
@export var initial_routes: Array[Route]

@onready var router := Router.new(initial_routes)

static func request(_path) -> Array[RequestData]:
	return Router.generate_request_data(_path)
const PathParams := Router.PathParams

func _ready():
	request_path = request_path

func _process(_delta):
	router.process_request(_delta)


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
