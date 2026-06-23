extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var invulneravel: bool = false
@export var tempo_max_invuneravel: float
var tempo_atual_invuneravel: float = 0

@export var animation: AnimatedSprite2D
@export var tower_scenes: Array[PackedScene] = []
@export var respawn_point: Node2D
@export var tempo_respawn: float = 5.0
@export var tempo_respawn_incremento: float = 2.0

var planta_selecionada: int = 0
var morto: bool = false

func _ready() -> void:
	GameController.player_morreu.connect(_on_player_morreu)

func _unhandled_input(event: InputEvent) -> void:
	var anterior = planta_selecionada

	if event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_1: planta_selecionada = 0
			KEY_2: planta_selecionada = 1
			KEY_3: planta_selecionada = 2
			KEY_4: planta_selecionada = 3

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			planta_selecionada = (planta_selecionada - 1 + tower_scenes.size()) % tower_scenes.size()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			planta_selecionada = (planta_selecionada + 1) % tower_scenes.size()

	if planta_selecionada != anterior:
		print("Planta selecionada: ", planta_selecionada + 1)

func _physics_process(delta: float) -> void:
	if morto:
		return

	if invulneravel:
		tempo_atual_invuneravel += delta
		
		if tempo_atual_invuneravel >= tempo_max_invuneravel:
			invulneravel = false
			tempo_atual_invuneravel = 0.0
			animation.modulate = Color(1, 1, 1, 1)
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED

	if direction != Vector2.ZERO:
		
		if abs(direction.x) >= abs(direction.y):
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
	if tower_scenes == null:
		return
		
	var tilemap = get_tree().get_first_node_in_group("mapa")
	if tilemap == null:
		return
		
	# 1. Posição Alvo
	var posicao_interna = tilemap.to_local(global_position)
	var coord_mapa = tilemap.local_to_map(posicao_interna)
	var posicao_alvo_global = tilemap.to_global(tilemap.map_to_local(coord_mapa))
	
	# 2. Verifica se já existe uma torre
	for torre in get_tree().get_nodes_in_group("torres"):
		if torre.global_position.distance_to(posicao_alvo_global) < 1.0:
			GameController.novo_erro.emit("Local Ocupado!")
			return

	# 3. Verifica permissão do terreno
	var dados_do_chao = tilemap.get_cell_tile_data(coord_mapa)
	if dados_do_chao == null or not dados_do_chao.get_custom_data("pode_construir"):
		GameController.novo_erro.emit("Terreno Inválido!")
		return

	# 4. Verifica economia e constrói
	var new_tower = tower_scenes[0].instantiate()
	
	if GameController.dinheiro_atual >= new_tower.stats.preco:
		get_parent().add_child(new_tower)
		new_tower.global_position = posicao_alvo_global
		new_tower.add_to_group("torres")
		GameController.diminui_dinheiro(new_tower.stats.preco)
	else:
		new_tower.free()
		GameController.novo_erro.emit("Dinheiro Insuficiente!")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not invulneravel:
		animation.modulate = Color(1, 0, 0, 0.7)
		animation.play("damage")
		GameController.damage_player(1)
		invulneravel = true
		tempo_atual_invuneravel = 0

func _on_player_morreu() -> void:
	morto = true
	visible = false
	$CollisionShape2D2.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	var tempo = tempo_respawn + (GameController.mortes_player - 1) * tempo_respawn_incremento
	await get_tree().create_timer(tempo).timeout

	if respawn_point:
		global_position = respawn_point.global_position

	visible = true
	$CollisionShape2D2.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)

	invulneravel = true
	tempo_atual_invuneravel = 0
	morto = false
