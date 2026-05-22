extends enemy
class_name fly_enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_x = global_position.x
	HP=5
	current_speed= IDLE_SPEED
	direction=1

		
