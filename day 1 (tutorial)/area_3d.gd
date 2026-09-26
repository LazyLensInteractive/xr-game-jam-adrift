extends Area3D
@onready var wooden_crate_01_lid: MeshInstance3D = $"../wooden_crate_01_1k/wooden_crate_01_lid"

func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body is GXDKCollisionHand: #this should work? 
		wooden_crate_01_lid.rotation_degrees.x = -64.0
