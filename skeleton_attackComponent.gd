extends Attack_Component


# Called when the node enters the scene tree for the first time.

func area_facing(direction)->void:
	facing= direction
	$SlashAttack.area_facing(direction)
func area_valid(v)->void:
	
	$SlashAttack.area_valid(v)
func get_player_in_range()->bool:
	return $SlashAttack.get_player_in_range()
