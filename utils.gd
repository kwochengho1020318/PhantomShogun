class_name Utils
extends Node

var is_player_damaged:bool = false
var is_player_parrying:bool =false

static func bool_to_sign(condition)->float:
	if condition:
		return 1
	else:
		return -1
func is_player_busy()->bool:
	return is_player_damaged or is_player_parrying
	
