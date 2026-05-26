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
	if direction:
		animation.play("walk")
	else:
		animation.play("idle")
	if velocity.x < 0:
		animation.flip_h = true
	if velocity.x > 0:
		animation.flip_h = false

	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		place_tower()
	
func place_tower() -> void:
	if tower_scene != null:
		var new_tower = tower_scene.instantiate()
		get_parent().add_child(new_tower)
		new_tower.global_position = global_position
