
extends Node3D
signal all_tasks_done
@export var display: GXDKUI2Din3D 
@export var day_header: String = "DAY 84"

var task_states := {}
var task_texts := {
	"note":   "throw the note into the sea",
	"trap":   "check the fish trap",
	"damage": "patch the hull",
	"cup":    "put out the rain cup",
}

var viewport: SubViewport
var labels := {}

func _ready() -> void:
	_build_ui()
	_configure_day()
	_refresh()

func _build_ui() -> void:
	viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.size = Vector2i(1024, 512)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.disable_3d = true
	add_child(viewport)
	var box := VBoxContainer.new()
	box.position = Vector2(32, 24)
	box.add_theme_constant_override("separation", 10)
	viewport.add_child(box)

	var header := RichTextLabel.new()
	header.bbcode_enabled = true
	header.fit_content = true
	header.text = "[center][b]%s[/b][/center]" % day_header
	box.add_child(header)

	for key in task_texts:
		var l := RichTextLabel.new()
		l.bbcode_enabled = true
		l.fit_content = true
		labels[key] = l
		box.add_child(l)
	display.display_viewport = viewport

func _configure_day() -> void:
	if not Data.boat_dmg:
		labels["damage"].visible = false
	if not Data.storm_day:
		labels["cup"].visible = false
	for key in task_texts:
		task_states[key] = false

func complete_task(task_name: String) -> void:
	if task_states.has(task_name) and not task_states[task_name]:
		task_states[task_name] = true
		_refresh()
		if _check_all_done():
			all_tasks_done.emit()

func _check_all_done() -> bool:
	for key in task_states:
		if not task_states[key] and labels[key].visible:
			return false
	return true

func _refresh() -> void:
	for key in task_texts:
		if labels[key].visible == false:
			continue
		if task_states[key]:
			labels[key].text = "[s][color=gray]%s[/color][/s]" % task_texts[key]
		else:
			labels[key].text = task_texts[key]
