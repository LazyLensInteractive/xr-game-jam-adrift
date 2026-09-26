#spent way too much time on this.... had so many bugs dont even know what it does at this point everything i thought i knew was wrong akes the paper look nice 
#the const for the shader was made by AI don't smite me please i hevent learned much of shader code yet its next on my list
#mark unused
class_name FlexiNote
extends RigidBody3D

@export_range(0.10, 0.35, 0.005) var note_width: float = 0.19:
	set(v): note_width = v; _rebuild()
@export_range(0.10, 0.50, 0.005) var note_height: float = 0.26:
	set(v): note_height = v; _rebuild()
@export var bend_amount: float = 0.035
@export var idle_flutter: float = 0.002
@export var motion_flutter: float = 0.006
@export var text_file: String = ""

var _mat: ShaderMaterial
var _text_label: Label

const SHADER := "
shader_type spatial;
render_mode cull_disabled;

uniform vec3 paper_color : source_color = vec3(0.94, 0.91, 0.83);
uniform sampler2D front_tex : source_color, filter_linear;
uniform float bend_amount : float = 0.035;
uniform float flutter_amount : float = 0.002;

void vertex() {
	// how close to the paper's long edges (top/bottom): 0 centre, 1 edge
	float edge := abs(UV.y - 0.5) * 2.0;
	VERTEX.z -= pow(edge, 2.0) * bend_amount;
	float wave := sin(TIME * 2.3 + UV.y * 6.0 + UV.x * 1.5);
	VERTEX.z += wave * flutter_amount * (0.4 + 0.6 * edge);
}

void fragment() {
	vec4 col := vec4(paper_color, 1.0);
	if (FRONT_FACING) {
		vec4 t := texture(front_tex, UV);
		col.rgb = mix(paper_color, t.rgb, t.a);
	}
	ALBEDO = col.rgb;
	ROUGHNESS = 0.95;
	EMISSION = paper_color * 0.05;
}
"

func _ready() -> void:
	_rebuild()
	if text_file != "":
		load_from_file(text_file)

func _physics_process(_delta: float) -> void:
	var speed := linear_velocity.length()
	_mat.set_shader_parameter("flutter_amount",
		idle_flutter + min(speed * motion_flutter, 0.05))

func set_text(txt: String) -> void:
	_text_label.text = txt

func load_from_file(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("FlexiNote: no file at " + path)
		return
	set_text(f.get_as_text())


func _rebuild() -> void:
	for c in get_children():
		c.queue_free()
	if not is_inside_tree():
		await ready
	var pm := PlaneMesh.new()
	pm.size = Vector2(note_width, note_height)
	pm.subdivide_width = 12
	pm.subdivide_depth = 16

	_mat = ShaderMaterial.new()
	_mat.shader = _make_shader()
	_mat.set_shader_parameter("bend_amount", bend_amount)
	pm.material = _mat

	var mi := MeshInstance3D.new()
	mi.mesh = pm
	add_child(mi)
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(note_width, note_height, 0.002)
	cs.shape = box
	add_child(cs)
	mass = 0.02
	linear_damp = 2.0
	angular_damp = 3.0
	var vp := SubViewport.new()
	vp.size = Vector2(512, 700)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var tr := TextureRect.new()
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vp.add_child(tr)
	_text_label = Label.new()
	_text_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 34)
	tr.add_child(_text_label)
	_mat.set_shader_parameter("front_tex", vp.get_texture())

func _make_shader() -> Shader:
	var s := Shader.new()
	s.code = SHADER
	return s
