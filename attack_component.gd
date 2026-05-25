extends Node2D
class_name Attack_Component


var player_in_range = false
var facing = 1
var shape
var capsule
func _ready() -> void:
	capsule = $AttackArea/CollisionArea
	shape=capsule.shape as CapsuleShape2D
func area_facing(direction)->void:
	facing= direction
	$AttackArea/CollisionArea.position.x = facing*abs($AttackArea/CollisionArea.position.x)
	$DetectArea/CollisionArea.position.x = facing*abs($AttackArea/CollisionArea.position.x)
func area_valid(v)->void:
	
	$AttackArea/CollisionArea.disabled=v
	
func get_boundary()->float:
	return abs(capsule.position.x+facing*(shape.radius))
func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		
		player_in_range= true
		


func _on_detect_area_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		player_in_range= false
func get_player_in_range()->bool:
	return player_in_range
