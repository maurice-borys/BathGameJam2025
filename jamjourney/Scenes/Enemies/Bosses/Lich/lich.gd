extends CharacterBody2D

@export var speed = 300
@export var damage = 200

@onready var fireball = preload("res://Scenes/Enemies/Bosses/Lich/fireball.tscn")
@onready var grunt = preload("res://Scenes/Enemies/Normal/Grunt.tscn")

@onready var nav_component: NavComponent = $NavComponent

@onready var health_module: Health = $HealthModule
#variables for hitboxes and stuff
@onready var sprite: AnimatedSprite2D = $pivot/BasicAttack
@onready var hitbox: Area2D = $pivot/AttackHitbox
@onready var hitbox_shape: CollisionShape2D = $pivot/AttackHitbox/CollisionShape2D

@onready var stun_hitbox: Area2D = $Stun_area
@onready var stun_hitbox_shape: CollisionShape2D = $Stun_area/stun_collision
@onready var stun_anim: AnimatedSprite2D = $stun_anim
@onready var pivot: Node2D = $pivot
@onready var root: CharacterBody2D = get_tree().get_root().get_node("LichBody2D")
#different timers
@onready var death_timer: Timer = $death_timer
@onready var stun_timer: Timer = $stun_timer
@onready var teleport_cd: Timer = $teleport_cd
@onready var fireball_cd: Timer = $fireball_cd
@onready var stun_cd: Timer = $stun_cd
@onready var summon_cd: Timer = $summon_cd
 
@export var teleport_range : float = 300

var click_position = Vector2()
var target_position = Vector2()



var attacking = false
var teleport_ready = true
var fireball_ready = true
var stun_ready = true
var summon_ready = true
var char_speed : float
var char_changed : CharacterBody2D


func _ready():
	add_to_group("enemies")
	click_position = position
	hitbox.body_entered.connect(_on_Hitbox_body_entered)
	stun_hitbox.body_entered.connect(_on_stun_Hitbox_body_entered)
	health_module.healthChanged.connect(health_changed)
	sprite.animation_finished.connect(_on_basic_attack_animation_finished)
	stun_anim.animation_finished.connect(_on_stun_attack_animation_finished)
	
func _process(_delta):
	if Input.is_action_just_pressed("button_1") and not attacking:
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
		start_attack()
	elif Input.is_action_just_pressed("button_2") and not attacking and teleport_ready:
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
		start_teleport()
	elif Input.is_action_just_pressed("button_3") and not attacking and fireball_ready:
		pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle() - PI
		start_shoot()
	elif Input.is_action_just_pressed("button_4") and not attacking and stun_ready:
		start_stun()
	elif Input.is_action_just_pressed("button_5") and not attacking and summon_ready:
		start_summon()
	
	
	
func _physics_process(_delta):
	nav_component.navigate()
	#if Input.is_action_just_pressed("left_click"):
		#click_position = get_global_mouse_position()
	#
	#if position.distance_to(click_position) > 3:
		#target_position = (click_position - position).normalized()
		#velocity = target_position * speed
		#move_and_slide()
		
func start_attack():
	attacking = true
	hitbox_shape.disabled = false
	sprite.play("default")


func start_teleport():
	attacking = true
	teleport_ready = false
	teleport_cd.start()
	if global_position.distance_to(get_global_mouse_position()) <= teleport_range:
		global_position = get_global_mouse_position()
		click_position = get_global_mouse_position()
		
	attacking = false

func start_shoot():
	var fireball_instance = fireball.instantiate()
	attacking = true
	fireball_ready = false
	fireball_cd.start()
	
	pivot.call_deferred("add_child",fireball_instance)
	attacking = false
	
func start_stun():
	attacking = true
	stun_ready = false
	stun_hitbox_shape.disabled = false
	
	stun_anim.play("default")

func start_summon():
	attacking = true
	summon_ready = false
	summon_cd.start()
	
	for i in range(4):
		var grunt_instance = grunt.instantiate()
		root.call_deferred("add_child",grunt_instance)
	
	attacking = false
	


func health_changed(_old, new):
	if new <= 0:
		death_timer.start()




func _on_basic_attack_animation_finished() -> void:
	if sprite.animation == "default":
		hitbox_shape.disabled = true
		attacking = false

func _on_stun_attack_animation_finished() -> void:
	if stun_anim.animation == "default":
		stun_hitbox_shape.disabled = true
		attacking = false
		stun_cd.start()

func _on_Hitbox_body_entered(body):
	if attacking:
		Health.findHealthModule(body).dealDamage(damage)

func _on_stun_Hitbox_body_entered(body):
	if attacking:
		char_changed = body
		char_speed = body.speed
		body.speed = 0
		stun_timer.start()
		

func reset_speed(body,org_speed):
	body.speed = org_speed

func _on_death_timer_timeout() -> void:
	queue_free()
	
func _on_teleport_cd_timeout() -> void:
	teleport_ready = true

func _on_fireball_cd_timeout() -> void:
	fireball_ready = true


func _on_nav_component_computed_velocity(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_stun_cd_timeout() -> void:
	stun_ready = true


func _on_stun_timer_timeout() -> void:
	reset_speed(char_changed,char_speed)


func _on_summon_cd_timeout() -> void:
	summon_ready = true
