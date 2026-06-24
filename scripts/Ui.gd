extends CanvasLayer

@export var vida_celeiro_UI: Label
@export var vida_player_UI: Label
@export var rodada_atual_UI: Label
@export var dinheiro_atual_UI: Label
@export var mensagem_falha: Label

func _ready() -> void:
	GameController.vida_celeiro_mudou.connect(_atualizar_texto_celeiro)
	GameController.vida_player_mudou.connect(_atualizar_texto_player)
	GameController.rodada_mudou.connect(_atualizar_texto_rodada)
	GameController.dinheiro_mudou.connect(_atualizar_texto_dinheiro)
	GameController.novo_erro.connect(_atualizar_texto_erro)
	
	_atualizar_texto_celeiro(GameController.vida_celeiro)
	_atualizar_texto_player(GameController.vida_player)
	_atualizar_texto_rodada(GameController.rodada_atual)
	_atualizar_texto_dinheiro(GameController.dinheiro_atual)
	
	if mensagem_falha:
		mensagem_falha.visible = false

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

func _atualizar_texto_erro(erro: String) -> void:
	mensagem_falha.text = erro
	mensagem_falha.visible = true
	await  get_tree().create_timer(1.5).timeout
	mensagem_falha.visible = false
