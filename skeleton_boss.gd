extends enemy


var action_queue= []
var action_name

func activated_mode()->void:
	if !action_queue.is_empty() :
		current_action = action_queue[0]
		if current_action is Action:
			if current_action._action_type=="attack":
				if attack_phase == Attack_Phase.NORMAL and $AttackComponent.get_player_in_range():
					action_name = current_action._action_name
					current_action.activate()
					action_queue.pop_front()
					return 
			else:
				current_action.activate()
				action_queue.pop_front()
				return
		
	if  action_queue.is_empty():
		action_queue.append(Action.new("hop",hop,"move"))
		
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
		if $Animation.animation!=("damaged_%d" %[break_level]):
			$Animation.play("damaged_%d" %[break_level])
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
	current_action=null
	
func slash2(action_name):
	$AttackComponent.switch_action(action_name)
	attack_phase= Attack_Phase.PRE_ATTACK
	current_action=null

func hop(action_name):
	
	velocity=Vector2(600,-50)
func _on_cleanup_timer_timeout() -> void:
	pass
