extends CanvasLayer

@export var vida_celeiro_UI: Label
@export var vida_player_UI: Label
@export var rodada_atual_UI: Label
@export var dinheiro_atual_UI: Label

func _ready() -> void:
	GameController.vida_celeiro_mudou.connect(_atualizar_texto_celeiro)
	GameController.vida_player_mudou.connect(_atualizar_texto_player)
	GameController.rodada_mudou.connect(_atualizar_texto_rodada)
	GameController.dinheiro_mudou.connect(_atualizar_texto_dinheiro)
	
	_atualizar_texto_celeiro(GameController.vida_celeiro)
	_atualizar_texto_player(GameController.vida_player)
	_atualizar_texto_rodada(GameController.rodada_atual)
	_atualizar_texto_dinheiro(GameController.dinheiro_atual)

func _atualizar_texto_celeiro(nova_vida: int) -> void:
	if vida_celeiro_UI:
		vida_celeiro_UI.text = "Vida Celeiro: " + str(nova_vida)

func _atualizar_texto_player(nova_vida: int) -> void:
	if vida_player_UI:
		vida_player_UI.text = "Vida Player: " + str(nova_vida)

func _atualizar_texto_rodada(nova_rodada: int) -> void:
	if rodada_atual_UI:
		rodada_atual_UI.text = str(nova_rodada)
		

func _atualizar_texto_dinheiro(novo_dinheiro: int) -> void:
	if dinheiro_atual_UI:
		dinheiro_atual_UI.text = str(novo_dinheiro) + "$" 
