extends Area2D

var target: Node2D
var speed: float = 400.0

func set_target(alvo_recebido: Node2D) -> void:
	target = alvo_recebido

func _process(delta: float) -> void:
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		look_at(target.global_position)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == target:
		if body.has_method("take_damage"):
			body.take_damage(1)
		else:
			body.queue_free()
			
		queue_free()
