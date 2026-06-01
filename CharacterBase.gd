extends CharacterBody2D

class_name CharacterBase

enum Locomotion{
	RUN,
	IDLE,
	damaged,
	JUMP,
	CLIMB
}
enum State{
	DAMAGED,
	NORMAL,
}
enum Mode{
	IDLE,
	ACTIVATED
}
enum Attack_Phase{
	PRE_ATTACK,
	ATTACKING,
	NORMAL
}
enum PARRY_STATE{
	NORMAL,
	PARRYING,
	PARRY_SUCCESS
}
var mode = Mode.IDLE
var locomotion_state= Locomotion.IDLE
var state = State.NORMAL
var attack_phase= Attack_Phase.NORMAL
var parry_state = PARRY_STATE.NORMAL
var facing_direction=1
var is_on_ladder=0



var dead =false

@export var damaged_velocity_scale=10
@export var HP = 5
var damaged_velocity
var damaged_count=0

func _character_action(delta)->void:
	pass
func _moving_action()->void:
	pass
func _handle_direction()->void:
	pass
func _manage_state()->void:
	pass
func _manage_animate()->void:
	pass
func _on_hit(damage,damage_velocity)->void:
	pass
