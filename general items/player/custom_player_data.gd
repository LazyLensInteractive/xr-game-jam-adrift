extends Node3D
var hunger_rate = 0.35

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Data.amount_food = max(Data.amount_food - hunger_rate * delta, 0.0) # should be about 5 minutes? 


func _on_bottle_detect_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
