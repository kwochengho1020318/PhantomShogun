extends Attack_Component


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass
func area_facing(direction)->void:
	pass
func area_valid(v)->void:
	$AttackArea/CollisionArea.disabled=1
	
func get_boundary()->float:
	return abs(capsule.position.x+facing*(shape.radius))
func _on_detect_area_body_entered(body: Node2D) -> void:
	pass
		


func _on_detect_area_body_exited(body: Node2D) -> void:
	pass
func get_player_in_range()->bool:
	return true
