extends ColorRect

@export_enum("linear", "nearest") var custom_texture_filter:String = "linear" : set = set_custom_texture_filter
@export var linear_material:Material = preload("res://camera360/canvas_material_linear.tres")
@export var nearest_material:Material = preload("res://camera360/canvas_material_nearest.tres")

var ForwardTexture:Texture: set = set_forward_texture, get = get_forward_texture
var LeftTexture:Texture: set = set_left_texture, get = get_left_texture
var BackTexture:Texture: set = set_back_texture, get = get_back_texture
var RightTexture:Texture: set = set_right_texture, get = get_right_texture
var TopTexture:Texture: set = set_top_texture, get = get_top_texture
var BottomTexture:Texture: set = set_bottom_texture, get = get_bottom_texture

var is_ready = false

func set_custom_texture_filter(filter:String):
	custom_texture_filter = filter

func set_from_cubemap(cubemap):
	set_forward_texture(cubemap.get_forward_texture())
	set_left_texture(cubemap.get_left_texture())
	set_back_texture(cubemap.get_back_texture())
	set_right_texture(cubemap.get_right_texture())
	set_top_texture(cubemap.get_top_texture())
	set_bottom_texture(cubemap.get_bottom_texture())

func set_forward_texture(new_texture : Texture):
	ForwardTexture = new_texture
	if is_ready:
		material.set_shader_parameter('ForwardTexture', ForwardTexture)

func get_forward_texture():
	return ForwardTexture

func set_left_texture(new_texture : Texture):
	LeftTexture = new_texture
	if is_ready:
		material.set_shader_parameter('LeftTexture', LeftTexture)

func get_left_texture():
	return LeftTexture

func set_back_texture(new_texture : Texture):
	BackTexture = new_texture
	if is_ready:
		material.set_shader_parameter('BackTexture', BackTexture)

func get_back_texture():
	return BackTexture

func set_right_texture(new_texture : Texture):
	RightTexture = new_texture
	if is_ready:
		material.set_shader_parameter('RightTexture', RightTexture)

func get_right_texture():
	return RightTexture

func set_top_texture(new_texture : Texture):
	TopTexture = new_texture
	if is_ready:
		material.set_shader_parameter('TopTexture', TopTexture)

func get_top_texture():
	return TopTexture

func set_bottom_texture(new_texture : Texture):
	BottomTexture = new_texture
	if is_ready:
		material.set_shader_parameter('BottomTexture', BottomTexture)

func get_bottom_texture():
	return BottomTexture

# Called when the node enters the scene tree for the first time.
func _ready():
	process_textures()
	is_ready = true


func process_textures():
	match custom_texture_filter:
		"linear": 
			texture_filter = TEXTURE_FILTER_LINEAR
			material = linear_material
		"nearest": 
			texture_filter = TEXTURE_FILTER_NEAREST
			material = nearest_material
	# assign textures to shader
	set_forward_texture(ForwardTexture)
	set_left_texture(LeftTexture)
	set_back_texture(BackTexture)
	set_right_texture(RightTexture)
	set_top_texture(TopTexture)
	set_bottom_texture(BottomTexture)
