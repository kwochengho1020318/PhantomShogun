extends Attack_Component


# Called when the node enters the scene tree for the first time.
var current_action
func area_facing(direction)->void:
	facing= direction
	$SlashAttack.area_facing(direction)
func area_valid(v)->void:
	for child in get_children():
		if child is Attack_Component:
			child.area_valid(v)
func switch_action(action_name)->void:
	current_action= action_name
func get_player_in_range()->bool:
	return $SlashAttack.get_player_in_range()
