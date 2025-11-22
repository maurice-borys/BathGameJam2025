extends CharacterBody2D
class_name Fighter

var target : Node2D
var closestEnemy : Node2D
var inRange : Array[Health]
var inRangeSpecial : Array[Health]

signal completedMap()

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : Node2D = $Polygon2D
@onready var basicTimer : Timer = $BasicCoolDown
@onready var specialTimer : Timer = $SpecialCoolDown
@onready var areaRange : Area2D = $BasicRange
@onready var areaRangeSpecial : Area2D = $SpecialRange
@onready var healthModule : Health = $HealthModule

@export var targetArray : Array[Node2D]
@export var testEnemy : Node2D
@export var maxHealth = 1000
@export var speed : float = 10
@export var range : Vector2 = Vector2(10,20)
@export var basicCoolDown : float = 1
@export var specialCoolDown : float = 3
@export var damage : float = 10
@export var damageSpecial : float = 30

func _ready() -> void:
	areaRange.body_entered.connect(enteredRange)
	areaRange.body_exited.connect(exitedRange)
	
	areaRangeSpecial.body_entered.connect(enteredRangeSpecial)
	areaRangeSpecial.body_exited.connect(exitedRangeSpecial)
	
	basicTimer.wait_time = basicCoolDown
	specialTimer.wait_time = specialCoolDown
	
	healthModule.maxHealth = maxHealth
	healthModule.health = maxHealth
	healthModule.healthChanged.connect(healthChanged)
	
	agent.velocity_computed.connect(safeVelocity)
	
	target = targetArray.pop_front()
	setClosestEnemy(testEnemy)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		if targetArray.size() <= 0:
			completedMap.emit()
		else:
			target = targetArray.pop_front()
	
	agent.target_position = target.global_position
	
	if not is_instance_valid(closestEnemy):
		closestEnemy = null
	
	if global_position.distance_to(closestEnemy.global_position) < range.x && closestEnemy != null:
		rotation = (global_position.direction_to(closestEnemy.position).angle() + PI/2) 
		attack()
	elif global_position.distance_to(target.global_position) > range.y:
		move()
	else:
		attack()

func move() -> void:
	var pathPos = agent.get_next_path_position()
	var newVelocity = Vector2 (global_position.direction_to(pathPos) * speed)
	agent.velocity = newVelocity
	rotation = velocity.angle() + PI/2
	
	move_and_slide()

func attack() -> void:
	if specialTimer.time_left == 0 && basicTimer.time_left == 0:
		specialAttack()
		specialTimer.start()
		basicTimer.start()
	elif basicTimer.time_left == 0:
		basicAttack()
		basicTimer.start()

func basicAttack():
	for body in inRange:
		body.dealDamage(damage)
		
func specialAttack():
	for body in inRangeSpecial:
		body.dealDamage(damageSpecial)

func enteredRange(body : Node2D):
	inRange.append(Health.findHealthModule(body))
	
func exitedRange(body : Node2D):
	inRange.erase(Health.findHealthModule(body))
	
func enteredRangeSpecial(body : Node2D):
	inRangeSpecial.append(Health.findHealthModule(body))
	
func exitedRangeSpecial(body : Node2D):
	inRangeSpecial.erase(Health.findHealthModule(body))

func setClosestEnemy(enemy : Node2D) -> void:
	if closestEnemy == null:
		closestEnemy = enemy
		return
	
	if global_position.distance_to(enemy.global_position) < global_position.distance_to(closestEnemy.global_position):
		closestEnemy = enemy

func healthChanged(old : float, new : float) -> void:
	print(self.name + " -> " + str(new))
	if new <= 0:
		queue_free()
		
func safeVelocity(safeVel):
	velocity = safeVel
