extends Node

signal vida_celeiro_mudou(nova_vida: int)
signal vida_player_mudou(nova_vida: int)
signal rodada_mudou(nova_rodada: int)
signal dinheiro_mudou(novo_dinheiro: int)

@export var vida_celeiro: int = 100
@export var vida_player: int = 3
@export var rodada_atual: int = 1
@export var dinheiro_atual: int = 0

func _ready() -> void:
	pass

func damage_player(qtd: int):
	vida_player -= qtd
	vida_player_mudou.emit(vida_player) 

func damage_celeiro(qtd: int):
	vida_celeiro -= qtd
	vida_celeiro_mudou.emit(vida_celeiro) 
	
	if vida_celeiro <= 0:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		
func aumento_dinheiro(qtd: int):
	dinheiro_atual += qtd
	dinheiro_mudou.emit(dinheiro_atual)
	
func diminui_dinheiro(qtd: int):
	print("perdeu " + str(qtd) + " de dinheiro")
	dinheiro_atual -= qtd
	dinheiro_mudou.emit(dinheiro_atual)

func reset_game():
	vida_celeiro = 100
	dinheiro_atual = 0
	dinheiro_mudou.emit(dinheiro_atual)
	vida_celeiro_mudou.emit(vida_celeiro)
