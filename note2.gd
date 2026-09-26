extends RigidBody3D

@export var wobble_strength: float = 0.05

func _physics_process(delta):
	var speed = linear_velocity.length()
	rotation.x += sin(Time.get_ticks_msec() / 300.0) * wobble_strength * speed * delta
	rotation.z += cos(Time.get_ticks_msec() / 260.0) * wobble_strength * speed * delta
