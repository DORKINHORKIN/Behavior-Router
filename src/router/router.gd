class_name Router
extends Resource

@export var route_map: Dictionary[String, Route]
var context : Array[RouteContext]

# Lifecycle
func _init(_routes) -> void:
	route_map = generate_route_map(_routes)

func set_route(route_path) :
	var result = make_context(route_path, route_map)
	if (result):
		# end previous
		if (context):
			for c : RouteContext in context:
				if c.route:
					c.route.exit(self)

		context = result
		#state new
		for c : RouteContext in context:
			if c.route:
				c.route.enter(self)

func process(_delta := 0.0, _context: Array[RouteContext] = context):
	var process_result : = ProcessResult.Error

	for c : RouteContext in _context:
		if c.route:
			process_result = c.route.execute(self, _delta)

			# if any route returns a complete status, stop processing
			if process_result == ProcessResult.Error:
				return ProcessResult.Error
			elif process_result == ProcessResult.Complete:
				return ProcessResult.Complete

	return process_result

func get_current_context(_context: Array[RouteContext] = context) -> RouteContext:
	var size = _context.size()
	if size > 0:
		return _context[size-1]
	return null

# API
enum ProcessResult {
	Error,
	Complete,
	Continue
}

static func generate_route_map(routes: Array[Route]) -> Dictionary[String, Route]:
	var map: Dictionary[String, Route] = {}
	for route in routes:
		map[route.path] = route
	return map

static func make_context(path = "", _route_map: Dictionary[String, Route] = {}) -> Array[RouteContext]:
	var _context: Array[RouteContext] = []
	var walked = ""
	for pathname: String in path.rsplit("/", false):
		var pair: Dictionary[String, Variant] = {}
		if (pathname.begins_with(":")):
			var split = pathname.rsplit("=", false)
			pathname = split[0]
			var value = split[1] if split.size() >1 else ""
			pair = {pathname.replace(":", ""): value }

		walked += "/" + pathname
		_context.append(RouteContext.new(walked, pair, _route_map))
	return _context



class ParamAPI extends RefCounted:
	static func toVector3(params: Dictionary[String, String], key: String) -> Vector3:
		var result = Vector3()
		var value = params.get(key)
		if value != null:
			var Vectors = value.rsplit(",", false)
			if Vectors.size() == 3:
				result.x = Vectors[0].to_float()
				result.y = Vectors[1].to_float()
				result.z = Vectors[2].to_float()
		return result

	static func toFloat(params: Dictionary[String, String], key: String) -> float:
		var result = 0.0
		var value = params.get(key)
		if value != null:
			var components = value.rsplit(",", false)
			if components.size() == 1:
				result = components[0].to_float()
		return result

	static func toInt(params: Dictionary[String, String], key: String) -> int:
		var result = 0
		var value = params.get(key)
		if value != null:
			var components = value.rsplit(",", false)
			if components.size() == 1:
				result = components[0].to_int()
		return result
