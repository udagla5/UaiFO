extends CanvasLayer

var _semillas_vbox: VBoxContainer
var _plantas_vbox: VBoxContainer
var _upgrades_vbox: VBoxContainer

func _ready() -> void:
	visible = false
	_construir_ui()
	GameController.inventario_mudou.connect(_actualizar)
	GameController.dinheiro_mudou.connect(_actualizar.unbind(1))

func abrir() -> void:
	GameController.tienda_abierta = true
	visible = true
	_actualizar()

func fechar() -> void:
	GameController.tienda_abierta = false
	visible = false

func _construir_ui() -> void:
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(420, 520)
	panel.position = Vector2(-210, -260)
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	panel.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "TIENDA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(tabs)

	# --- Tab Semillas ---
	var scroll_sem = ScrollContainer.new()
	scroll_sem.name = "Sementes"
	scroll_sem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll_sem)
	_semillas_vbox = VBoxContainer.new()
	scroll_sem.add_child(_semillas_vbox)

	# --- Tab Plantas ---
	var scroll_pl = ScrollContainer.new()
	scroll_pl.name = "Plantas"
	scroll_pl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll_pl)
	_plantas_vbox = VBoxContainer.new()
	scroll_pl.add_child(_plantas_vbox)

	# --- Tab Upgrades ---
	var scroll_up = ScrollContainer.new()
	scroll_up.name = "Upgrades"
	scroll_up.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll_up)
	_upgrades_vbox = VBoxContainer.new()
	scroll_up.add_child(_upgrades_vbox)

	# --- Botón cerrar ---
	var btn_fechar = Button.new()
	btn_fechar.text = "Fechar"
	btn_fechar.pressed.connect(fechar)
	vbox.add_child(btn_fechar)

func _actualizar() -> void:
	if not visible:
		return
	_rellenar_semillas()
	_rellenar_plantas()
	_rellenar_upgrades()

func _rellenar_semillas() -> void:
	for child in _semillas_vbox.get_children():
		child.queue_free()
	for i in GameController.plantas.size():
		if not GameController.plantas_desbloqueadas[i]:
			continue
		var preco = GameController.get_preco_semente(i)
		var slot_info = ""
		"""
		for slot in GameController.inventario:
			if slot != null and slot["planta_idx"] == i:
				slot_info = " [%d sem.]" % slot["semillas"]
				break
		"""
		_agregar_boton(_semillas_vbox,
			"Planta %d — 1 semente (%d$)%s" % [i + 1, preco, slot_info],
			func(): GameController.comprar_semente(i))

func _rellenar_plantas() -> void:
	for child in _plantas_vbox.get_children():
		child.queue_free()
	var alguma = false
	for i in GameController.plantas.size():
		if GameController.plantas_desbloqueadas[i]:
			continue
		alguma = true
		_agregar_boton(_plantas_vbox,
			"Desbloquear planta %d (%d$)" % [i + 1, GameController.preco_desbloquear_planta],
			func(): _on_comprar(func(): return GameController.desbloquear_planta(i)))
	if not alguma:
		var lbl = Label.new()
		lbl.text = "Todas as plantas desbloqueadas"
		_plantas_vbox.add_child(lbl)

func _rellenar_upgrades() -> void:
	for child in _upgrades_vbox.get_children():
		child.queue_free()

	if GameController.slots_max < GameController.plantas.size():
		_agregar_boton(_upgrades_vbox,
			"Slot extra (%d$)" % GameController.preco_slot_extra,
			func(): _on_comprar(GameController.comprar_slot))

	if GameController.capacidade_max < GameController.CAPACIDADE_TOPE:
		_agregar_boton(_upgrades_vbox,
			"Ampliar capacidad +5 (%d$)  [%d/%d]" % [GameController.preco_ampliar_capacidade, GameController.capacidade_max, GameController.CAPACIDADE_TOPE],
			func(): _on_comprar(GameController.ampliar_capacidade))

	_agregar_boton(_upgrades_vbox,
		"Curar celeiro +25 HP (%d$)" % GameController.preco_curar_celeiro,
		func(): _on_comprar(GameController.curar_celeiro))

	if GameController.vida_celeiro_max < GameController.VIDA_CELEIRO_TOPE:
		_agregar_boton(_upgrades_vbox,
			"Vida máx celeiro +25 (%d$)  [%d/%d]" % [GameController.preco_ampliar_vida_max, GameController.vida_celeiro_max, GameController.VIDA_CELEIRO_TOPE],
			func(): _on_comprar(GameController.ampliar_vida_max_celeiro))

func _agregar_boton(parent: Control, texto: String, callback: Callable) -> void:
	var btn = Button.new()
	btn.text = texto
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _on_comprar(metodo: Callable) -> void:
	metodo.call()
	_actualizar()
