extends StaticBody2D

var built : bool
var endPoint : Vector2

@onready var poly : Polygon2D = $Polygon2D
@onready var currentCollider : CollisionPolygon2D = $CollisionPolygon2D
@onready var areaCollider : CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var area : Area2D = $Area2D

@export var width : float = 3

func _ready() -> void:
	built = false
	
	area.body_entered.connect(areaEntered)
	
func _process(delta: float) -> void:
	if not built:
		showBuild()
		
	if Input.is_action_just_pressed("left_click") and not built:
		built = true
		currentCollider.set_deferred("polygon", getVertexPositions())

func showBuild():
	areaCollider.disabled = true
	poly.polygon = getVertexPositions()
	areaCollider.set_deferred("polygon", getVertexPositions())
	poly.color = Color()
	areaCollider.disabled = false

func areaEntered(body : Node2D):
	print(body.name)
	if body != self:
		built = false

func getVertexPositions() -> Array[Vector2]:
	var directon = get_local_mouse_position().normalized()
	var right = Vector2(-directon.y, directon.x).normalized() * width
	var left = Vector2(directon.y, -directon.x).normalized() * width
	var topRight = right + get_local_mouse_position()
	var topLeft = left + get_local_mouse_position()
	return [left, topLeft, topRight, right]
