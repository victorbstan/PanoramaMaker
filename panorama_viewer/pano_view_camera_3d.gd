extends Camera3D

@export var angle_increment:float = 45

var my_euler = Vector3.ZERO
var new_euler = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	new_euler = my_euler
	if Input.is_action_pressed('ui_left'):
		new_euler.y += angle_increment
		my_euler.y = lerp_angle(my_euler.y, new_euler.y, angle_increment*delta)
	if Input.is_action_pressed('ui_right'):
		new_euler.y -= angle_increment
		my_euler.y = lerp_angle(my_euler.y, new_euler.y, angle_increment*delta)
	if Input.is_action_pressed('ui_up'):
		new_euler.x += angle_increment
		my_euler.x = lerp_angle(my_euler.x, new_euler.x, angle_increment*delta)
	if Input.is_action_pressed('ui_down'):
		new_euler.x -= angle_increment
		my_euler.x = lerp_angle(my_euler.x, new_euler.x, angle_increment*delta)
		
	set_rotation_degrees(my_euler)
