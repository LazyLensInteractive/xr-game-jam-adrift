extends Node3D
@onready var bottle_to_do: Node3D = $BottleToDo
@onready var fish_to_do: Node3D = $FishToDo
@onready var cup_to_do: Node3D = $CupToDo


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Data.cup_out == true:
		cup_to_do.hide()
	if Data.bottle_thrown == true:
		bottle_to_do.hide()
	if Data.bottle_thrown == false:
		bottle_to_do.show()
	if Data.fished == true:
		fish_to_do.hide()
