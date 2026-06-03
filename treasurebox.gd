extends Node2D

var is_open=false
var is_interactable=true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func open()->void:
	if is_interactable:
		print(123)
		is_open = true
		
		$AnimatedSprite2D.play("open")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_interactable = !is_open


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation=="open":
		$Timer.start()


func _on_timer_timeout() -> void:
	$AnimatedSprite2D.play("opened")
