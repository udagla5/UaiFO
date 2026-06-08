extends Node2D

@export var stats: TowerStats
@export var bullet_scene: PackedScene
@export var seed_sprite: Sprite2D
@export var plant_node: Node2D

var enemies_in_range: Array = []

func _ready():
	var shape = $Area2D/CollisionShape2D.shape.duplicate()
	shape.radius = stats.alcance
	$Area2D/CollisionShape2D.shape = shape

	$Timer.wait_time = stats.cadencia
	$Timer.stop()
	_fase_germinacao()

func _fase_germinacao():
	if seed_sprite:
		seed_sprite.visible = true
		seed_sprite.scale = Vector2(0.5, 0.5)
		seed_sprite.modulate.a = 0.5
	if plant_node:
		plant_node.visible = false
	await get_tree().create_timer(stats.tempo_germinacao).timeout
	_fase_ativa()

func _fase_ativa():
	if seed_sprite:
		seed_sprite.visible = false
	if plant_node:
		plant_node.visible = true
	$Timer.start()
	await get_tree().create_timer(stats.tempo_vida).timeout
	queue_free()

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
		bala.setup(alvo, stats.dano_bala, stats.velocidade_bala)
