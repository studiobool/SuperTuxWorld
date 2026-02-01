@tool
extends EditorPlugin

# WORKER_COUNT determines how many threads are in the worker pool used by the VoronoiWorker.
# I don't really want to make this configurable right now, but if you're seeing this, you can change
# this number to whatever you want for varying performance needs. :)
var WORKER_COUNT := 8

func _enter_tree():
    add_custom_type("VoronoiShatter", "Node3D", preload("res://addons/voronoishatter/tools/voronoishatter.gd"), preload("res://addons/voronoishatter/tools/voronoishatter.svg"))
    add_custom_type("VoronoiCollection", "Node3D", preload("res://addons/voronoishatter/tools/voronoicollection.gd"), preload("res://addons/voronoishatter/tools/voronoicollection.svg"))
    var voronoi_generator = VoronoiGenerator.new()
    Engine.register_singleton("EditorVoronoiGenerator", voronoi_generator)


func _exit_tree():
    remove_custom_type("VoronoiShatter")
    remove_custom_type("VoronoiCollection")
    var voronoi_generator = Engine.get_singleton("EditorVoronoiGenerator") as VoronoiGenerator
    voronoi_generator.queue_free()
    Engine.unregister_singleton("EditorVoronoiGenerator")
