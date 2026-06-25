extends Node

signal vida_celeiro_mudou(nova_vida: int)
signal vida_player_mudou(nova_vida: int)
signal rodada_mudou(nova_rodada: int)
signal dinheiro_mudou(novo_dinheiro: int)
signal novo_erro(erro: String)
signal player_morreu()
signal inventario_mudou()

var plantas: Array[PackedScene] = []
var plantas_desbloqueadas: Array[bool] = []

@export var capacidade_max: int = 10
@export var slots_max: int = 2
@export var vida_celeiro_max: int = 100

# cada slot: {"planta_idx": int, "semillas": int} ou null se vazio
var inventario: Array = []

@export var vida_celeiro: int = 100
@export var vida_player: int = 3
@export var rodada_atual: int = 1
@export var dinheiro_atual: int = 1000

@export var penalidade_morte_base: int = 50
@export var penalidade_morte_incremento: int = 25

@export var preco_desbloquear_planta: int = 500
@export var preco_slot_extra: int = 500
@export var preco_ampliar_capacidade: int = 500
@export var preco_curar_celeiro: int = 200
@export var preco_ampliar_vida_max: int = 500

var mortes_player: int = 0

func _ready() -> void:
	inventario.resize(slots_max)
	inventario.fill(null)
	adicionar_sementes(0, 5)
	adicionar_sementes(1, 5)

func inicializar_plantas() -> void:
	plantas_desbloqueadas.clear()
	for i in plantas.size():
		plantas_desbloqueadas.append(i < 2)

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

func get_preco_semente(planta_idx: int) -> int:
	var inst = plantas[planta_idx].instantiate()
	var preco = inst.stats.preco
	inst.free()
	return preco

func comprar_semente(planta_idx: int) -> bool:
	if not plantas_desbloqueadas[planta_idx]:
		novo_erro.emit("Planta não desbloqueada!")
		return false
	var preco = get_preco_semente(planta_idx)
	if dinheiro_atual < preco:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	if semillas_total() >= capacidade_max:
		novo_erro.emit("Inventário cheio!")
		return false
	var slot_livre = false
	for slot in inventario:
		if slot == null or slot["planta_idx"] == planta_idx:
			slot_livre = true
			break
	if not slot_livre:
		novo_erro.emit("Sem slots disponíveis!")
		return false
	diminui_dinheiro(preco)
	adicionar_sementes(planta_idx, 1)
	return true

func desbloquear_planta(planta_idx: int) -> bool:
	if plantas_desbloqueadas[planta_idx]:
		novo_erro.emit("Planta já desbloqueada!")
		return false
	if dinheiro_atual < preco_desbloquear_planta:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	diminui_dinheiro(preco_desbloquear_planta)
	plantas_desbloqueadas[planta_idx] = true
	return true

func comprar_slot() -> bool:
	if dinheiro_atual < preco_slot_extra:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	diminui_dinheiro(preco_slot_extra)
	slots_max += 1
	inventario.resize(slots_max)
	inventario[slots_max - 1] = null
	inventario_mudou.emit()
	return true

func ampliar_capacidade() -> bool:
	if dinheiro_atual < preco_ampliar_capacidade:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	diminui_dinheiro(preco_ampliar_capacidade)
	capacidade_max += 5
	inventario_mudou.emit()
	return true

func curar_celeiro() -> bool:
	if dinheiro_atual < preco_curar_celeiro:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	if vida_celeiro >= vida_celeiro_max:
		novo_erro.emit("Celeiro com vida cheia!")
		return false
	diminui_dinheiro(preco_curar_celeiro)
	vida_celeiro = min(vida_celeiro + 25, vida_celeiro_max)
	vida_celeiro_mudou.emit(vida_celeiro)
	return true

func ampliar_vida_max_celeiro() -> bool:
	if dinheiro_atual < preco_ampliar_vida_max:
		novo_erro.emit("Dinheiro insuficiente!")
		return false
	diminui_dinheiro(preco_ampliar_vida_max)
	vida_celeiro_max += 25
	return true

func enviar_mensagem_erro(mensagem: String) -> void:
	novo_erro.emit(mensagem)
  
func avancar_rodada():
	rodada_atual += 1
	rodada_mudou.emit(rodada_atual)

func reset_game():
	vida_player = 3
	vida_celeiro = vida_celeiro_max
	dinheiro_atual = 400
	rodada_atual = 1
	mortes_player = 0
	inventario.fill(null)
	vida_player_mudou.emit(vida_player)
	dinheiro_mudou.emit(dinheiro_atual)
	vida_celeiro_mudou.emit(vida_celeiro)
	rodada_mudou.emit(rodada_atual)
	inventario_mudou.emit()
