extends Node2D
class_name Attack_Component

func area_facing(direction)->void:
	
	$AttackArea/CollisionArea.position.x = abs($AttackArea/CollisionArea.position.x)
	$DetectArea/CollisionArea.position.x = abs($DetectArea/CollisionArea.position.x)
func area_valid(v)->void:
	
	$AttackArea/CollisionArea.disabled=v
