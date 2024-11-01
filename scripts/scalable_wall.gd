extends Area2D

@onready var timer: Timer = $Timer




func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	body.get_script()
