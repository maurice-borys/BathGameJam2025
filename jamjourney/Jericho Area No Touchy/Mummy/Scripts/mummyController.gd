extends CharacterBody2D

var target : Vector2 = Vector2.ZERO
var playerOriginalStats : Dictionary[Node2D, Vector2]
var inRange : Array[Health]

@onready var shieldCTimer : Timer = $Timers/shieldCooldown
@onready var stopHealCTimer : Timer = $Timers/stopHealCooldown
@onready var strikeCTimer : Timer = $Timers/strikeCooldown
@onready var shieldDTimer : Timer = $Timers/shieldDuration
@onready var stopHealDTimer : Timer = $Timers/stopHealDuration

@onready var healthModule : Health = $HealthModule
@onready var strikeHitBox : Area2D = $Pivot/Area2D
@onready var pivot : Node2D = $Pivot

var players : Array[Node2D]
@export var maxHealth : float = 1000
@export var speed : float = 25
@export var damage : float = 30
@export var damageModifier : float = 0.5
@export var sandShieldCool : float = 3
@export var stopHealCool : float = 5
@export var strikeCool : float = 1
@export var shieldDuration : float = 1
@export var stopHealDuration : float = 1

func _ready() -> void:
	var rawPlayer = get_tree().get_nodes_in_group("Players")
	for raw in rawPlayer:
		if raw is Node2D:
			players.append(raw)
	
	healthModule.maxHealth = maxHealth
	healthModule.health = maxHealth
	healthModule.healthChanged.connect(healthChanged)
	
	strikeHitBox.body_entered.connect(inRangeEntered)
	strikeHitBox.body_exited.connect(inRangeExited)
	
	target = global_position
	
	shieldCTimer.wait_time = sandShieldCool
	strikeCTimer.wait_time = strikeCool
	stopHealCTimer.wait_time = stopHealCool
	shieldDTimer.wait_time = shieldDuration
	stopHealDTimer.wait_time = stopHealDuration
	
	shieldDTimer.timeout.connect(shieldTimout)
	stopHealDTimer.timeout.connect(noHealsTimeout)
	
	for body in players:
		if body is Cleric:
			playerOriginalStats[body] = Vector2(body.basicHeal,body.specialHeal)
		elif body is Fighter:
			playerOriginalStats[body] = Vector2(body.damage,body.damageSpecial)
		elif body is Mage:
			playerOriginalStats[body] = Vector2(body.damage,body.damageSpecial)

func _physics_process(delta: float) -> void:
	
	players.filter(func(item): return item != null)
	
	if Input.is_action_pressed("left_click"):
		target = get_global_mouse_position()
	
	if Input.is_key_pressed(KEY_1) && strikeCTimer.time_left == 0:
		print("Strike")
		strike()
		strikeCTimer.start()
	elif Input.is_key_pressed(KEY_2) && shieldCTimer.time_left == 0 && shieldDTimer.time_left == 0:
		print("Shield")
		shield()
		shieldCTimer.start()
		shieldDTimer.start()
	elif Input.is_key_pressed(KEY_3) && stopHealCTimer.time_left == 0 && stopHealDTimer.time_left == 0:
		print("No heals")
		noHeals()
		stopHealCTimer.start()
		stopHealDTimer.start()
	
	pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
	velocity = global_position.direction_to(target).normalized() * speed
	move_and_slide()

func strike():
	for body in inRange:
		body.dealDamage(damage)
func shield():
	for body in players:
		if body is not Cleric:
			body.damage = body.damage * damageModifier
			body.damageSpecial = body.damageSpecial * damageModifier
func noHeals():
	for body in players:
		if body is Cleric:
			body.basicHeal = 0
			body.specialHeal = 0

func shieldTimout():
	for body in players:
		if body is not Cleric:
			body.damage = playerOriginalStats[body].x
			body.damageSpecial = playerOriginalStats[body].y
func noHealsTimeout():
	for body in players:
		if body is Cleric:
			body.basicHeal = playerOriginalStats[body].x
			body.specialHeal = playerOriginalStats[body].y

func inRangeEntered(body : Node2D) -> void:
	var health = Health.findHealthModule(body)
	if health != null:
		inRange.append(health)
	
func inRangeExited(body : Node2D) -> void:
	inRange.erase(Health.findHealthModule(body))
	
func healthChanged(old, new):
	print(self.name + " -> " + str(new))
	if new <= 0:
		queue_free()
