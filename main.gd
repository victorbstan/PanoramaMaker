extends Node3D

var my_root = "res://my_scenes/"
var my_scenes:Dictionary = {}
var my_renders_root = "res://panoramas/"
var my_renders:Dictionary = {}
var current_scene:PackedScene
var scene_instance:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	%ErrorLabel.text = ''
	update_scened_menu()
	update_renders_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"): get_tree().quit()


func update_scened_menu():
	# get list of available scenes for menu options
	fetch_scenes_from_dir(my_root)
	%ScenesMenuBar/Scenes.clear()
	for scene_name in my_scenes.keys():
		%ScenesMenuBar/Scenes.add_item(scene_name)
	

func update_renders_menu():
	# get list of available rendered images for menu options
	fetch_renders_from_dir(my_renders_root)
	%RendersMenuBar/Renders.clear()
	for render_name in my_renders.keys():
		%RendersMenuBar/Renders.add_item(render_name)


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

# NOTE: File access could be refactored into something more modular, but it's "only" two copies ATM...
func fetch_renders_from_dir(path):
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
				if file_name.ends_with('.png'):
					# Add to list of valid scenes to load
					var file_path:String = dir.get_current_dir() + '/' + file_name
					my_renders[file_name] = file_path
					print('Full file path: ', file_path)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

#
# EVENTS
#

func _on_scenes_index_pressed(index):
	var id = %ScenesMenuBar/Scenes.get_item_text(index)
	print('POPUP INDEX: ', index, ' - ', id)
	# load scene
	for n in %MyScene.get_children(): n.queue_free()
	current_scene = load(my_scenes[id])
	scene_instance = current_scene.instantiate()
	%MyScene.call_deferred("add_child", scene_instance)
	# set label name
	%SelectedSceneLabel.text = scene_instance.name
	# enable render button
	%RenderButton.disabled = false
	# set filename text
	%SceneFileName.text = scene_instance.name


func _on_renders_index_pressed(index: int) -> void:
	var id = %RendersMenuBar/Renders.get_item_text(index)
	print('RENDERS INDEX: ', index, ' - ', id)
	var selected_render:Resource = load(my_renders[id])
	%NotificationWindow.title = "Preview: {filename}".format({"filename": my_renders[id]}) 
	%NotificationWindow.show()
	# load image into panorama viwer, displayed in message popup
	%PanoramaViewer.panorama = selected_render
	%PanoramaViewer.setup()


func _on_render_button_pressed() -> void:
	if not current_scene: return
	%PanoramaMaker.setup()
	print('RENDER SETTINGS APPLIED: ', %PanoramaMaker.capture_resolution, ' ', %PanoramaMaker.output_resolution, ' ', %PanoramaMaker.texture_filter, ' ', %PanoramaMaker.antialias_msaa)
	%PanoramaMaker.save_file_name = %SceneFileName.text
	if %PanoramaMaker.save_file_name:
		print('SAVING: ', %PanoramaMaker.save_file_name)
		var output_file:String = await %PanoramaMaker.save_panorama()
		var message:String = "Saved: {filename}".format({"filename": output_file})
		# Show preview popup
		%NotificationWindow.title = message
		%NotificationWindow.show()
		# load image into panorama viwer, displayed in popup
		%PanoramaViewer.panorama = await load(output_file)
		%PanoramaViewer.setup()


func _on_popup_popup_hide() -> void:
	%ErrorLabel.text = ''


func _on_notification_window_close_requested() -> void:
	%ErrorLabel.text = ''
	%NotificationWindow.hide()


func _on_notification_window_focus_exited() -> void:
	%ErrorLabel.text = ''
	%NotificationWindow.hide()


func _on_capture_resolution_index_pressed(index: int) -> void:
	var selection = %CaptureResolutionMenuBar/"Capture Resolution".get_item_text(index)
	print('CAPTURE RES. CHOICE: ', index, ' - ', selection)
	%PanoramaMaker.capture_resolution = selection
	%PanoramaMaker.setup()


func _on_output_resolution_index_pressed(index: int) -> void:
	var selection = %OutputResolutionMenuBar/"Output Resolution".get_item_text(index)
	print('OUTPUT RES. CHOICE: ', index, ' - ', selection)
	%PanoramaMaker.output_resolution = selection
	%PanoramaMaker.setup()


func _on_texture_filter_index_pressed(index: int) -> void:
	var selection = %FilterMenuBar/"Texture Filter".get_item_text(index)
	print('FILTER CHOICE: ', index, ' - ', selection)
	%PanoramaMaker.texture_filter = selection
	%PanoramaMaker.setup()


func _on_antialias_check_box_toggled(toggled_on: bool) -> void:
	print('ANTIALIAS CHOICE: ', toggled_on)
	%PanoramaMaker.antialias_msaa = toggled_on
	%PanoramaMaker.setup()


func _on_scenes_about_to_popup() -> void:
	update_scened_menu()


func _on_renders_about_to_popup() -> void:
	update_renders_menu()
