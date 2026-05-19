extends CharacterBody2D

class_name CharacterBase

enum Locomotion{
	RUN,
	IDLE,
	damaged
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
var mode = Mode.IDLE
var locomotion_state= Locomotion.IDLE
var state = State.NORMAL
var attack_phase= Attack_Phase.NORMAL


func _physics_process(delta: float) -> void:
	# Add the gravity.
	

	move_and_slide()
