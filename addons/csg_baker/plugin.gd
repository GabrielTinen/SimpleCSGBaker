@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	inspector_plugin = preload("res://addons/csg_baker/inspector.gd").new(self)
	add_inspector_plugin(inspector_plugin)
	
	# Register Custom Node
	add_custom_type(
		"SimpleCSGBaker",          
		"CSGCombiner3D",                
		preload("res://addons/csg_baker/csg_baker.gd"),
		load("res://addons/csg_baker/SimpleCSGBakerIcon.png")
	)
	
func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)
