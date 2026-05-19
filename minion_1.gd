
extends CharacterBase
class_name enemy
@export var patrol_distance := 100.0
@export var SPEED :=100
@export var IDLE_SPEED=50
@export var HP=5


var current_speed
var start_x

var direction
var waiting=false
var next_direction=0

var damaged_velocity_scale=20
var damaged_velocity=0



var player_in_vision=false
var player=null
var player_in_range = false

var last_anime=""



func _ready() -> void:
	start_x = global_position.x
	HP=5
	current_speed= IDLE_SPEED
	direction=1
func _process(delta: float) -> void:
	
	manage_state()
	action_by_mode()
	manage_animate()
func _physics_process(delta: float) -> void:
	if state!=State.DEAD:
		if not is_on_floor():
			velocity += get_gravity() * delta
	if state==State.DEAD:
		return
	live_action(delta)
	
	move_and_slide()

func live_action(delta)->void:
	
	if state==State.DEAD:
		velocity.x=0
		return
	if state==State.DAMAGED:
		
		velocity.x=damaged_velocity
		return
	if direction==1:
		$Animation.flip_h=false
		$AttackArea/CollisionArea.position.x = abs($AttackArea/CollisionArea.position.x)
		$DetectArea/CollisionArea.position.x = abs($DetectArea/CollisionArea.position.x)
	if direction==-1:
		$AttackArea/CollisionArea.position.x = -abs($AttackArea/CollisionArea.position.x)
		$DetectArea/CollisionArea.position.x = -abs($DetectArea/CollisionArea.position.x)
		$Animation.flip_h= true
	attack_action()
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
	if global_position.x>start_x+patrol_distance:
		wait_at_edge(-1)
	if  global_position.x<start_x-patrol_distance:
		wait_at_edge(1)
func activated_mode()->void:
	if player_in_range and attack_phase==Attack_Phase.NORMAL :
		attack_phase= Attack_Phase.PRE_ATTACK
		return
	current_speed=SPEED
	if player==null:
		print("no player!!")
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
	if attack_phase==Attack_Phase.ATTACKING:
		$AttackArea/CollisionArea.disabled=false
	else:
		$AttackArea/CollisionArea.disabled=true
		


func manage_state()->void:
	if HP<=0:
		$CollisionShape2D.disabled=true
		state=State.DEAD
	if player:
		if can_see_player():
			mode=Mode.ACTIVATED
	if velocity.x==0:
		locomotion_state=Locomotion.IDLE
	else:
		locomotion_state=Locomotion.RUN
	
	
		
func action_by_mode()->void:
	if state==State.DAMAGED or state==State.DEAD:
		return
	if mode==Mode.IDLE:
		idle_mode()
	elif mode==Mode.ACTIVATED:
		activated_mode()
func manage_animate()->void:
	if state==State.DEAD:
		if $Animation.name !=("dead"):
			$Animation.play("dead")
		return
	if state==State.DAMAGED:
		if $Animation.name!=("damaged"):
			$Animation.play("damaged")
		return
	if attack_phase==Attack_Phase.PRE_ATTACK:
		if $Animation.name!=("pre_attack_1"):
			$Animation.play("pre_attack_1")
		
		return
	if attack_phase==Attack_Phase.ATTACKING:
		if $Animation.name!=("attack_1"):
			$Animation.play("attack_1")
			
		return
	if locomotion_state==Locomotion.IDLE:
		if $Animation.name!=("idle"):
			$Animation.play("idle")
		return
	if locomotion_state==Locomotion.RUN:
		if $Animation.name!=("walk"):
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
	mode= Mode.IDLE


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
		state = State.DAMAGED
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
