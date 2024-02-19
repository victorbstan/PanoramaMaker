extends Node3D

@export var save_file_name:String = 'untitled-panorama'
#DCI = 1K 1024(horizontal) x 540(vertical) = 552.960 pixels.
#DCI 2K = 2048 x 1080 = 2.211.840
#DCI 4K = 4096 x 2160 = 8.847.360
#DCI 8K = 8192 x 4320 = 35.389.440
@export_enum("1K", "2K", "4K", "8K") var output_resolution:String = "2K"
@export_enum("256", "512", "1024", "2048", "4096") var capture_resolution:String = "1024"
@export_enum("linear", "nearest") var texture_filter:String = "nearest"
@export var antialias_msaa:bool = false

@onready var render_container := $RendererContainer
@onready var renderer := $RendererContainer/Renderer
@onready var panorama := $RendererContainer/Renderer/Panorama
@onready var cube_cam := $CubeCam

# Called when the node enters the scene tree for the first time.
func _ready():
	match texture_filter:
			"linear": renderer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
			"nearest": renderer.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	# init our size
	match output_resolution:
		"1K": renderer.size = Vector2(1024, 512)
		"2K": renderer.size = Vector2(2048, 1024)
		"4K": renderer.size = Vector2(4096, 2048)
		"8K": renderer.size = Vector2(8192, 4096)
	match capture_resolution:
		"256": cube_cam.cube_size = 256
		"512": cube_cam.cube_size = 512
		"1024": cube_cam.cube_size = 1024
		"2048": cube_cam.cube_size = 2048
		"4096": cube_cam.cube_size = 4096
	print('PM: ', capture_resolution)
	cube_cam.texture_filter = texture_filter
	cube_cam.antialias_msaa = antialias_msaa
	cube_cam.setup() # call after setting all cube camera parameters
		
	# disable 3d output on our main viewport
	renderer.disable_3d = true
	renderer.use_hdr_2d = false
	
	# bind our camera images to our panorama render
	panorama.set_custom_texture_filter(texture_filter)
	panorama.set_from_cubemap($CubeCam)
	panorama.process_textures() # call after parameter changes
	
	generate_image()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# save panorama as PNG file
func generate_image():
	await RenderingServer.frame_post_draw
	var img = renderer.get_texture().get_image()
	img.save_png("res://panoramas/" + save_file_name +".png")
