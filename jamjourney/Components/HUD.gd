extends CanvasLayer

class_name HUD

@onready var mana_label = $Mana

@export var mana_manager: ManaManager


#func _ready() -> void:
	#pass # Replace with function body.


func _process(delta: float) -> void:
	mana_label.text = str(mana_manager.mana)
	
