extends Node2D
class_name DamageComponentBase

@export var damage = 1
@export var knockback_velocity:float = 1
@export var agility_damage:=1
func _ready()->void:
	pass


func disable()->void:
	queue_free()
func _damage(area)->void:
	if _condition(area):
		area.get_parent()._on_hit(damage,knockback_velocity*(area.global_position-global_position),agility_damage)

func _condition(area):
	pass
