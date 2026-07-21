extends Node
class_name Action

var _action_name
var _call_func
var _action_type

func activate()->void:
	_call_func.call(_action_name)
	_on_action.call()
func _init(action_name,call_func,,action_type="attack")->void:
	_action_name= action_name
	_call_func = call_func
	_action_type = action_type
func on_action()->void:
	
