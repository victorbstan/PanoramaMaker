extends Node3D

@export var panorama:Texture2D

var sky_material:PanoramaSkyMaterial = PanoramaSkyMaterial.new()
var button_state:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()


func setup():
	sky_material.panorama = panorama
	$WorldEnvironment.environment.sky.sky_material = sky_material
	$WorldEnvironment.environment.sky.sky_material.filter = button_state


func _on_texture_filter_check_button_toggled(toggled_on: bool) -> void:
	$WorldEnvironment.environment.sky.sky_material.filter = toggled_on
	button_state = toggled_on
