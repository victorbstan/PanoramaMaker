extends Node3D

@export var save_file_name:String = 'untitled-panorama'


# Called when the node enters the scene tree for the first time.
func _ready():
	# disable 3d output on our main viewport
	var vp = get_viewport()
	vp.disable_3d = true
	#vp.usage = Viewport.
	vp.use_hdr_2d = false
	
	# bind our camera images to our panorama render
	$Panorama.set_from_cubemap($CubeCam)
	
	# connect to our window resize signal
	#get_tree().get_root().connect("size_changed", self, "on_resize")
	
	# init our size
	on_resize()
	_generate_icon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_resize():
	$Panorama.size = get_viewport().size;


# save panorama as PNG file
func _generate_icon():
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://panoramas/" + save_file_name +".png")
