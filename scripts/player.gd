extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var invulneravel: bool = false
@export var tempo_max_invuneravel: float
var tempo_atual_invuneravel: float = 0

@export var animation: AnimatedSprite2D
@export var tower_scene: PackedScene

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
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
	if tower_scene == null:
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
	var new_tower = tower_scene.instantiate()
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
