extends Attack_Component


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _condition(area)->bool :
	return area.name =="HitBox" and area.get_parent().is_in_group("enemy")
