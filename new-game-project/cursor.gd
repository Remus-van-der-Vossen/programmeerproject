extends CharacterBody3D

@export var speed = 2
@export var default_size = Vector3(0.1, 2.6, 0.1)
@export var default_position = Vector3(0.05, 0, 0.05)

@onready var selection_green = preload("res://selection_green.tres")
@onready var selection_red = preload("res://selection_red.tres")
@onready var default_mesh = preload("res://default_cursor.tres")

var grid_size = 0.1

var selected_object = null
var can_place = true
var moving = false
var rotating = false
var interacting_objects = null
var selection_size = default_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select(null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# We create a local variable to store the input direction.
	handle_movement()
	
	can_place = true
	interacting_objects = $Pivot/Area3D.get_overlapping_bodies()
	
	if selected_object:
		if len(interacting_objects) > 1:
			can_place = false
		
		if not moving:
			var rotation_direction = get_rotation_direction()
		
			if rotation_direction != 0:
				rotate_selected(rotation_direction)
		
		selected_object.position = position
		selected_object.rotation = $Pivot.rotation

	if not moving:
		handle_selection()
		update_collision_size()
		
	set_color()

func get_direction():
	var direction = Vector3.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.z += 1
	if Input.is_action_pressed("up"):
		direction.z -= 1
	
	return direction

func handle_movement():
	var direction = get_direction()	
	
	#Stop when moving into a wall, but keep sliding past it.
	if direction != Vector3.ZERO:
		if check_for_wall(Vector3(direction.x, 0, 0)):
			direction.x = 0
		
		if check_for_wall(Vector3(0, 0, direction.z)):
			direction.z = 0
		
		#Fixes trying to go into a block diagonally
		if check_for_wall(direction):
			direction = Vector3.ZERO
	
	if direction != Vector3.ZERO:
		move(direction)

func check_for_wall(direction):
	$RayCast3D.target_position = direction * grid_size
	$RayCast3D.force_raycast_update()
	return $RayCast3D.is_colliding()

func move(direction):
	if moving == false and rotating == false:
			moving = true
			var tween = create_tween()
			tween.tween_property(self, "position", position + direction * grid_size, 0.1)
			tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_callback(stop_moving)

func stop_moving():
	moving = false

func set_color():
	if can_place:
		$Pivot/MeshInstance3D.material_override = selection_green
	else:
		$Pivot/MeshInstance3D.material_override = selection_red

func get_rotation_direction():
	var rotation_direction = 0
	
	if Input.is_action_pressed("rotate_right"):
		rotation_direction += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_direction -= 1
	
	return rotation_direction

func rotate_selected(rotation_direction):
	if rotating == false:
		rotating = true
		
		var tween = create_tween()
		tween.tween_property($Pivot, "rotation_degrees", Vector3(0, $Pivot.rotation_degrees.y + rotation_direction * 90, 0), 1)
		#tween.tween_property(selected_object, "rotation_degrees", Vector3(0, rotation_degrees.y + rotation_direction * 90, 0), 0.1)
		#tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_callback(stop_rotating)

func stop_rotating():
	rotating = false

func handle_selection():
	if Input.is_action_just_pressed("select"):
			if not selected_object:
				if interacting_objects:
					select(interacting_objects[0])
			else:
				if can_place:
					select(null)

func select(object: StaticBody3D):
	if object: 
		selected_object = object
		position = object.position
		$Pivot.rotation = object.rotation
		position.y = 0.5
		var source_mesh := object.get_node("MeshInstance3D") as MeshInstance3D
		$Pivot/MeshInstance3D.mesh = source_mesh.mesh
		$Pivot/MeshInstance3D.position.y = 0.1
		selection_size.x = object.size.x
		selection_size.z = object.size.z
			
	else:
		if selected_object:
			selected_object.position.y = 0
		selected_object = null
		position = default_position
		$Pivot.rotation = Vector3.ZERO
		$Pivot/MeshInstance3D.mesh = default_mesh
		$Pivot/MeshInstance3D.position.y = 0
		selection_size = default_size

func update_collision_size():
	$Pivot/Area3D/CollisionShape3D.shape.size = selection_size - Vector3(0.05, 0, 0.05)
