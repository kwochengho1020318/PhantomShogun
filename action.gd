extends Node
class_name Action

var _action_name
var _call_func
func activate()->void:
	_call_func.call(_action_name)
func _init(action_name,call_func)->void:
	_action_name= action_name
	_call_func = call_func
