extends Area2D

var target: Node2D
var speed: float = 400.0
var dano: int = 1

@onready var animacao_bala = $AnimatedSprite2D 

func setup(alvo: Node2D, _dano: int, _speed: float, _anim_nome: String) -> void:
	target = alvo
	dano = _dano
	speed = _speed
	
	if _anim_nome != "" and animacao_bala != null:
		animacao_bala.play(_anim_nome)

func _process(delta: float) -> void:
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		look_at(target.global_position)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == target:
		if body.has_method("take_damage"):
			body.take_damage(dano)
		else:
			body.queue_free()
		queue_free()
