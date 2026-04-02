class_name RoutingContext
extends Resource

@export var route_map: Dictionary[String, Route]
var request_data : Array[RequestData]


func _init(_routes) -> void:
	route_map = generate_route_map(_routes)

func request(route_path) :
	request_data = generate_request_data(route_path, route_map)
	return request_data

func process_request(_request_data: Array[RequestData], _delta := 0.0):
	for req : RequestData in _request_data:
		var route = req.path
		req.route.execute(self, _delta)
	pass

static func generate_route_map(routes: Array[Route]) -> Dictionary[String, Route]:
	var map: Dictionary[String, Route] = {}
	for route in routes:
		map[route.path] = route
	return map

static func generate_request_data(path = "/lol/:velocity=1,2,3", _route_map: Dictionary[String, Route] = {}) -> Array[RequestData]:
	var data: Array[RequestData] = []
	var walked = ""
	for pathname: String in path.rsplit("/", false):
		var pair: Dictionary[String, Variant] = {}
		if (pathname.begins_with(":")):
			var split = pathname.rsplit("=", false)
			pathname = split[0]
			var value = split[1] if split.size() >1 else ""
			pair = {pathname.replace(":", ""): value }

		walked += "/" + pathname
		data.append(RequestData.new(walked, pair, _route_map))
	return data



class PathParams extends RefCounted:
	static func toVector3(params: Dictionary[String, String], key: String): # expects a string (e.g. "1,2,3")
		var result = Vector3()
		var value = params.get(key)
		if value != null:
			var Vectors = value.rsplit(",", false)
			if Vectors.size() == 3:
				result.x = Vectors[0].to_float()
				result.y = Vectors[1].to_float()
				result.z = Vectors[2].to_float()
		return result

	static func toFloat(params: Dictionary[String, String], key: String):
		var result = 0.0
		var value = params.get(key)
		if value != null:
			var components = value.rsplit(",", false)
			if components.size() == 1:
				result = components[0].to_float()
		return result

	static func toInt(params: Dictionary[String, String], key: String):
		var result = 0
		var value = params.get(key)
		if value != null:
			var components = value.rsplit(",", false)
			if components.size() == 1:
				result = components[0].to_int()
		return result


class Router extends RefCounted:
	pass
