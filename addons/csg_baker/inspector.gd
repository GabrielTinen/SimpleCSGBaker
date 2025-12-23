@tool
extends EditorInspectorPlugin

var plugin: EditorPlugin

func _init(p_plugin: EditorPlugin) -> void:
	plugin = p_plugin

func _can_handle(object: Object) -> bool:
	return object is SimpleCSGBaker

func _parse_begin(object: Object) -> void:
	
	var target: SimpleCSGBaker = object
	
	var container: VBoxContainer = VBoxContainer.new()
	container.add_theme_constant_override("separation", 6)
	
	var title: RichTextLabel = RichTextLabel.new()
	title.bbcode_enabled = true
	title.fit_content = true
	title.scroll_active = false
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = "[center][b][font_size=16]CSG Baker Tool[/font_size][/b][/center]"
	container.add_child(title)
	
	container.add_child(HSeparator.new())
	
	# --- Bake Button ---
	var bake_button: Button = Button.new()
	bake_button.text = "Bake Mesh"
	
	bake_button.tooltip_text = \
	"Bake the mesh with or without collision.\n" + \
	"To include collision, choose one of the options below.\n" + \
	"Leave both options unchecked to generate the mesh only.\n" +  \
	"Only visible CSG operations are included in the generated mesh."

	bake_button.pressed.connect(func() -> void:
		target.bake_mesh()
	)
	container.add_child(bake_button)
	
	container.add_child(HSeparator.new())
	
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 1)
	container.add_child(spacer)
	
	add_custom_control(container)
