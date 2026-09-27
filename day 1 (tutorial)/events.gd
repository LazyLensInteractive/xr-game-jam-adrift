extends Node

const SCENE_ROOT := "/root/Day1"

var island: Node3D
var stormnote: RigidBody3D
var directional_light_3d: DirectionalLight3D
var storm: StormOverlay

var current_event_id: int = 0

func _grab_nodes() -> void:
	# Fetch fresh references every time (cheap, and survives scene weirdness)
	island = get_node_or_null(SCENE_ROOT + "/island") as Node3D
	stormnote = get_node_or_null(SCENE_ROOT + "/stormnote") as RigidBody3D
	directional_light_3d = get_node_or_null(SCENE_ROOT + "/DirectionalLight3D") as DirectionalLight3D
	storm = get_node_or_null(SCENE_ROOT + "/storm") as StormOverlay

func event_shift():
	_grab_nodes()
	
	if not island or not stormnote or not directional_light_3d or not storm:
		push_error("event_shift(): missing nodes — check names under " + SCENE_ROOT)
		return  # bail out instead of crashing later
	
	current_event_id += 1
	Data.bottle_thrown = false
	
	print("Event shifted to: ", current_event_id)
	
	match current_event_id:
		1:
			island.show()
		2:
			island.hide()
			storm.show()
			directional_light_3d.light_energy = 0.2
			stormnote.show()
			stormnote.position = Vector3(-1.56, 1.777, 3.999)
		3:
			get_tree().change_scene_to_file("res://basement.tscn")
		_:
			push_warning("event_shift(): event ID exceeds defined events (3)")
