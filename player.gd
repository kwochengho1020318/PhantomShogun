extends CharacterBody2D

var speed=300
var jump_speed=500
var locomotion_state
var combat_state
var state

##input
var walk_direction
var jump_action
var attack_action

var damaged_velocity_scale=50
var damaged_velocity=0

var can_attack=true
var attack_count=0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_input()
	locomotion_state=Locomotion.IDLE
	combat_state=Combat.NORMAL
	state=State.NORMAL

enum Locomotion {
	IDLE,
	RUN,
	JUMP
}

enum Combat {
	NORMAL,
	ATTACK
}

enum State {
	NORMAL,
	DAMAGED,
	DEAD
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	if combat_state==Combat.ATTACK:
		$AttackArea/CollisionShape2D.disabled=false
	else:
		$AttackArea/CollisionShape2D.disabled=true
	manage_state()
	manage_animate()
func get_input():
	walk_direction= Input.get_axis("move_left","move_right")
	jump_action = Input.is_action_just_pressed("jump")
	attack_action=Input.is_action_just_pressed("attack")
func moving_action()->void:
	var v_x = velocity.x
	if state==State.DAMAGED:
		velocity.x=damaged_velocity
		return
	if v_x!=0:
		$Animation.flip_h =v_x <= 0
	# update velocity ,skip if attacking 
	if combat_state==Combat.ATTACK and locomotion_state!=Locomotion.JUMP or state==State.DAMAGED:
		velocity.x=0
		return
	#jump,updating jump state
	if is_on_floor() and jump_action:
		locomotion_state=Locomotion.JUMP
		velocity.y=-jump_speed
	velocity.x=walk_direction*speed

func _physics_process(delta: float) -> void:
	get_input()
	if not is_on_floor():
		velocity.y += gravity * delta
	moving_action()
	
		
	move_and_slide()

	
func manage_state()->void:
	var v_y = velocity.y
	var v_x = velocity.x
	var v=velocity.length()
	
	if $Animation.flip_h==true:
		$AttackArea/CollisionShape2D.position.x = -abs($AttackArea/CollisionShape2D.position.x)
	else:
		$AttackArea/CollisionShape2D.position.x = abs($AttackArea/CollisionShape2D.position.x)
	if combat_state==Combat.ATTACK:
		return
	if locomotion_state==Locomotion.JUMP and is_on_floor():
		locomotion_state=Locomotion.IDLE
	if  attack_action and  can_attack:
		combat_state=Combat.ATTACK
		$Timers/AttackTimer.start()
		attack_count+=1
		return
	if(v==0):
		locomotion_state=Locomotion.IDLE
		return
	if is_on_floor() and velocity.x!=0:
		locomotion_state=Locomotion.RUN
	
func manage_animate()->void:
	if state==State.DAMAGED:
		if $Animation.animation !="damaged":
				$Animation.play("damaged")
		return
	if combat_state==Combat.ATTACK:
		if !can_attack: return
		var temp = attack_count%3+1
		if $Animation.animation!="attack_%d" %[temp]:
				$Animation.play("attack_%d" %[temp])
		
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
		locomotion_state=Locomotion.IDLE
		combat_state=Combat.NORMAL
		$Animation.play("idle")
		can_attack=true
		


func _on_attack_timer_timeout() -> void:
	attack_count=0


func _on_hit_box_area_entered(area: Area2D) -> void:
	
	if area.name=="AttackArea" and area.is_in_group("enemy_area"):
		if area.global_position.x>global_position.x:
			damaged_velocity=-damaged_velocity_scale
		else:
			damaged_velocity=damaged_velocity_scale
		state=State.DAMAGED
		print(damaged_velocity)
		$Timers/DamageRecoveryTimer.start()


func _on_damage_recovery_timer_timeout() -> void:
	state=State.NORMAL
