extends Resource
class_name RouteContext

var path: String = ""
var params: Dictionary[String, String] = {}
var route: Route
var state: Dictionary = {}

func _init(_path: String, _params: Dictionary[String, String], route_map: Dictionary[String, Route]) -> void:
	self.path = _path
	self.params = _params
	self.route = route_map.get(_path)
