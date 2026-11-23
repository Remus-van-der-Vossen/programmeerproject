extends StaticBody3D

var grid_size = 0.1

# x and z size need to be BOTH EVEN or BOTH ODD
@export var size: Vector3
@export var mesh: Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("A")
	$MeshInstance3D.mesh = mesh
	$FurnitureHitbox.shape.size = size
	position = (position - size * 0.5).snapped(Vector3.ONE * grid_size) + size * 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#position = (position - size * 0.5).snapped(Vector3.ONE * grid_size) + size * 0.5
