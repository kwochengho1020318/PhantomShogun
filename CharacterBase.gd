extends CharacterBody2D

class_name CharacterBase

enum Locomotion{
	RUN,
	IDLE,
	damaged,
	JUMP
}
enum State{
	DAMAGED,
	NORMAL,
	DEAD
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

@export var damaged_velocity_scale=10
var damaged_velocity=0
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
