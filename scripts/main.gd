extends Node2D

@export var spawn_interval: float = 2.0
@export var tempo_entre_rodadas: float = 5.0
@export var enemy_medio: PackedScene
@export var enemy_leve: PackedScene
@export var enemy_pesado: PackedScene

@onready var entradas: Array = [$PathA1, $PathB1, $PathC1, $PathD1]

const RODADAS_DESBLOQUEIO = {2: 1, 5: 2, 8: 3}  # rodada: índice da entrada desbloqueada

# combinações possíveis para rondas temáticas (índices em enemy_medio/leve/pesado)
const TEMAS_RODADA = [
	[0],       # só médios
	[1],       # só leves
	[2],       # só pesados
	[0, 1],    # médios + leves
	[0, 2],    # médios + pesados
	[1, 2],    # leves + pesados
]

var timer: float = 0.0
var spawned: int = 0
var enemies_per_wave: int = 0
var entradas_ativas: Array = []
var pesos_ativos: Array = []
var enemies_ativos: Array = []
var pesos_enemy_ativos: Array = []
var aguardando_proxima_rodada: bool = false

func _ready() -> void:
	$Player.respawn_point = $RespawnPoint
	_iniciar_rodada()

func _process(delta: float):
	if aguardando_proxima_rodada:
		return

	if spawned >= enemies_per_wave:
		if get_tree().get_nodes_in_group("enemy").is_empty():
			aguardando_proxima_rodada = true
			await get_tree().create_timer(tempo_entre_rodadas).timeout
			GameController.avancar_rodada()
			_iniciar_rodada()
			aguardando_proxima_rodada = false
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		_spawn_enemy()

func _iniciar_rodada():
	timer = 0.0
	spawned = 0
	enemies_per_wave = _calcular_enemies_per_wave(GameController.rodada_atual)
	entradas_ativas = _entradas_desbloqueadas(GameController.rodada_atual)

	pesos_ativos = []
	for i in entradas_ativas.size():
		pesos_ativos.append(randi_range(1, 5))

	_definir_enemies_da_rodada(GameController.rodada_atual)

func _entradas_desbloqueadas(rodada: int) -> Array:
	var lista = [entradas[0]]
	for rodada_minima in RODADAS_DESBLOQUEIO:
		if rodada >= rodada_minima:
			lista.append(entradas[RODADAS_DESBLOQUEIO[rodada_minima]])
	return lista

func _calcular_enemies_per_wave(rodada: int) -> int:
	var qtd = 10 + (rodada - 1) * 2

	# rodada em que uma entrada nova é desbloqueada: reduz a quantidade
	if rodada in RODADAS_DESBLOQUEIO:
		qtd = int(qtd * 0.6)

	return qtd

func _definir_enemies_da_rodada(rodada: int):
	var enemies = [enemy_medio, enemy_leve, enemy_pesado]

	# rodada temática: a cada 4 rondas, 50% de chance de só ter certos tipos
	if rodada % 4 == 0 and randf() < 0.5:
		var tema: Array = TEMAS_RODADA.pick_random()
		enemies_ativos = []
		pesos_enemy_ativos = []
		for indice in tema:
			enemies_ativos.append(enemies[indice])
			pesos_enemy_ativos.append(1)
		return

	# pesos normais: médio é a base, leve e pesado escalam com a rodada
	enemies_ativos = enemies
	pesos_enemy_ativos = [
		5,
		min(1 + rodada / 3, 4),
		min(1 + rodada / 4, 4),
	]

func _spawn_enemy():
	var path: Path2D = _sorteio_ponderado(entradas_ativas, pesos_ativos)

	# crea el PathFollow2D y lo agrega al camino
	var follow = PathFollow2D.new()
	follow.rotates = false   # para que el sprite no rote con el camino
	path.add_child(follow)

	# instancia el enemigo segundo o tipo sorteado e o pone adentro do PathFollow2D
	var enemy_scene: PackedScene = _sorteio_ponderado(enemies_ativos, pesos_enemy_ativos)
	var enemy = enemy_scene.instantiate()
	follow.add_child(enemy)
	follow.progress = 0.0

	spawned += 1

func _sorteio_ponderado(opcoes: Array, pesos: Array):
	var total = 0
	for peso in pesos:
		total += peso

	var sorteio = randi_range(1, total)
	var acumulado = 0
	for i in opcoes.size():
		acumulado += pesos[i]
		if sorteio <= acumulado:
			return opcoes[i]

	return opcoes[-1]

func _on_zona_tienda_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Tienda.abrir()
