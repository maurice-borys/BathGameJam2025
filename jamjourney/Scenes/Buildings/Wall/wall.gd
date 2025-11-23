extends StaticBody2D
class_name WallClass

var built: bool
var endPoint: Vector2

@onready var poly : Polygon2D = $Polygon2D
@onready var currentCollider : CollisionPolygon2D = $CollisionPolygon2D
@onready var areaCollider : CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var navigationRegion : NavigationRegion2D = $NavigationRegion2D
@onready var area : Area2D = $Area2D
@onready var healthModule : Health = $HealthModule

@export var width : float = 3
@export var costPerLength : int = 5

signal rebakeMesh()
signal deleteWall(body)

func _ready() -> void:
	built = false
	endPoint = Vector2.ZERO
	healthModule.healthChanged.connect(healthChanged)
	
func _process(delta: float) -> void:
	if not built:
		areaCollider.disabled = true
		poly.polygon = getVertexPositions()
		areaCollider.set_deferred("polygon", getVertexPositions())
		
		# Visual feedback for collision
		if will_collide():
			poly.color = Color.RED
		else:
			poly.color = Color.GREEN
			
		areaCollider.disabled = false

func init():	
	if not built:
		built = true
		currentCollider.set_deferred("polygon", getVertexPositions())
		areaCollider.disabled = true
		
		var navPoly = NavigationPolygon.new()
		navPoly.add_outline(getVertexPositions())
		navigationRegion.navigation_polygon = navPoly
		
		rebakeMesh.emit()
	
func length() -> float:
	var target = endPoint if endPoint != Vector2.ZERO else get_local_mouse_position()
	return Vector2.ZERO.distance_to(target)

func getVertexPositions() -> Array[Vector2]:
	var target = endPoint if endPoint != Vector2.ZERO else get_local_mouse_position()
	var direction = target.normalized()
	
	var right = Vector2(-direction.y, direction.x) * width
	var left = Vector2(direction.y, -direction.x) * width
	
	var bottomLeft = left
	var topLeft = target + left
	var topRight = target + right
	var bottomRight = right
	
	return [bottomLeft, topLeft, topRight, bottomRight]

func healthChanged(old, new):
	print("Wall -> " + str(new))
	if new <= 0:
		deleteWall.emit(self)

func will_collide() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	var shape = ConvexPolygonShape2D.new()
	shape.points = getVertexPositions()
	
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false  # Don't collide with areas
	query.collision_mask = 0b1111 
	
	var collisions = space_state.intersect_shape(query)
	for collision in collisions:
		if collision.collider != self and collision.collider is not WallClass:
			return true
	return false
