extends CanvasLayer

@export var slot_scene: PackedScene
@export var textura_slot_normal: Texture2D
@export var textura_slot_seleccionado: Texture2D
@export var texturas_semillas: Array[Texture2D] = []

var _slot_actual: int = 0
var _contenedor: HBoxContainer

func _ready() -> void:
	_contenedor = $Slots
	_reconstruir_slots()
	GameController.inventario_mudou.connect(_reconstruir_slots)
	GameController.slot_mudou.connect(_on_slot_mudou)

func _reconstruir_slots() -> void:
	for hijo in _contenedor.get_children():
		hijo.free()
	for i in GameController.inventario.size():
		var slot = slot_scene.instantiate()
		slot.name = "Slot%d" % i
		_contenedor.add_child(slot)
	_actualizar()

func _actualizar() -> void:
	for i in GameController.inventario.size():
		if i >= _contenedor.get_child_count():
			break
		var slot_ctrl = _contenedor.get_child(i)
		var slot_data = GameController.inventario[i]

		var bg: TextureRect = slot_ctrl.get_node("BG")
		bg.texture = textura_slot_seleccionado if i == _slot_actual else textura_slot_normal

		var icono: TextureRect = slot_ctrl.get_node("Icono")
		var cantidad: Label = slot_ctrl.get_node("Cantidad")

		if slot_data != null:
			var pidx: int = slot_data["planta_idx"]
			icono.texture = texturas_semillas[pidx] if pidx < texturas_semillas.size() else null
			icono.visible = true
			cantidad.text = "x%d" % slot_data["semillas"]
			cantidad.visible = true
		else:
			icono.visible = false
			cantidad.visible = false

func _on_slot_mudou(idx: int) -> void:
	_slot_actual = idx
	_actualizar()
