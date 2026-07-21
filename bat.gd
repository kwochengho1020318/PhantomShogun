extends enemy
class_name fly_enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_x = global_position.x
	HP=5
	current_speed= IDLE_SPEED


func _moving_action()->void:
	if state==State.DAMAGED:
		return
	if attack_phase!=Attack_Phase.NORMAL:
		velocity.x=0 
		return
	if direction:
		velocity = direction * (current_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		
func activated_mode()->void:
	
	current_speed=SPEED
	if player==null:
		print("no player!!")
	var dist = global_position.distance_to(player.global_position)
	var dir = (player.global_position-global_position).normalized()
	if (player.global_position.x-global_position.x)>0:
		player_direction=1
	else:
		player_direction = -1
	if Global.is_player_damaged:
		direction = -dir*0.3
	elif dist>30 :
		direction = Vector2(player_direction,((player.global_position.y-global_position.y)/30)).normalized()
	
	else:
		direction= Vector2(0,0)
