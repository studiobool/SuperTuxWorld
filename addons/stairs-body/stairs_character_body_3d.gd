class_name StairsCharacterBody3D
extends CharacterBody3D
## CharacterBody3D that automatically controlls movement up and down the stairs
##
## How to use:[br][br]
## Set [code]velocity[/code] to whatever value you wish to move;[br]
## Don't forget to call [code]super(delta)[/code] at the start of [code]_physics_process[/code] if you are overriding it.[br]
##[br][br][br]
## Credits:
##[br][br]
## Special thanks to [url=https://www.youtube.com/@MajikayoGames]Majikayo Games[/url]
## for [url=https://youtu.be/-WjM1uksPIk]original solution to stair_step_down[/url]!
##[br][br]
## Special thanks to [url=https://github.com/myria666/]Myria666[/url]
## for [url=https://github.com/myria666/qMovementDoc]paper on Quake movement mechanics[/url]
## (used for stair_step_up)!
##[br][br]
## Special thanks to [url=https://github.com/Andicraft]Andicraft[/url]
## for help with implementation of stair_step_up!
##[br][br]
## Special thanks to [url=https://github.com/JheKWall/]JheKWall[/url] for
## [url=https://github.com/JheKWall/Godot-Stair-Step-Demo]original character controller demo[/url]
## this is based on!
##[br][br]
## [url=https://github.com/Visssarion]Vissa[/url] refactored previous code
## so that it could be used with Entity Component System or with Node Inheritance
## [br][br][br]
## Notes:[br][br]
## 0. All shape colliders are supported. Although, I would recommend Capsule colliders for enemies
##		as it works better with the Navigation Meshes. Its up to you what shape you want to use
##		for players.
##[br][br]
## 1. To adjust the step-up/down height, just change the MAX_STEP_UP/MAX_STEP_DOWN values below.
##[br][br]
## 2. This uses Jolt Physics as the default Godot Physics has a few bugs:[br]
##	2.1: Small gaps that you should be able to fit through both ways will block you in Godot Physics.
##		You can see this demonstrated with the floating boxes in front of the big stairs.[br]
##	2.2: Walking into some objects may push the player downward by a small amount which causes
##		jittering and causes the floor to be detected as a step.[br]
##	TLDR: This still works with default Godot Physics, although it feels a lot better in Jolt Physics.

#region ANNOTATIONS ################################################################################
@export_category("Character's Collider")
## Collider that will be used for body's stair collision
@export var PLAYER_COLLIDER: CollisionShape3D
@export_category("Character Settings")
## Max height body will go up stairs.
@export var MAX_STEP_UP := 0.5			# Maximum height in meters the player can step up.
## Max height body will go down stairs.
@export var MAX_STEP_DOWN := -0.5		# Maximum height in meters the player can step down.

@export_category("Debug Settings")
## Set to [code]true[/code] for body to print debug info for upward calculations
@export var STEP_DOWN_DEBUG := false	# Enable these to get detailed info on the step down/up process.
## Set to [code]true[/code] for body to print debug info for downward calculations
@export var STEP_UP_DEBUG := false

# Node References

#endregion

#region VARIABLES ##################################################################################
## Returns [code]true[/code] if body is grounded
var is_grounded := true					# If player is grounded this frame
## Returns [code]true[/code] if body was grounded last physics frame
var was_grounded := true				# If player was grounded last frame
## Calculated horizontal direction that body wants to move.[br]
## DO NOT USE THIS TO SET VELOCITY. Set [code]velocity[/code] instead.[br]
## [code]wish_dir[/code] is a left over from old implementation, so leaving it prevents stuff from breaking
var wish_dir := Vector3.ZERO			# Player input (WASD) direction

const vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical
const horizontal := Vector3(1, 0, 1)		# Shortcut for converting vectors to horizontal
#endregion

#region IMPLEMENTATION #############################################################################

func _physics_process(delta: float) -> void:
	_pre_physics_process()
	_post_physics_process.call_deferred()

# Function: Handle settings made before physical movements of this body
func _pre_physics_process():
	# Lock player collider rotation
	PLAYER_COLLIDER.global_rotation = Vector3.ZERO

	# Update player state
	was_grounded = is_grounded

	if is_on_floor():
		is_grounded = true
	else:
		is_grounded = false


# Function: Handle movement after velocity has been set
func _post_physics_process():
	# Retrieve wish_dir from velocity that was passed here.
	# wish_dir is a left over from old implementation, so getting it from velocity prevents stuff from breaking
	wish_dir = Vector3(velocity.x, 0, velocity.z).normalized()

	# Stair step up
	stair_step_up()

	# Move
	move_and_slide()

	# Stair step down
	stair_step_down()

# Function: Handle walking down stairs
func stair_step_down():
	if is_grounded:
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:
		_debug_stair_step_down("SSD_ENTER", null)													## DEBUG

		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true
			_debug_stair_step_down("SSD_APPLIED", body_test_result.get_travel().y)					## DEBUG

# Function: Handle walking up stairs
func stair_step_up():
	if wish_dir == Vector3.ZERO:
		return

	if velocity.y > 0:
		return

	_debug_stair_step_up("SSU_ENTER", null)															## DEBUG

	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = wish_dir * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		_debug_stair_step_up("SSU_EXIT_1", null)													## DEBUG

		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	_debug_stair_step_up("SSU_REMAINING", remainder)												## DEBUG
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

		_debug_stair_step_up("SSU_TEST_POS", test_transform)										## DEBUG

	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		_debug_stair_step_up("SSU_EXIT_2", null)													## DEBUG

		return

	test_transform = test_transform.translated(body_test_result.get_travel())
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()

	if STEP_UP_DEBUG:
		print("SSU: Surface check: ", snappedf(surface_normal.angle_to(vertical), 0.001), " vs ", floor_max_angle)#!
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):
		_debug_stair_step_up("SSU_EXIT_3", null)													## DEBUG

		return

	if STEP_UP_DEBUG:
		print("SSU: Walkable")#!
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 6. Move player up
	var global_pos = global_position
	var step_up_dist = test_transform.origin.y - global_pos.y
	_debug_stair_step_up("SSU_APPLIED", step_up_dist)												## DEBUG

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos


#endregion

#region DEBUG ####################################################################################

# Debug: Stair Step Down
func _debug_stair_step_down(param, value):
	if STEP_DOWN_DEBUG == false:
		return

	match param:
		"SSD_ENTER":
			print()
			print("Stair step down entered")
		"SSD_APPLIED":
			print("Stair step down applied, travel = ", value)

# Debug: Stair Step Up
func _debug_stair_step_up(param, value):
	if STEP_UP_DEBUG == false:
		return

	match param:
		"SSU_ENTER":
			print()
			print("SSU: Stair step up entered")
		"SSU_EXIT_1":
			print("SSU: Exited with no collisions")
		"SSU_TEST_POS":
			print("SSU: test_transform current position = ", value)
		"SSU_REMAINING":
			print("SSU: Remaining distance = ", value)
		"SSU_EXIT_2":
			print("SSU: Exited due to no step collision")
		"SSU_EXIT_3":
			print("SSU: Exited due to non-floor stepping")
		"SSU_APPLIED":
			print("SSU: Player moved up by ", value, " units")


#endregion
