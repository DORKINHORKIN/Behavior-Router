
so whats the idea...

I'm using a router in place of a state machine
There is a context object that is important for communicating between the states, router, and engine.

Got to make sure to process the path before parameters


I'm unsure about how I want the api to be organized or even if this works at all but it was fun to say the least.


what is the use case?

```gdscript

class_name TestRoute
extends Route

func enter(ctx): pass
func end(ctx): pass
func update(ctx, delta): 
    const router = ctx.router
    
    # processes all paths in order until current path
    processAncestorPaths(ctx.route.paths) 
    
    
    const params = ctx.route.params
    var velocity = params["velocity"] = "(x,y,z)"
    # since this is a string, 
    # I need to find a way to turn it into a vector
    # probably could do that by
    # - and removing "()"
    # - and split by ","
    var velocity = PathParams.Vector3(params[velocity]) 
    pass
``` 


class PathParams extends RefCounted:
    static func toVector3(params): #expects a string (e.g. "1,2,3")
    static func toFloat:
    static func toInt:


class PathData extends RefCounted:
    var path : String = ""
    var params : Dictionary[String, String]= {}
    var route : Route = null


static func generate_path_data(path="/lol/:velocity=(1,2,3)"):
    var routes = []
    var walked = ""
    for pathname in path.split("/"):
        var pair : Dictionary[String, Variant ]= {}
        if (pathname.starts_with(":")):
            const split = pathname.replace(":" ,"").split("=")
            pair = {split[0]: split[1]}

        walked += "/" + pathname 
        routes.push({
            "path": walked,
            "params": {
                key: value
            },
            "route": null
        })
            

```