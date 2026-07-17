extends DamageComponentBase
class_name Attack_Component
signal hit

var player_in_range = false
var facing = 1
var shape
var capsule

func _ready() -> void:
	capsule = $AttackArea/CollisionArea
	shape=capsule.shape as CapsuleShape2D
	$AttackArea/CollisionArea.disabled=true

func area_facing(direction)->void:
	facing= direction
	$AttackArea/CollisionArea.position.x = facing*abs($AttackArea/CollisionArea.position.x)
	$DetectArea/CollisionArea.position.x = facing*abs($AttackArea/CollisionArea.position.x)
func area_valid(v)->void:
	
	$AttackArea/CollisionArea.disabled=!v
	
func get_boundary()->float:
	return abs(capsule.position.x+facing*(shape.radius))

		
func disable() ->void:
	queue_free()


func _condition(area)->bool:
	return area.name =="HitBox" and area.get_parent().name=="Player"

func get_player_in_range()->bool:
	return player_in_range

func _on_attack_area_area_entered(area: Area2D) -> void:
	_damage(area)


func _on_detect_area_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Player" and area.name =="HitBox":
		
		player_in_range= true


func _on_detect_area_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "Player"and area.name =="HitBox":
		player_in_range= false
