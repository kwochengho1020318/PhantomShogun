
extends CharacterBase
class_name enemy
@export var patrol_distance := 100.0
@export var SPEED :=100
@export var IDLE_SPEED:=50
@export var HP=5


var current_speed= IDLE_SPEED
var start_x

var direction
var waiting=false
var next_direction=0





var player_in_vision=false
var player=null
var player_in_range = false
var player_direction

var last_anime=""

var can_attack= true


func _ready() -> void:
	start_x = global_position.x
	HP=5
	current_speed= IDLE_SPEED
	direction=1
func _process(_delta: float) -> void:
	# manage the visual state and animate update
	_manage_state()
	_manage_animate()
func _physics_process(delta: float) -> void:
	if state==State.DEAD:
		_dead_action()
		
		return
	if not is_on_floor():
		if not $FlyComponent:
			velocity += get_gravity() * delta
	_character_action(delta)
	
	move_and_slide()

func _character_action(_delta)->void:
	
	_manage_state()
	
	strat_by_mode()
	_handle_direction()
	attack_action()
	_moving_action()
func _dead_action()->void:
	velocity= Vector2(0,0)
	$CollisionShape2D.disabled=true
	$AttackComponent/AttackArea/CollisionArea.disabled=true
	
	get_tree().call_group("live_group", "set_disabled", true)
func _handle_direction()->void:
	if !mode==Mode.ACTIVATED:
		facing_direction= direction
	else:
		if (player.global_position.x-global_position.x)>0:
			player_direction=1
		else:
			player_direction = -1
		
		facing_direction= player_direction
	if facing_direction==1:
		$Animation.flip_h=false
		
	if facing_direction==-1:
		$Animation.flip_h= true
	$AttackComponent.area_facing(facing_direction)
func _moving_action()->void:
	if state==State.DAMAGED:
		
		velocity.x=damaged_velocity
		return
	if attack_phase!=Attack_Phase.NORMAL:
		velocity.x=0 
		return
	if direction:
		velocity.x = direction * (current_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
func idle_mode()->void:
	current_speed=IDLE_SPEED
	if waiting:
		direction=0
		return
	if global_position.x>start_x+patrol_distance and facing_direction==1:
		wait_at_edge(-1)
	if  global_position.x<start_x-patrol_distance  and facing_direction==-1:
		wait_at_edge(1)
func activated_mode()->void:
	if player_in_range and can_attack :
		
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

	if player.global_position<global_position:
		direction=-1
	else:
		direction=1
		
	
func wait_at_edge(new_direction):
	waiting=true
	next_direction=new_direction
	$Timers/EdgeWaitTimer.start()
func _on_edge_wait_timer_timeout() -> void:
	waiting=false
	
	direction=next_direction
	###防止timeout後又因為滿足條件又進入新的cycle
	global_position.x += direction * 2


func attack_action():
	$AttackComponent.area_valid(!attack_phase==Attack_Phase.ATTACKING)
		


func _manage_state()->void:
	if HP<=0:
		$CollisionShape2D.disabled=true
		state=State.DEAD
	if can_see_player():
		mode=Mode.ACTIVATED
	else:
		mode= Mode.IDLE
	if velocity.length()==0:
		locomotion_state=Locomotion.IDLE
	else:
		
		locomotion_state=Locomotion.RUN
	
	
		
func strat_by_mode()->void:
	if state==State.DAMAGED or state==State.DEAD:
		return
	if mode==Mode.IDLE:
		idle_mode()
	elif mode==Mode.ACTIVATED:
		activated_mode()
func _manage_animate()->void:
	if state==State.DEAD:
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
		if $Animation.animation!=("pre_attack_1"):
			$Animation.play("pre_attack_1")
		
		return
	if attack_phase==Attack_Phase.ATTACKING:
		if $Animation.animation!=("attack_1"):
			$Animation.play("attack_1")
			
		return
	if locomotion_state==Locomotion.IDLE:
		if $Animation.animation!=("idle"):
			$Animation.play("idle")
		return
	if locomotion_state==Locomotion.RUN:
		if $Animation.animation!=("walk"):
			$Animation.play("walk")
		return






func can_see_player()->bool:
	if !player:
		return false
	var player_dir= (player.global_position-global_position).normalized()
	var vision_dir=Vector2.RIGHT if not $Animation.flip_h else Vector2.LEFT
	var angle = rad_to_deg(acos(vision_dir.dot(player_dir)))	
	if angle<45:
		return true
	else:
		return false






func _on_vision_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		player=body
		player_in_vision=true
	
		
func _on_vision_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		player=null
		player_in_vision=false


func _on_damage_recovery_timer_timeout() -> void:
	state= State.NORMAL


func _on_hit_box_area_entered(area: Area2D) -> void:
	if state==State.DEAD:
		return
	if area.is_in_group("player_area") and area.name=="AttackArea":
		
		if area.global_position.x-global_position.x>0:
			damaged_velocity=-damaged_velocity_scale
			direction=1
		else:
			damaged_velocity=damaged_velocity_scale

			direction=-1
		HP-=1
		if HP<=0:
			$Timers/CleanupTimer.start()
		state = State.DAMAGED
		damaged_count+=1
		$Timers/DamageRecoveryTimer.start()


func _on_animation_animation_finished() -> void:
	if attack_phase==Attack_Phase.PRE_ATTACK:
		attack_phase=Attack_Phase.ATTACKING
		return
	if attack_phase==Attack_Phase.ATTACKING:
		attack_phase=Attack_Phase.NORMAL
		$Timers/AttackCoolDownTimer.start()
		return
		





func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		player_in_range= true
		


func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		player_in_range= false


func _on_cleanup_timer_timeout() -> void:
	queue_free()


func _on_attack_cool_down_timer_timeout() -> void:
	
	can_attack= true
