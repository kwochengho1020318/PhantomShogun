extends CharacterBase

var speed=300
var jump_speed=350
@export var valid_parry_time_msec = 300


##input
var direction
var jump_action
var attack_action
var parry_action
var parry_start
var parry_start_time

var can_attack=true
var can_jump = true
var attack_count=0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_input()
	locomotion_state=Locomotion.IDLE
	
	state=State.NORMAL
	






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_input()
	$AttackComponent.area_valid(attack_phase==Attack_Phase.ATTACKING)
	_manage_state()
	_manage_animate()
func get_input():
	direction= Input.get_axis("move_left","move_right")
	
	jump_action = Input.is_action_just_pressed("jump")
	if state !=State.DAMAGED:
		attack_action=Input.is_action_just_pressed("attack")
	parry_action = Input.is_action_pressed("parry")
	parry_start = Input.is_action_just_pressed("parry")
func _moving_action()->void:
	if state==State.DAMAGED:
		velocity=damaged_velocity
		return
	
	# update velocity ,skip if attacking 
	if attack_phase==Attack_Phase.ATTACKING and locomotion_state!=Locomotion.JUMP:
		velocity.x=0
		return
	if parry_state== PARRY_STATE.PARRYING and locomotion_state!=Locomotion.JUMP:
		velocity.x=0
		return
	#jump,updating jump state
	if is_on_floor() and jump_action and can_jump:
		can_jump= false
		locomotion_state=Locomotion.JUMP
		velocity.y=-jump_speed
	velocity.x=direction*speed

func _physics_process(delta: float) -> void:
	
	_character_action(delta)
	if is_on_floor() and !can_jump:
		$Timers/JumpCooldownTimer.start()	
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
func _character_action(_delta)->void:
	get_input()
	_moving_action()
	_handle_direction()

func _handle_direction()->void:
	if direction!=0 and state==State.NORMAL and attack_phase== Attack_Phase.NORMAL:
		$Animation.flip_h = direction<0
	if $Animation.flip_h==true:
		facing_direction=-1
	else:
		facing_direction=1
	$AttackComponent.area_facing(facing_direction)
func _manage_state()->void:
	var v=velocity.length()
	
	
	
	if locomotion_state==Locomotion.JUMP:
		if is_on_floor():
			locomotion_state=Locomotion.IDLE
			
			
	if  attack_action and  can_attack:
		attack_phase=Attack_Phase.ATTACKING
		attack_count+=1
		return
		
	# manage parry state
	manage_parry_state()
		
		
	if(v==0):
		locomotion_state=Locomotion.IDLE
		return
	if is_on_floor() and velocity.x!=0:
		locomotion_state=Locomotion.RUN
func manage_parry_state()->void:
	if attack_phase!=Attack_Phase.NORMAL:
		parry_state = PARRY_STATE.NORMAL
		return
	if parry_state == PARRY_STATE.PARRY_SUCCESS:
		return
	if parry_start:
		parry_start_time = Time.get_ticks_msec() 
	if parry_action:
		parry_state = PARRY_STATE.PARRYING
	else:
		parry_state = PARRY_STATE.NORMAL
func _manage_animate()->void:
	if state==State.DAMAGED:
		if $Animation.animation !="damaged":
				$Animation.play("damaged")
		return
	if attack_phase==Attack_Phase.ATTACKING:
		if !can_attack: return
		var temp = attack_count%3+1
		if $Animation.animation!="attack_%d" %[temp]:
				$Animation.play("attack_%d" %[temp])
		
		return
	if parry_state == PARRY_STATE.PARRY_SUCCESS:
		if !$Animation.animation.begins_with("parry_success") :
			var randnum = randi_range(1,2)
			$Animation.play("parry_success%d" %[randnum] )
		return
	if parry_state==PARRY_STATE.PARRYING:
		if $Animation.animation!="parrying" :
				$Animation.play("parrying" )
		return
	match locomotion_state:
		Locomotion.IDLE:
			if $Animation.animation !="idle":
				$Animation.play("idle")
		Locomotion.RUN:
			if $Animation.animation != "walking":
				$Animation.play("walking")
		Locomotion.JUMP:
			if $Animation.animation != "jump":
				$Animation.play("jump")
			


func _on_animation_animation_finished() -> void:
	var regex = RegEx.new()
	regex.compile("^attack_\\d+$")
	if regex.search($Animation.animation):
		
		attack_phase=Attack_Phase.NORMAL
		can_attack=true
	if $Animation.animation.begins_with("parry_success"):
		Global.is_player_parrying = false
		
		parry_state= PARRY_STATE.NORMAL
		


func _on_attack_timer_timeout() -> void:
	attack_count=0



		


func _on_damage_recovery_timer_timeout() -> void:
	state=State.NORMAL
	Global.is_player_damaged = false
	
func _on_hit(damage,damage_velocity)->void:
	if parry_state==PARRY_STATE.PARRYING and Time.get_ticks_msec()-parry_start_time<=valid_parry_time_msec:
		parry_state= PARRY_STATE.PARRY_SUCCESS
		Global.is_player_parrying = true
	else:
		print(damage)
		damaged_velocity= damage_velocity
		state=State.DAMAGED
		Global.is_player_damaged = true
		attack_phase= Attack_Phase.NORMAL

		$Timers/DamageRecoveryTimer.start()

func _on_jump_cooldown_timer_timeout() -> void:
	can_jump = true

	
