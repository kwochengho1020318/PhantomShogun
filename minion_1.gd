
extends CharacterBase
class_name enemy
@export var patrol_distance := 100.0
@export var SPEED :=100
@export var IDLE_SPEED:=50
@export var initial_patrol = PATROL_STATE.PATROL

enum  PATROL_STATE{
	PATROL,
	IDLE
}

var current_speed= IDLE_SPEED
var start_x
var current_action

var waiting=false
var next_direction=Vector2(0,0)

var animation_playing



var player_in_vision=false
var player=null
var player_direction

var last_anime=""

var can_attack= true


func _ready() -> void:

	start_x = global_position.x
	current_speed= IDLE_SPEED
	direction=Vector2(1,0)
func _process(_delta: float) -> void:
	# manage the visual state and animate update
	_manage_state()
	_manage_animate()
func _physics_process(delta: float) -> void:
	
	if not is_on_floor() and (!$FlyComponent ):
		velocity += get_gravity() * delta
		
	if !dead:	
		_character_action(delta)
	else:
		velocity.x=0
	
	move_and_slide()

func _character_action(_delta)->void:
	
	_manage_state()
	if current_action:
		current_action.activate()
	strat_by_mode()
	_handle_direction()
	_moving_action()
func _dead_action()->void:
	velocity= Vector2(0,0)
	collision_mask = 1 
	set_collision_layer_value(3, false)
	$AttackComponent.disable()
	if $CollisionDamageComponent:
		$CollisionDamageComponent.disable()
	if $FlyComponent:
		$FlyComponent.disable()
	get_tree().call_group("live_group", "set_disabled", true)
func _handle_direction()->void:
	if locomotion_state==Locomotion.damaged:
		return
	if !mode==Mode.ACTIVATED:
		
		if direction.x!=0:
			facing_direction= direction.x
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
		return
	
	if attack_phase!=Attack_Phase.NORMAL:
		velocity.x=0 
		return
	if direction:
		velocity.x = direction.x * (current_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
func idle_mode()->void:
	if initial_patrol==PATROL_STATE.PATROL:
		current_speed=IDLE_SPEED
		if waiting:
			direction.x=0
			return
		if global_position.x>start_x+patrol_distance and facing_direction==1:
			wait_at_edge(-1)
		if  global_position.x<start_x-patrol_distance  and facing_direction==-1:
			wait_at_edge(1)
	else:
		direction.x=0
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
		
	
func wait_at_edge(new_direction):
	waiting=true
	next_direction.x=new_direction
	$Timers/EdgeWaitTimer.start()
func _on_edge_wait_timer_timeout() -> void:
	waiting=false
	
	direction.x=next_direction.x
	###防止timeout後又因為滿足條件又進入新的cycle
	global_position.x += direction.x * 2


func attack_action():
	$AttackComponent.area_valid(attack_phase==Attack_Phase.ATTACKING)
		


func _manage_state()->void:
	if HP<=0:
		dead=true
	if can_see_player():
		mode=Mode.ACTIVATED
	else:
		mode= Mode.IDLE
	if velocity.length()==0:
		locomotion_state=Locomotion.IDLE
	else:
		
		locomotion_state=Locomotion.RUN
	
	
		
func strat_by_mode()->void:
	if state==State.DAMAGED or dead:
		return
	if mode==Mode.IDLE:
		idle_mode()
	elif mode==Mode.ACTIVATED:
		activated_mode()
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
	direction=next_direction


		


func _on_animation_animation_finished() -> void:
	
	if attack_phase==Attack_Phase.PRE_ATTACK:
		$AttackComponent.area_valid(true)

		attack_phase=Attack_Phase.ATTACKING
		return
	if attack_phase==Attack_Phase.ATTACKING:
		$AttackComponent.area_valid(false)
		attack_phase=Attack_Phase.NORMAL
		return
	
		



func _on_hit(damage,damage_velocity,agility_damage)->void:
	if dead:
		return

	HP-=damage
	agility-=agility_damage
	$Timers/AgilityReoveryTimer.start()
	
	state=State.DAMAGED
	break_level = min(1,round((max_agility-agility)/max_agility)*3)+1
	if break_level>=2:
		agility = max_agility
	velocity= damage_velocity*(2+break_level*2)/10
	var from = -sign(damage_velocity.x)
	next_direction = Vector2(from,0)
	if HP<=0:
		dead=true
		_dead_action()
		$Timers/CleanupTimer.start()
	attack_phase= Attack_Phase.NORMAL
	damaged_count+=1
	$Timers/DamageRecoveryTimer.start(break_level*2/10)




func _on_cleanup_timer_timeout() -> void:
	queue_free()


func _on_attack_cool_down_timer_timeout() -> void:
	can_attack= true
	


func _on_agility_reovery_timer_timeout() -> void:
	agility= max_agility
