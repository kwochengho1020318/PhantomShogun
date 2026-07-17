extends enemy


var action_queue= []
var action_name

func activated_mode()->void:
	if !action_queue.is_empty() and attack_phase == Attack_Phase.NORMAL:
		if action_queue[0] is Action:
			action_queue[0].activate()
			action_name = action_queue[0]._action_name
			action_queue.pop_front()
			return
		
	if $AttackComponent.get_player_in_range() and action_queue.is_empty():
		action_queue.append(Action.new("slash1",slash1))
		action_queue.append(Action.new("slash2",slash1))

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
func _manage_animate()->void:
	if dead:
		if $Animation.animation !=("dead"):
			$Animation.play("dead")
		return
	if state==State.DAMAGED:
		if damaged_count%2+1==1:
			
			if $Animation.animation!=("damaged_1"):
				$Animation.play("damaged_1")
		else:
			if $Animation.animation!=("damaged_2"):
				$Animation.play("damaged_2")
		return
	if attack_phase==Attack_Phase.PRE_ATTACK:
		if $Animation.animation!="%s_pre_attack" %[action_name]:
			$Animation.play("%s_pre_attack" %[action_name])
		
		return
	if attack_phase==Attack_Phase.ATTACKING:
		if $Animation.animation!="%s_attack" %[action_name]:
			$Animation.play("%s_attack" %[action_name])
			
		return
	if locomotion_state==Locomotion.IDLE:
		if $Animation.animation!=("idle"):
			$Animation.play("idle")
		return
	if locomotion_state==Locomotion.RUN:
		if $Animation.animation!=("walk"):
			$Animation.play("walk")
		return
func slash1(action_name):
	$Timers/AttackCoolDownTimer.start()
	$AttackComponent.switch_action(action_name)
	attack_phase= Attack_Phase.PRE_ATTACK
func slash2(action_name):
	$AttackComponent.switch_action(action_name)
	attack_phase= Attack_Phase.PRE_ATTACK
func _on_cleanup_timer_timeout() -> void:
	pass
