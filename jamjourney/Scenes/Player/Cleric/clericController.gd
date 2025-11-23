extends CharacterBody2D
class_name Cleric

var allyTarget : Node2D
var currentRange : float
var healingArea : Array[Health]

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var basicTimer : Timer = $BasicCoolDown
@onready var specialTimer : Timer = $SpecialCoolDown
@onready var healthModule : Health = $HealthModule
@onready var specialHitbox : Area2D = $Area2D

var allies : Array[Node2D]
@export var minMaxHealth : float = 1000
@export var minSpeed : float = 10
@export var range : Vector2 = Vector2(10,30)
@export var basicCoolDown : float = 1
@export var specialCoolDown : float = 3
@export var minBasicHeal : float = 10
@export var minSpecialHeal : float = 25

@export var healthMultiplier : float = 2
@export var speedMultiplier : float = 2
@export var healMultiplier : float = 2
@export var maxXp : float = 100

var xp : float

var maxHealth : float = 1000
var speed : float = 10
var basicHeal : float = 10
var specialHeal  : float = 25

func _ready() -> void:
	add_to_group("player")
	currentRange = range.x
	
	basicTimer.wait_time = basicCoolDown
	specialTimer.wait_time = specialCoolDown
	
	healthModule.maxHealth = maxHealth
	healthModule.health = maxHealth
	healthModule.healthChanged.connect(healthChanged)
	
	agent.velocity_computed.connect(safeVelocity)
	
	addXp(0)
	sprite.play("Run")
	sprite.animation_finished.connect(killMe)
	
	allies = []
	var rawPlayer = get_tree().get_nodes_in_group("Players")
	for raw in rawPlayer:
		if raw is Node2D and raw != self:
			allies.append(raw)

func _physics_process(delta: float) -> void:
	allies.filter(func(item): return item != null)
	allyTarget = getLowestHealthAlly()
	
	if allyTarget != null:
		agent.target_position = allyTarget.position
	else:
		return
	
	if global_position.distance_to(allyTarget.global_position) < currentRange:
		currentRange = range.y
		#rotation = (global_position.direction_to(allyTarget.position).angle() + PI/2) 
		action()
	elif global_position.distance_to(allyTarget.global_position) > currentRange:
		currentRange = range.x
		move()

func killMe():
	sprite.play("Run")

func move() -> void:
	var pathPos = agent.get_next_path_position()
	var newVelocity = Vector2 (global_position.direction_to(pathPos) * speed)
	agent.velocity = newVelocity
	#rotation = velocity.angle() + PI/2
	move_and_slide()

func action() -> void:
	if specialTimer.time_left == 0 && basicTimer.time_left == 0:
		specialAction()
		specialTimer.start()
		basicTimer.start()
	elif basicTimer.time_left == 0:
		basicAction()
		basicTimer.start()

func basicAction():
	sprite.play("Heal")
	Health.findHealthModule(allyTarget).healHealth(basicHeal)
	
func specialAction():
	sprite.play("Heal")
	for body in healingArea:
		body.healHealth(specialHeal)

func enteredHealing(body : Node2D):
	healingArea.append(Health.findHealthModule(body))
	
func exitedHealing(body : Node2D):
	healingArea.erase(Health.findHealthModule(body))

func getLowestHealthAlly() -> Node2D:
	if allies.size() == 0:
		return null
	
	var lowestHealth = allies[0]
	for body in allies:
		var module = Health.findHealthModule(body)
		if module.health < Health.findHealthModule(body).health:
			lowestHealth = body
			
	return lowestHealth
		
func healthChanged(_old, new):
	print(self.name + " -> " + str(new))
	if new <= 0:
		queue_free()

func safeVelocity(safeVel):
	velocity = safeVel

func addXp(amount : float):
	xp = clamp(xp + amount,0 , maxXp)
	maxHealth = lerp(minMaxHealth, minMaxHealth * healthMultiplier, xp/maxXp)
	speed = lerp(minSpeed, minSpeed * speedMultiplier, xp/maxXp)
	basicHeal = lerp(minBasicHeal, minBasicHeal * healMultiplier, xp/maxXp)
	specialHeal = lerp(specialHeal, specialHeal * healMultiplier, xp/maxXp)
