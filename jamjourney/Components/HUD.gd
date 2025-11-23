extends CanvasLayer

@onready var mana_label = $Mana

@export var mana_manager: ManaGer


#func _ready() -> void:
	#pass # Replace with function body.


func _process(delta: float) -> void:
	mana_label.text = str(mana_manager.mana)
	
