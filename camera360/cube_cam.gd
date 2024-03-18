extends Node3D

@export_subgroup("Settings Viewport")
@export var cube_size:float = 512
@export var shadow_atlast_size:float = 1024
@export_enum("linear", "nearest") var texture_filter:String = "nearest"

@export_subgroup("Settings Camera")
@export var near:float = 0.1
@export var far:float = 300.0
@export var antialias_msaa:bool = false

var is_ready = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# now we're ready
	setup()
	is_ready = true


func _process(delta):
	# update viewports' global position
	var t = global_transform
	$ForwardViewport/Position.global_transform = t
	$LeftViewport/Position.global_transform = t
	$BackViewport/Position.global_transform = t
	$RightViewport/Position.global_transform = t
	$TopViewport/Position.global_transform = t
	$BottomViewport/Position.global_transform = t


func setup():
	# camera settings
	for camera:Camera3D in get_tree().get_nodes_in_group('camera'):
		camera.far = far
		camera.near = near
	# viewport settings
	for viewport:SubViewport in get_tree().get_nodes_in_group('viewport'):
		viewport.size = Vector2(cube_size, cube_size)
		viewport.positional_shadow_atlas_size = shadow_atlast_size
		# antialias msaa
		if antialias_msaa: viewport.msaa_3d = 3
		else: viewport.msaa_3d = 0
		# texture filter
		match texture_filter:
			"linear": 
				viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
			"nearest": 
				viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	print('CUBECAM SETTINGS: ', cube_size, ' ', texture_filter, ' ', antialias_msaa)


func get_forward_texture():
	return $ForwardViewport.get_texture()

func get_left_texture():
	return $LeftViewport.get_texture()

func get_back_texture():
	return $BackViewport.get_texture()

func get_right_texture():
	return $RightViewport.get_texture()

func get_top_texture():
	return $TopViewport.get_texture()

func get_bottom_texture():
	return $BottomViewport.get_texture()
