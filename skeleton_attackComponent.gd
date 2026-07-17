extends Attack_Component


# Called when the node enters the scene tree for the first time.
var current_action
func area_facing(direction)->void:
	facing= direction
	$SlashAttack.area_facing(direction)
func area_valid(v)->void:
	if current_action=="slash1":
		$SlashAttack.area_valid(v)
	if current_action=="slash2":
		$Slash2Attack.area_valid(v)
func switch_action(action_name)->void:
	current_action= action_name
func get_player_in_range()->bool:
	if current_action=="slash1":
		return $SlashAttack.get_player_in_range()
	if current_action=="slash2":
		return $Slash2Attack.get_player_in_range()
	else:
		return false
