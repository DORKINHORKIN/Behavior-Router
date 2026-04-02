extends Node

signal request_path_changed(path: String)
@export var request_path: String:
	set(value):
		request_path = value
		if (router):
			router.set_route(value)
		request_path_changed.emit(value)

@export var initial_routes: Array[Route]


static func request(_path) -> Array[RouteContext]:
	return Router.make_context(_path)
const ParamAPI := Router.ParamAPI

@onready var router := Router.new(initial_routes)


func _ready():
	request_path = request_path

func _process(_delta):
	router.process(_delta)


func _test():
	var path_data = request(request_path)
	for data in path_data:
		print("Path: ", data.path)

		if (data.params.get("velocity") != null):
			print("Velocity: ", ParamAPI.toVector3(data.params, "velocity"))

		if (data.params.get("lol") != null):
			print("Lol: ", ParamAPI.toInt(data.params, "lol"))

		if (data.params.get("ha") != null):
			print("Ha: ", data.params.get("ha"))
