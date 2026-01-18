extends CharacterBody3D

@export_group("Arena Movement")
@export var SPEED: float = 8.0 
@export var ROTATION_SPEED: float = 14.0 # High energy turning for arcade feel
@export var ACCELERATION: float = 0.25
@export var FRICTION: float = 0.2

# Nodes mapped to your specific hierarchy
@onready var visual_node: Node3D = $CharacterArmature
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Get Input Vector
	# Note: In an isometric view, you may want to rotate your input vector by 45 degrees
	# to match the screen's "Up" with the world's "Diagonal".
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction != Vector3.ZERO:
		# PUNCHY VELOCITY: Use lerp for snappy acceleration
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION)
		
		# CINEMATIC ROTATION: Smoothly face the move direction
		var target_angle = atan2(direction.x, direction.z)
		visual_node.rotation.y = lerp_angle(visual_node.rotation.y, target_angle, ROTATION_SPEED * delta)
		
		# ANIMATION: Rapid transition to Walk
		_handle_animation("Walk", 0.1)
	else:
		# INSTANT DECARCELLATION: For that responsive arcade stop
		velocity.x = move_toward(velocity.x, 0, SPEED * FRICTION)
		velocity.z = move_toward(velocity.z, 0, SPEED * FRICTION)
		
		# ANIMATION: Smooth transition back to Idle
		_handle_animation("Idle", 0.2)

	move_and_slide()

func _handle_animation(anim_name: String, blend: float) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name, blend)