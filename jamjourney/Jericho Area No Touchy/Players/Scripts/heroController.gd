extends CharacterBody2D

var target : Vector2 = Vector2 (40, 0)
var closestEnemy : Node2D

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : Node2D = $Polygon2D
@onready var basicTimer : Timer = $BasicCoolDown
@onready var specialTimer : Timer = $SpecialCoolDown

@export var testEnemy : Node2D
@export var speed : float = 10
@export var range : float = 0.5
@export var basicCoolDown : float = 1
@export var specialCoolDown : float = 3
@export var damage : float = 10
func _ready() -> void:
	agent.target_position = target
	
	basicTimer.wait_time = basicCoolDown
	specialTimer.wait_time = specialCoolDown
	
	setClosestEnemy(testEnemy)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(closestEnemy):
		closestEnemy = null
	
	if global_position.distance_to(closestEnemy.global_position) < range && closestEnemy != null:
		sprite.rotation = (global_position.direction_to(closestEnemy.position).angle() + PI/2) 
		attack()
	elif global_position.distance_to(target) > range:
		move()
	else:
		attack()

func move() -> void:
	var pathPos = agent.get_next_path_position()
	var newVelocity = Vector2 (global_position.direction_to(pathPos) * speed)
	velocity = newVelocity
	sprite.rotation = newVelocity.angle()
	move_and_slide()

func attack() -> void:
	if specialTimer.time_left == 0:
		#Basic attacks and special attacks
		print("Special Attack")
		specialTimer.start()
		basicTimer.start()
	elif basicTimer.time_left == 0:
		print("Basic Attack")
		basicTimer.start()

func setClosestEnemy(enemy : Node2D) -> void:
	if closestEnemy == null:
		closestEnemy = enemy
		return
	
	if global_position.distance_to(enemy.global_position) < global_position.distance_to(closestEnemy.global_position):
		closestEnemy = enemy
