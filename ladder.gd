extends Node2D
class_name ladder
@export var is_terminal = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name =="Player" :
		body.interacted_object =self

		body.is_on_ladder=true


func exit(body)->void:
		body.is_on_ladder=false
		body.is_climbing=false
		body.interacted_object =null
		body.set_collision_mask_value(1,true)
