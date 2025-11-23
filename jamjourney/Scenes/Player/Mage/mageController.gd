extends CharacterBody2D
class_name Mage

var target : Node2D
var closestEnemy : Node2D

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : Node2D = $Polygon2D
@onready var basicTimer : Timer = $BasicCoolDown
@onready var specialTimer : Timer = $SpecialCoolDown
@onready var healthModule : Health = $HealthModule
@onready var rayWall : RayCast2D = $Pivot/RayCast2D
@onready var pivot : Node2D = $Pivot

var homingSpellScene : PackedScene = preload("res://Scenes/Player/Mage/HomingSpell.tscn")
var piercingSpellScene : PackedScene = preload("res://Scenes/Player/Mage/PiercingSpell.tscn")

signal completedMap()

@export var targetArray : Array[Node2D]
@export var testEnemy : Node2D
@export var minMaxHealth : float = 1000
@export var minSpeed : float = 10
@export var range : float = 40
@export var basicCoolDown : float = 1
@export var specialCoolDown : float = 3
@export var minDamage : float = 10
@export var minDamageSpecial : float = 25
@export var rangeWall : float = 50

@export var healthMultiplier : float = 2
@export var speedMultiplier : float = 2
@export var damageMultiplier : float = 2
@export var maxXp : float = 100

var xp : float

var maxHealth : float = 1000
var speed : float = 10
var damage : float = 10
var damageSpecial : float = 25

func _ready() -> void:
	add_to_group("player")
	basicTimer.wait_time = basicCoolDown
	specialTimer.wait_time = specialCoolDown
	
	rayWall.target_position = Vector2.UP * rangeWall
	
	healthModule.maxHealth = maxHealth
	healthModule.health = maxHealth
	healthModule.healthChanged.connect(healthChanged)
	
	agent.velocity_computed.connect(safeVelocity)
	
	addXp(0)
	
	target = targetArray.pop_front()
	setClosestEnemy(testEnemy)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		if targetArray.size() <= 0:
			completedMap.emit()
			return
		else:
			target = targetArray.pop_front()
			
	if target:
		agent.target_position = target.global_position
	
	if not is_instance_valid(closestEnemy):
		closestEnemy = null
		return
	

	if global_position.distance_to(closestEnemy.global_position) < range && closestEnemy != null:
		pivot.rotation = (global_position.direction_to(closestEnemy.position).angle() + PI/2) 
		attack(closestEnemy)
	elif global_position.distance_to(target.global_position) > range:
		move()
		
		if rayWall.is_colliding():
			if rayWall.get_collider() is WallClass:
				attack(rayWall.get_collider())
	else:
		attack(target)

func move() -> void:
	var pathPos = agent.get_next_path_position()
	var newVelocity = Vector2 (global_position.direction_to(pathPos) * speed)
	agent.velocity = newVelocity
	pivot.rotation = velocity.angle() + PI/2
	move_and_slide()

func attack(targ : Node2D) -> void:
	if specialTimer.time_left == 0 && basicTimer.time_left == 0:
		specialAttack()
		specialTimer.start()
		basicTimer.start()
	elif basicTimer.time_left == 0:
		basicAtack(targ)
		basicTimer.start()

func basicAtack(targ : Node2D):
	var spell : HomingSpell = homingSpellScene.instantiate()
	spell.global_position = global_position
	spell.direction = Vector2.RIGHT.rotated(pivot.rotation - PI/2)
	spell.target = targ
	spell.damage = damage
	
	get_tree().current_scene.add_child(spell)
	
func specialAttack():
	var spell : PiercingSpell = piercingSpellScene.instantiate()
	spell.global_position = global_position
	spell.direction = Vector2.RIGHT.rotated(pivot.rotation - PI/2)
	spell.damage = damageSpecial
	
	get_tree().current_scene.add_child(spell)

func setClosestEnemy(enemy : Node2D) -> void:
	if closestEnemy == null:
		closestEnemy = enemy
		return
	
	if global_position.distance_to(enemy.global_position) < global_position.distance_to(closestEnemy.global_position):
		closestEnemy = enemy

func healthChanged(old, new):
	print(self.name + " -> " + str(new))
	if new <= 0:
		queue_free()

func safeVelocity(safeVel):
	velocity = safeVel

func addXp(amount : float):
	xp = clamp(xp + amount,0 , maxXp)
	maxHealth = lerp(minMaxHealth, minMaxHealth * healthMultiplier, xp/maxXp)
	speed = lerp(minSpeed, minSpeed * speedMultiplier, xp/maxXp)
	damage = lerp(minDamage, minDamage * damageMultiplier, xp/maxXp)
	damageSpecial = lerp(minDamageSpecial, minDamageSpecial * damageMultiplier, xp/maxXp)
