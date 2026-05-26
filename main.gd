extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var enemies_per_wave: int = 20
@export var enemy_scenes: Array[PackedScene] = []

@onready var all_paths: Array = [$PathA1, $PathA2, $PathB1, $PathB2, $PathC1, $PathC2, $PathD1, $PathD2]

var active_paths: Array = []
var timer: float = 0.0
var spawned: int = 0

func _ready() -> void:
	active_paths.append(all_paths[0])
	active_paths.append(all_paths[1])

func _process(delta: float):
	if spawned >= enemies_per_wave:
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		_spawn_enemy()

func _spawn_enemy():
	# elige una entrada al azar
	var path: Path2D = all_paths.pick_random()

	# crea el PathFollow2D y lo agrega al camino
	var follow = PathFollow2D.new()
	follow.rotates = false   # para que el sprite no rote con el camino
	path.add_child(follow)

	# instancia el enemigo y lo pone adentro del PathFollow2D
	var enemy = enemy_scene.instantiate()
	follow.add_child(enemy)
	follow.progress = 0.0

	spawned += 1
