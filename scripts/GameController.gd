extends Node

signal vida_celeiro_mudou(nova_vida: int)
signal vida_player_mudou(nova_vida: int)
signal rodada_mudou(nova_rodada: int)
signal dinheiro_mudou(novo_dinheiro: int)
signal novo_erro(erro: String)
signal player_morreu()
signal inventario_mudou()

var plantas: Array[PackedScene] = []
@export var capacidade_max: int = 10
@export var slots_max: int = 2

# cada slot: {"planta_idx": int, "semillas": int} ou null se vazio
var inventario: Array = []

@export var vida_celeiro: int = 100
@export var vida_player: int = 3
@export var rodada_atual: int = 1
@export var dinheiro_atual: int = 1000 #test

@export var penalidade_morte_base: int = 50
@export var penalidade_morte_incremento: int = 25

var mortes_player: int = 0

func _ready() -> void:
	inventario.resize(slots_max)
	inventario.fill(null)
	adicionar_sementes(0, 5)
	adicionar_sementes(1, 5)

func semillas_total() -> int:
	var total = 0
	for slot in inventario:
		if slot != null:
			total += slot["semillas"]
	return total

func pode_plantar(slot_idx: int) -> bool:
	if slot_idx >= inventario.size():
		return false
	var slot = inventario[slot_idx]
	return slot != null and slot["semillas"] > 0

func usar_semente(slot_idx: int) -> void:
	var slot = inventario[slot_idx]
	slot["semillas"] -= 1
	if slot["semillas"] <= 0:
		inventario[slot_idx] = null
	inventario_mudou.emit()

func adicionar_sementes(planta_idx: int, qtd: int) -> bool:
	var espacio = capacidade_max - semillas_total()
	if espacio <= 0:
		return false
	var agregar = min(qtd, espacio)
	# busca slot existente para esta planta
	for i in inventario.size():
		if inventario[i] != null and inventario[i]["planta_idx"] == planta_idx:
			inventario[i]["semillas"] += agregar
			inventario_mudou.emit()
			return agregar == qtd
	# busca slot vacío
	for i in inventario.size():
		if inventario[i] == null:
			inventario[i] = {"planta_idx": planta_idx, "semillas": agregar}
			inventario_mudou.emit()
			return agregar == qtd
	return false

func damage_player(qtd: int):
	vida_player -= qtd
	vida_player_mudou.emit(vida_player)

	if vida_player <= 0:
		var penalidade = penalidade_morte_base + mortes_player * penalidade_morte_incremento
		mortes_player += 1
		diminui_dinheiro(penalidade)

		vida_player = 3
		vida_player_mudou.emit(vida_player)
		player_morreu.emit()


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
	dinheiro_atual = max(0, dinheiro_atual - qtd)
	dinheiro_mudou.emit(dinheiro_atual)

func enviar_mensagem_erro(mensagem: String) -> void:
	novo_erro.emit(mensagem)
  
func avancar_rodada():
	rodada_atual += 1
	rodada_mudou.emit(rodada_atual)

func reset_game():
	vida_player = 3
	vida_celeiro = 100
	dinheiro_atual = 400
	rodada_atual = 1
	mortes_player = 0
	inventario.fill(null)
	vida_player_mudou.emit(vida_player)
	dinheiro_mudou.emit(dinheiro_atual)
	vida_celeiro_mudou.emit(vida_celeiro)
	rodada_mudou.emit(rodada_atual)
	inventario_mudou.emit()
