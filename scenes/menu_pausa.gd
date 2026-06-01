extends CanvasLayer

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		alternar_pausa()

func alternar_pausa() -> void:
	var novo_estado = not get_tree().paused
	get_tree().paused = novo_estado
	
	if novo_estado == true:
		show()
	else:
		hide()

func _on_voltar_pressed() -> void:
	alternar_pausa()
