extends CharacterBody2D

@onready var path_follow = get_parent()

@export var speed: float = 100.0
@export var min_walk_time: float = 1.0
@export var max_walk_time: float = 8.0
@export var min_pause_time: float = 1.0
@export var max_pause_time: float = 5.0

var tiempo_restante: float = 0.0
var pausa: bool = false
var direccion: Vector2 = Vector2.ZERO
var posicion_anterior: Vector2

func _ready():
	posicion_anterior = path_follow.global_position
	# empieza caminando con un tiempo aleatorio
	tiempo_restante = randf_range(min_walk_time, max_walk_time)

func _physics_process(delta: float):
	tiempo_restante -= delta

	if tiempo_restante <= 0.0:
		pausa = !pausa
		if pausa:
			tiempo_restante = randf_range(min_pause_time, max_pause_time)
		else:
			tiempo_restante = randf_range(min_walk_time, max_walk_time)

	if not pausa:
		path_follow.progress += speed * delta

	var pos_actual = path_follow.global_position
	if not pausa:
		direccion = (pos_actual - posicion_anterior).normalized()
	else:
		direccion = Vector2.ZERO
	posicion_anterior = pos_actual

	if path_follow.progress_ratio >= 1.0:
		queue_free()  # llegó al celeiro — aquí después le restás vida

func _process(_delta: float):
	actualizar_animacion()

func actualizar_animacion():
	var anim = "idle"
	if direccion.x <= -0.5:
		anim = "move_left"
	elif direccion.x >= 0.5:
		anim = "move_right"
	elif direccion.y >= 0.5:
		anim = "move_down"
	elif direccion.y <= -0.5:
		anim = "move_up"
	$AnimatedSprite2D.play(anim)
