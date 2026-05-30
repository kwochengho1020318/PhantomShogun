extends enemy

var random_action = 1

func activated_mode()->void:
	
	if $AttackComponent.get_player_in_range() and can_attack :
		attack_phase= Attack_Phase.PRE_ATTACK
		can_attack= false
		return
	current_speed=SPEED
	if player==null:
		print("no player!!")
	var dist = global_position.distance_to(player.global_position)
	
	if (player.global_position.x-global_position.x)>0:
		player_direction=1
	else:
		player_direction = -1
	if dist>80:
		direction.x=player_direction
	elif dist<30:
		direction.x = 0
	else:
		direction.x = random_action*player_direction


func _on_random_action_timer_timeout() -> void:
	
	random_action = randi_range(-1,1)
