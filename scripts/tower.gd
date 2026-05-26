extends Node2D

@export var bullet_scene: PackedScene

var enemies_in_range: Array = []

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func _on_timer_timeout() -> void:
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemies_in_range.size() > 0:
		shoot(enemies_in_range[0])

func shoot(alvo: Node2D) -> void:
	if bullet_scene != null:
		var bala = bullet_scene.instantiate()
		get_parent().add_child(bala)
		bala.global_position = global_position
		bala.set_target(alvo)
