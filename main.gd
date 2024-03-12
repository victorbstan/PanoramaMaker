extends Node3D

var my_root = "res://my_scenes/"
var my_scenes:Dictionary = {}
var current_scene:PackedScene
var scene_instance:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	%MessageLabel.text = ''
	%ErrorLabel.text = ''
	fetch_scenes_from_dir(my_root)
	print(my_scenes)
	for scene_name in my_scenes.keys():
		%ScenesMenuBar/Scenes.add_item(scene_name)


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
					var file_path:String = dir.get_current_dir() + '/' + file_name
					my_scenes[file_name] = file_path
					print('Full file path: ', file_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")



func _on_scenes_index_pressed(index):
	var id = %ScenesMenuBar/Scenes.get_item_text(index)
	print('POPUP INDEX: ', index, id)
	# load scene
	for n in %MyScene.get_children(): n.queue_free()
	current_scene = load(my_scenes[id])
	scene_instance = current_scene.instantiate()
	%MyScene.call_deferred("add_child", scene_instance)
	# set label name
	%SelectedSceneLabel.text = scene_instance.name
	


func _on_render_button_pressed() -> void:
	if current_scene:
		%PanoramaMaker.save_file_name = scene_instance.name
		if %PanoramaMaker.save_file_name: 
			var output_file = await %PanoramaMaker.save_panorama()
			var message:String = "Saved: {filename}".format({"filename": output_file})
			%MessageLabel.text = message
			%NotificationWindow.show()
			print('SAVING: ', %PanoramaMaker.save_file_name)


func _on_popup_popup_hide() -> void:
	%MessageLabel.text = ''
	%ErrorLabel.text = ''


func _on_notification_window_close_requested() -> void:
	%MessageLabel.text = ''
	%ErrorLabel.text = ''
	%NotificationWindow.hide()


func _on_notification_window_focus_exited() -> void:
	%MessageLabel.text = ''
	%ErrorLabel.text = ''
	%NotificationWindow.hide()
