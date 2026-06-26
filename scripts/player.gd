extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var invulneravel: bool = false
@export var tempo_max_invuneravel: float
var tempo_atual_invuneravel: float = 0

@export var animation: AnimatedSprite2D
@export var plantas: Array[PackedScene] = []
@export var respawn_point: Node2D
@export var tempo_respawn: float = 5.0
@export var tempo_respawn_incremento: float = 2.0

var planta_selecionada: int = 0
var morto: bool = false

func _ready() -> void:
	GameController.plantas = plantas
	GameController.inicializar_plantas()
	GameController.player_morreu.connect(_on_player_morreu)

func _unhandled_input(event: InputEvent) -> void:
	var anterior = planta_selecionada

	if event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_1: planta_selecionada = 0
			KEY_2: planta_selecionada = 1
			KEY_3: planta_selecionada = 2
			KEY_4: planta_selecionada = 3
			KEY_5: planta_selecionada = 4
			KEY_6: planta_selecionada = 5

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			planta_selecionada = (planta_selecionada - 1 + GameController.slots_max) % GameController.slots_max
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			planta_selecionada = (planta_selecionada + 1) % GameController.slots_max

	if planta_selecionada != anterior:
		GameController.slot_mudou.emit(planta_selecionada)

func _physics_process(delta: float) -> void:
	if morto or GameController.tienda_abierta:
		velocity = Vector2.ZERO
		move_and_slide()
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

	if OS.is_debug_build() and Input.is_key_pressed(KEY_M):
		GameController.aumento_dinheiro(99999)

func place_tower() -> void:
	if not GameController.pode_plantar(planta_selecionada):
		GameController.novo_erro.emit("Sem sementes!")
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

	var slot = GameController.inventario[planta_selecionada]
	var tower_scene: PackedScene = GameController.plantas[slot["planta_idx"]]
	var new_tower = tower_scene.instantiate()

	# 4. Constrói e desconta semente
	get_parent().add_child(new_tower)
	new_tower.global_position = posicao_alvo_global
	new_tower.add_to_group("torres")
	GameController.usar_semente(planta_selecionada)

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
