extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var animation: AnimatedSprite2D
@export var tower_scene: PackedScene

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED

	# 2. ANIMAÇÃO: Decidimos qual lado mostrar baseando-se no eixo mais forte
	if direction != Vector2.ZERO:
		
		# Usamos >= para garantir que as diagonais perfeitas (teclado) não deem erro
		if abs(direction.x) >= abs(direction.y):
			# Movimento horizontal é mais forte ou igual (prioridade para os lados)
			if direction.x > 0:
				animation.play("walk_right")
			else:
				animation.play("walk_left")
		else:
			# Movimento vertical é mais forte
			if direction.y < 0:
				animation.play("walk_up")
			else:
				animation.play("walk_down")
	else:
		animation.play("idle")

	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		place_tower()

func place_tower() -> void:
	if tower_scene != null:
		var new_tower = tower_scene.instantiate()
		if GameController.dinheiro_atual >= new_tower.stats.preco:
			get_parent().add_child(new_tower)
			new_tower.global_position = global_position
			GameController.diminui_dinheiro(new_tower.stats.preco)
		else:
			new_tower.free()
