extends CharacterBody2D

#exports it so you can change it on the player.gd
@export var walk_speed = 130.0
@export var sprint_speed = 250.0
#creates a slider in the inspector to change the variable value in the range of 0-1
@export_range(0,1) var deceleration = 0.1
@export_range(0,1) var acceleration = 0.1

#for variable jump height
@export var jump_force = -300.0
@export_range(0,1) var decelerate_on_jump_release = 0.1
@export var wall_jump_pushback = 200
@export var wall_slide_gravity = 100
var is_wall_sliding = false

#calls the animated_sprite of our character
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

#hopefully for death animation

#hopefully to make specific jumpable walls
var can_wall_jump = false


func _physics_process(delta: float) -> void:
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	# Handles original jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
		#Handles wall_jumping(although crudely)
		elif is_on_wall():
			
			if Input.is_action_pressed("move_right"):
				
				velocity.y = jump_force
				velocity.x = -wall_jump_pushback
			elif Input.is_action_pressed("move_left"):
				velocity.y = jump_force
				velocity.x = wall_jump_pushback
	
	#calls the original wall_slide function
	wall_slide(delta)

	#adds variable jump height, where velocity.y < 0 makes sure it only happens when we jump upward
	#0.5 value on var decelerate_on_jump_release makes the fall smooth regardless of the jump as tested
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
	
		#speed variable
	var speed
	if Input.is_action_pressed("sprinting"):
		speed = sprint_speed
	else:
		speed = walk_speed 
	
	#gets the input direction which can be -1 1 or 0
	var direction = Input.get_axis("move_left", "move_right")
	
	#flips the sprite
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	#Play animations
	#checks if the player is touching ground
	if is_on_floor():
		#if character is not moving(direction == 0), play idle animation
		if direction == 0:	
			animated_sprite.play("idle")
		#then check if the player presses sprint button and is moving, play sprint animation
		elif Input.is_action_pressed("sprinting") and direction != 0:
			animated_sprite.play("sprint")
		#if not then play walk animation
		else:	
			animated_sprite.play("walk")
			
	#is character not touching ground, play jump animation
	else:
		animated_sprite.play("jump")
	
	#applies the movement
	if direction:
			#moves from current velocity to the product of direction and walkspeed, the delta is walkspeed * acceleration
			#makes the character build up speed as the move
			#only put speed in acceleration since putting it in deceleration would make it inconsistent
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
			#moves the current velocity to the value 0(character is not moving), the delta is now walk_speed * deceleration
			#makes the character slow down as they as they stop moving
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
	move_and_slide()	

#the  original wall_slide function
func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	if is_wall_sliding:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)
