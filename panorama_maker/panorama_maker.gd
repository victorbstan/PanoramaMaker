extends Node3D

@export var save_file_name:String
#DCI = 1K 1024(horizontal) x 540(vertical) = 552.960 pixels.
#DCI 2K = 2048 x 1080 = 2.211.840
#DCI 4K = 4096 x 2160 = 8.847.360
#DCI 8K = 8192 x 4320 = 35.389.440
@export_enum("256", "512", "1024", "2048", "4096") var capture_resolution:String = "1024"
@export_enum("512", "1024", "2048", "4096", "8192") var output_resolution:String = "2048"
@export_enum("linear", "nearest") var texture_filter:String = "nearest"
@export var antialias_msaa:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	setup()


# save panorama as PNG file
func save_panorama() -> String:
	setup()
	print('RENDER SETTINGS USED: ', capture_resolution, ' ', output_resolution, ' ', texture_filter, ' ', antialias_msaa)
	await RenderingServer.frame_post_draw
	var img = %Renderer.get_texture().get_image()
	var output_path = "res://panoramas/" + save_file_name +".png"
	await img.save_png(output_path)
	return output_path
	

func save_skybox():
	setup()
	# TODO: implement 6 texture saving for skybox format
	#Each Skybox face name is composed of two components: the base name and a suffix indicating which face the image relates to.
#
	#The base name should be strictly alphanumeric, and should not contain spaces. Only the base name is used for loading.
#
	#The suffix should be either of "bk" (back face), "ft" (front face), "lf" (left face), "rt" (right face), "up" (up face) or "dn" (down face). 
	pass


func setup():
	# For some reason everytime the project is opened this switches to "Always"...
	%Renderer.render_target_update_mode = %Renderer.UPDATE_WHEN_VISIBLE
	
	match texture_filter:
		"linear": %Renderer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
		"nearest": %Renderer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	match output_resolution:
		"512": %Renderer.size = Vector2(512, 256)
		"1024": %Renderer.size = Vector2(1024, 512)
		"2048": %Renderer.size = Vector2(2048, 1024)
		"4096": %Renderer.size = Vector2(4096, 2048)
		"8192": %Renderer.size = Vector2(8192, 4096)
		
	match capture_resolution:
		"256":  %CubeCam.cube_size = 256
		"512":  %CubeCam.cube_size = 512
		"1024":  %CubeCam.cube_size = 1024
		"2048":  %CubeCam.cube_size = 2048
		"4096":  %CubeCam.cube_size = 4096
		
	%CubeCam.texture_filter = texture_filter
	%CubeCam.antialias_msaa = antialias_msaa
	%CubeCam.setup() # call after setting all cube camera parameters
	
	# bind our camera images to our panorama render
	%Panorama.set_custom_texture_filter(texture_filter)
	%Panorama.set_from_cubemap( %CubeCam)
	%Panorama.process_textures() # call after parameter changes
