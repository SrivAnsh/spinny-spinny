extends RigidBody2D

@export var max_power := 1500.0
@export var charge_rate := 1200.0
@export var stop_speed := 15.0
@export var margin := 48.0

var charge := 0.0
var charging := false
var launched := false
var launch_timer := 0.0
var reset_requested := false
var start_pos: Vector2

func _ready():
	start_pos = get_centre_left()
	global_position = start_pos
	can_sleep = false 
	
func get_centre_left() -> Vector2:
	var screen_size := get_viewport().get_visible_rect().size
	var screen_point := Vector2(margin, screen_size.y / 2.0)
	return get_viewport().get_canvas_transform().affine_inverse() * screen_point

func _process(delta):
	if launched:
		launch_timer += delta
		if launch_timer > 0.3 and linear_velocity.length() < stop_speed:
			reset()
		return

	var dir := (get_global_mouse_position() - global_position).normalized()
	$Arrow.global_rotation = dir.angle()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		charging = true
		charge = min(charge + charge_rate * delta, max_power)
		$Arrow.scale.x = 1.0 + charge / max_power
	elif charging:
		launch(dir * charge)

func launch(impulse: Vector2):
	print("Launching with power: ", impulse.length())
	charging = false
	launched = true
	launch_timer = 0.0
	$Arrow.visible = false
	apply_central_impulse(impulse)
	angular_velocity = 40.0

func reset():
	print("Reset")
	reset_requested = true
	launched = false
	charge = 0.0
	$Arrow.scale.x = 1.0
	$Arrow.visible = true

func _integrate_forces(state):
	if reset_requested:
		state.transform = Transform2D(0, start_pos)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		reset_requested = false
