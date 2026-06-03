extends ladder


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_top_area_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		if body.direction.y==-1:
			exit(body)
