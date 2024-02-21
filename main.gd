extends Node3D

var my_root = "res://my_scenes/"
var my_scenes:Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: create a selector for all scenes in "my_scenes" directory
	fetch_scenes_from_dir(my_root)
	print(my_scenes)
	for scene_name in my_scenes.keys():
		$UI/MenuBar/Scenes.add_item(scene_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func fetch_scenes_from_dir(path):
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: ", file_name)
			else:
				print("Found file: ", file_name)
				# Check if scene
				if file_name.ends_with('.tscn') or file_name.ends_with('.scn'):
					# Add to list of valid scenes to load
					var file_path:String = dir.get_current_dir() + file_name
					my_scenes[file_name] = file_path
					print('Full file path: ', file_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")



func _on_scenes_index_pressed(index):
	var id = $UI/MenuBar/Scenes.get_item_text(index)
	print('POPUP INDEX: ', index, id)
	# load scene
	for n in $MyScene.get_children(): n.queue_free()
	var resource:PackedScene = load(my_scenes[id])
	$MyScene.call_deferred("add_child", resource.instantiate())
