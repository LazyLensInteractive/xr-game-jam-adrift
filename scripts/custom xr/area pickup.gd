# there may be a simpler way to do this but can be used for future projects no idea if old xr tools can do this but thanks for all the comments in GXDK or this wouldent be possible so quick
# pretty much choose an item to spawn create the collision and just like that when player grabs in this area item spawns in the hand
# not as good at commenting code as Bastiaan Olij is.... sometimes i feel i fall asleep and code exists all the sudden its crazy... hopefully its a bit understandable lol
#requires player hands to have gxdkpikup as children
# everything else should work scenes you want to spawn in hands need to have a root of rigidbody3d (not node 3d default) 
# optinally you can have grab points on said models but i havent tested that much just added it cause it was there.... 

@tool
class_name AreaGrab
extends Area3D

@export var item_scene: PackedScene:
	set(value):
		item_scene = value
		notify_property_list_changed()

@export var size: Vector3 = Vector3(0.3, 0.3, 0.3):
	set(value):
		size = value.max(Vector3.ONE * 0.01)
		if is_inside_tree():
			_update_volume()
@export var cooldown: float = 0.5
@export var grip_action: String = "grip"
@export var press_threshold: float = 0.8
@export var release_threshold: float = 0.6
var _box: BoxShape3D
var _preview_mesh: MeshInstance3D
var _warned_no_pickup: Array = []
var _hand_states: Dictionary = {}
var _last_spawn_time: float = -100.0

func _ready() -> void:
	_box = BoxShape3D.new()
	var cs := CollisionShape3D.new()
	cs.shape = _box
	add_child(cs, false, Node.INTERNAL_MODE_BACK)
	if Engine.is_editor_hint():
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.2, 0.8, 0.5, 0.25)
		var bm := BoxMesh.new()
		bm.size = size
		bm.material = mat
		_preview_mesh = MeshInstance3D.new()
		_preview_mesh.mesh = bm
		add_child(_preview_mesh, false, Node.INTERNAL_MODE_BACK)
	_update_volume()
	if not Engine.is_editor_hint():
		monitoring = true

func _update_volume() -> void:
	if _box:
		_box.size = size
	if _preview_mesh:
		_preview_mesh.mesh.size = size

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var hands: Array = []
	for body in get_overlapping_bodies():
		if body is GXDKCollisionHand or body is XRController3D:
			hands.push_back(body)
			if not body in _hand_states:
				_hand_states[body] = { "pressed": false }
	for hand in _hand_states.keys():
		if not hands.has(hand):
			_hand_states.erase(hand)
	for hand in hands:
		var state: Dictionary = _hand_states[hand]
		var grip := _get_grip_value(hand)
		if not state["pressed"] and grip > press_threshold:
			state["pressed"] = true
			_try_place_in(hand)
		elif state["pressed"] and grip < release_threshold:
			state["pressed"] = false

func _get_grip_value(hand) -> float:
	if hand is GXDKCollisionHand:
		var input = hand.get_input(grip_action)
		if input == null:
			return 0.0
		return float(input)
	elif hand is XRController3D:
		return hand.get_float(grip_action)
	return 0.0

func _try_place_in(hand) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if not item_scene:
		return
	if now - _last_spawn_time < cooldown:
		return

	var pickup := GXDKPickup.get_pickup(hand)
	if not pickup:
		if not hand in _warned_no_pickup:
			_warned_no_pickup.push_back(hand)
		return
	if pickup.has_picked_up():
		return

	_last_spawn_time = now
	var item := item_scene.instantiate()
	get_tree().current_scene.add_child(item)
	var hand_xf := _hand_transform(hand)
	var gp := _find_grab_point(item)
	if gp:
		var rel: Transform3D = item.global_transform.inverse() * gp.global_transform
		item.global_transform = hand_xf * rel.inverse()
	else:
		item.global_position = hand_xf.origin
	var go := GXDKPickup.GrabObject.new()
	go.body = item
	go.collision_point = hand_xf.origin
	go.collision_normal = hand_xf.basis.x
	pickup.pickup_object(go)
func _hand_transform(hand) -> Transform3D:
	if hand is GXDKCollisionHand:
		return hand.get_tracked_transform()
	return hand.global_transform

func _find_grab_point(node: Node) -> GXDKGrabPoint:
	for child in node.get_children():
		if child is GXDKGrabPoint:
			return child
	return null
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not item_scene:
		warnings.append("No item scene assigned")
	return warnings
