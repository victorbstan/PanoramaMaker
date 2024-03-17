extends Node3D

@export var panorama:Texture2D = preload("res://assets/sample-panorama.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	var sky_material = PanoramaSkyMaterial.new()
	sky_material.panorama = panorama
	$WorldEnvironment.environment.sky.sky_material = sky_material

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
