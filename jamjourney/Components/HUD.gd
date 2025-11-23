extends CanvasLayer

class_name HUD

@onready var mana_label = $Mana

func _process(delta: float) -> void:
	mana_label.text = str(GlobalVariables.mana)
	
