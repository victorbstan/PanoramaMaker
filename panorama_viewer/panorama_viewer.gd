extends Node3D

@export var panorama:Texture2D = preload("res://assets/sample-panorama.png")

var sky_material:PanoramaSkyMaterial = PanoramaSkyMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	sky_material.panorama = panorama
	$WorldEnvironment.environment.sky.sky_material = sky_material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup():
	# TODO: check that this works for new files, not yet inported to GODOT
	sky_material.panorama = panorama
	$WorldEnvironment.environment.sky.sky_material = sky_material
	print('PREVIEW: ', panorama.resource_path)
