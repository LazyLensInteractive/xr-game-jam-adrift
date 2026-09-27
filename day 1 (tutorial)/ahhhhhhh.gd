extends Area3D
func activate():
	if Data.bottle_thrown == true:
		print("sent")
		Events.event_shift()
	else:
		print("broke or task not done")

func _physics_process(_delta):
	if not get_overlapping_bodies().is_empty():
		for body in get_overlapping_bodies():
			if body is GXDKCollisionHand:
				var trig = body.get_input("trigger")
				var grip = body.get_input("grip")
				if (trig != null and float(trig) > 0.7) or (grip != null and float(grip) > 0.7):
					activate()
