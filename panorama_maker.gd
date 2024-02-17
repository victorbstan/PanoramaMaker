extends Node3D

@export var save_file_name:String = 'untitled-panorama'
#DCI = 1K 1024(horizontal) x 540(vertical) = 552.960 pixels.
#DCI 2K = 2048 x 1080 = 2.211.840
#DCI 4K = 4096 x 2160 = 8.847.360
#DCI 8K = 8192 x 4320 = 35.389.440
@export_enum("1K", "2K", "4K", "8K") var resolution:String = "2K"

@onready var render_container = $RendererContainer
@onready var renderer = $RendererContainer/Renderer
@onready var panorama = $RendererContainer/Renderer/Panorama

# Called when the node enters the scene tree for the first time.
func _ready():
	# init our size
	match resolution:
		"1K": renderer.size = Vector2(1024, 512)
		"2K": renderer.size = Vector2(2048, 1024)
		"4K": renderer.size = Vector2(4096, 2048)
		"8K": renderer.size = Vector2(8192, 4096)
		
	# disable 3d output on our main viewport
	renderer.disable_3d = true
	renderer.use_hdr_2d = false
	
	# bind our camera images to our panorama render
	panorama.set_from_cubemap($CubeCam)
	
	_generate_icon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# save panorama as PNG file
func _generate_icon():
	await RenderingServer.frame_post_draw
	var img = renderer.get_texture().get_image()
	img.save_png("res://panoramas/" + save_file_name +".png")
