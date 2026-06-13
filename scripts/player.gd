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
	var posicao_player = self.position
	var posicao_torre_x: int = int(posicao_player.x/16)
	var posicao_torre_y: int = int(posicao_player.y/16)
	
	print("Posição Player: ", posicao_player)
	print("Posição Torre Relativa X: ", posicao_torre_x)
	print("Posição Torre Relativa Y: ", posicao_torre_y)
	if tower_scene != null:
		var new_tower = tower_scene.instantiate()
		if GameController.dinheiro_atual >= new_tower.stats.preco:
			get_parent().add_child(new_tower)
			new_tower.global_position.x = (posicao_torre_x+1) * 16 - 8
			new_tower.global_position.y = (posicao_torre_y+1) * 16 - 8
			print("Posição Torre Reak X: ", new_tower.global_position.x)
			print("Posição Torre Real Y: ", new_tower.global_position.y)
			GameController.diminui_dinheiro(new_tower.stats.preco)
		else:
			new_tower.free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not invulneravel:
		animation.modulate = Color(1, 0, 0, 0.7)
		animation.play("damage")
		GameController.damage_player(1)
		invulneravel = true
		tempo_atual_invuneravel = 0
