@tool
extends CSGCombiner3D
class_name SimpleCSGBaker

## Generate the mesh with a concave collision shape.
## Best suited for static environments such as rooms or complex level geometry.
## Provides accurate collision, but dynamic bodies may require additional performance considerations.
@export var generate_concave_collision: bool = false:
	set(value):
		generate_concave_collision = value
		if value:
			generate_convex_collision = false

## Generate the mesh with a convex collision shape.
## Best suited for dynamic objects such as props, physics bodies, or movable elements.
## Faster and more stable for physics simulation, but less precise than concave collisions.
@export var generate_convex_collision: bool = false:
	set(value):
		generate_convex_collision = value
		if value:
			generate_concave_collision = false

var _pending_bake: bool = false

func bake_mesh() -> void:
	
	if not Engine.is_editor_hint():
		return
	
	var old: Node = get_node_or_null("BakedMesh")
	if old:
		_show_replace_warning()
		return
	
	_bake()

func _show_replace_warning() -> void:
	
	if _pending_bake:
		return
	
	_pending_bake = true
	
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.title = "Replace Baked Mesh"
	dialog.dialog_text = "An existing baked mesh will be replaced.\nDo you want to continue?"
	
	dialog.confirmed.connect(func() -> void:
		_pending_bake = false
		_bake()
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func() -> void:
		_pending_bake = false
		dialog.queue_free()
	)
	
	var editor_root: Control = EditorInterface.get_base_control()
	editor_root.add_child(dialog)
	dialog.popup_centered()

func _bake() -> void:
	
	if not Engine.is_editor_hint():
		return
	
	if not is_root_shape():
		push_error("SimpleCSGBaker: This node must be the CSG root.")
		return
	
	_update_shape()
	await get_tree().process_frame
	
	var baked_mesh: ArrayMesh = bake_static_mesh()
	
	if baked_mesh == null or baked_mesh.get_surface_count() == 0:
		push_error("SimpleCSGBaker: bake_static_mesh() returned empty mesh.")
		return
	
	var old: Node = get_node_or_null("BakedMesh")
	if old:
		old.free()
	
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "BakedMesh"
	mesh_instance.mesh = baked_mesh
	
	add_child(mesh_instance)
	mesh_instance.owner = get_tree().edited_scene_root
	
	if generate_concave_collision:
		_create_concave_collision(mesh_instance)
		
	elif generate_convex_collision:
		_create_convex_collision(mesh_instance)

func _get_collision_body_name() -> String:
	
	if generate_concave_collision:
		return "BakedMesh_Static_ConcaveCollision"
	
	elif generate_convex_collision:
		return "BakedMesh_Static_ConvexCollision"
	
	return "BakedMesh_Static_NoCollision"

func _get_collision_debug_color() -> Color:
	
	if generate_concave_collision:
		return Color(1.0, 0.2, 0.2, 0.9)
	
	elif generate_convex_collision:
		return Color(0.2, 0.4, 1.0, 0.9)
	
	return Color(1.0, 1.0, 1.0, 0.5)

func _create_concave_collision(mesh_instance: MeshInstance3D) -> void:
	
	mesh_instance.create_trimesh_collision()
	
	var body: StaticBody3D = mesh_instance.get_child(0) as StaticBody3D
	if not body:
		return
	
	body.name = _get_collision_body_name()
	body.owner = get_tree().edited_scene_root
	
	var shape: CollisionShape3D = body.get_child(0) as CollisionShape3D
	if shape:
		shape.debug_color = _get_collision_debug_color()

func _create_convex_collision(mesh_instance: MeshInstance3D) -> void:
	
	mesh_instance.create_convex_collision()
	
	var body: StaticBody3D = mesh_instance.get_child(0) as StaticBody3D
	if not body:
		return
	
	body.name = _get_collision_body_name()
	body.owner = get_tree().edited_scene_root
	
	var shape: CollisionShape3D = body.get_child(0) as CollisionShape3D
	if shape:
		shape.debug_color = _get_collision_debug_color()
