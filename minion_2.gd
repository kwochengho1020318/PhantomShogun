extends enemy


func activated_mode()->void:
	if player_in_range and attack_phase==Attack_Phase.NORMAL :
		if can_attack:
			
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
	if dist>90:
		direction=player_direction
	elif dist<70:
		
		direction = -player_direction
	else:
		direction=0
