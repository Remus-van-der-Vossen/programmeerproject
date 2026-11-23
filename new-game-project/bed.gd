extends "res://furniture_object.gd"

@export var free_space_width = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh = mesh
	$FurnitureHitbox.shape.size = size
	position = (position - size * 0.5).snapped(Vector3.ONE * grid_size) + size * 0.5
	$HeadboardWallDetector/CollisionShape3D.shape.size = Vector3(0.05, 1, size.z - 0.05)
	 # Replace with function body.
	$FreeSpaceLeft.position.z = -(size.z + free_space_width) / 2
	$FreeSpaceRight.position.z = (size.z + free_space_width) / 2
	$FreeSpaceLeft/CollisionShape3D.shape.size.z = free_space_width - 0.05

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func calculate_score():
	var score = 0
	
	if not $HeadboardWallDetector.get_overlapping_bodies():
		print("head not against wall")
		score = score - 100
		
	if $HeadboardWindowDetector.get_overlapping_areas():
		print("head against window")
		score = score - 100
	
	# One person bed
	if size.z <= 1:
		if not $FreeSpaceLeft.get_overlapping_bodies() or not $FreeSpaceRight.get_overlapping_bodies():
			print("at least one side is free")
			score = score + 40
	# Two person bed
	else:
		if not $FreeSpaceLeft.get_overlapping_bodies():
			print("left side is free")
			score = score + 20
		if not $FreeSpaceRight.get_overlapping_bodies():
			print("right side is free")
			score = score + 20
	
	return score
