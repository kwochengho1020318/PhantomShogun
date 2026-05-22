extends Node2D
class_name Attack_Component

func area_facing(direction)->void:
	if !$AttackArea/CollisionArea:
		print(get_node("AttackArea/CollisionArea"))
		return
	$AttackArea/CollisionArea.position.x = abs($AttackArea/CollisionArea.position.x)
	$DetectArea/CollisionArea.position.x = abs($DetectArea/CollisionArea.position.x)
func area_valid(v)->void:
	if !$AttackArea/CollisionArea:
		print($AttackArea/CollisionArea)
		return
	$AttackArea/CollisionArea.disabled=v
