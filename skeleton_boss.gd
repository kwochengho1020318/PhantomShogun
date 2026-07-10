extends enemy


var action_queue= []
func activated_mode()->void:
	if $AttackComponent.get_player_in_range() and can_attack :
		can_attack = false
		$Timers/AttackCoolDownTimer.start()

		attack_phase= Attack_Phase.PRE_ATTACK
		return
	current_speed=SPEED
	var dist = global_position.distance_to(player.global_position)
	if (player.global_position.x-global_position.x)>0:
		player_direction=1
	else:
		player_direction = -1
	
	if Global.is_player_busy():
		direction.x = 0
	elif player.global_position<global_position:
		direction.x=-1
	else:
		direction.x=1
