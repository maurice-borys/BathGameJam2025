extends StaticBody2D
class_name Generators

@onready var timer = $Timer
@onready var healthModule : Health = $HealthModule

@export var maxHealth = 1000
@export var amountTick : int = 10
@export var tickRate : float = 2

signal manaTick(amount : int)

func _ready() -> void:
	healthModule.healthChanged.connect(healthChanged)
	healthModule.maxHealth = maxHealth
	healthModule.health = maxHealth
	
	timer.wait_time = tickRate
	timer.timeout.connect(getMoolah)
	timer.start()
	
func getMoolah():
	#print("Money")
	manaTick.emit(amountTick)
	
func healthChanged(old, new):
	#print(self.name + " -> " + str(new))
	if new <= 0:
		queue_free()
