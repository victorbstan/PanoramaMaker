extends Node3D

var my_root = "res://my_scenes/"
var my_scenes:Dictionary = {}
var my_renders_root = "res://panoramas/"
var my_renders:Dictionary = {}
var current_scene:PackedScene
var scene_instance:Node
var save_skybox:bool = false

var loading:bool = false
var loading_status:int
var progress:Array[float]
var path_to_load:String


# Called when the node enters the scene tree for the first time.
func _ready():
	%ErrorLabel.text = ''
	update_scened_menu()
	update_renders_menu()
	

func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"): get_tree().quit()


func _process(delta: float) -> void:
	if loading: process_loading()
	else:
		%ProgressBar.visible = false
		%ProgressBar.value = 0


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


func fetch_scenes_from_dir(path:String):
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


# NOTE: File access could be refactored into something more modular, but it's "only" two copies ATM...
func fetch_renders_from_dir(path:String):
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


func preview_panorama_image(path:String) -> void:
	# Hide these for performance reasons
	%PanoramaMaker.visible = false
	%MyScene.visible = false
	get_tree().paused = true
	# load image into panorama viwer, displayed in message popup
	var image := Image.load_from_file(path)
	var selected_render:Texture2D = ImageTexture.create_from_image(image)
	%PanoramaViewer.panorama = selected_render
	%PanoramaViewer.setup()


func process_loading():
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(path_to_load, progress)
	print('LOADING A : ', loading_status)
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print('LOADING B : ', progress[0])
			%ProgressBar.visible = true
			%ProgressBar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED:
			print('LOADING C : ', progress[0])
			# When done loading, change to the target scene:
			current_scene = ResourceLoader.load_threaded_get(path_to_load)
			add_loaded_scene(current_scene)
			%ProgressBar.visible = false
			loading = false
		ResourceLoader.THREAD_LOAD_FAILED:
			# Well some error happend:
			print("Error. Could not load Resource")
			%ProgressBar.visible = false
			loading = false
	print('LOADING D : ', progress[0])


func add_loaded_scene(current_scene:Resource):
	scene_instance = current_scene.instantiate()
	%MyScene.call_deferred('add_child', scene_instance)
	# enable render button
	%RenderButton.disabled = false
	# set filename text
	%SceneFileName.text = scene_instance.name
	# update default settings from ui widgets
	%PanoramaMaker.capture_resolution = str(%CaptureResolutionOptions.get_selected_id())
	%PanoramaMaker.output_resolution = str(%OutputResolutionOptions.get_selected_id())
	%PanoramaMaker.texture_filter = %TextureFilterOptions.get_item_text(%TextureFilterOptions.get_selected_id())
	%PanoramaMaker.display()


#
# EVENTS
#

func _on_scenes_index_pressed(index):
	var id = %ScenesMenuBar/Scenes.get_item_text(index)
	path_to_load = my_scenes[id]
	print('POPUP INDEX: ', index, ' - ', id)
	# load scene
	for n in %MyScene.get_children(): n.queue_free()
	# path: String, type_hint: String = "", use_sub_threads: bool = false, cache_mode: CacheMode = 1
	ResourceLoader.load_threaded_request(path_to_load, "PackedScene", true)
	loading = true


func _on_renders_index_pressed(index: int) -> void:
	var id = %RendersMenuBar/Renders.get_item_text(index)
	print('RENDERS INDEX: ', index, ' - ', id)
	%NotificationWindow.title = "Preview: {filename}".format({"filename": my_renders[id]})
	%NotificationWindow.show()
	preview_panorama_image(my_renders[id])


func _on_render_button_pressed() -> void:
	if not current_scene: return
	%PanoramaMaker.setup()
	print('RENDER SETTINGS APPLIED: ', %PanoramaMaker.capture_resolution, ' ', %PanoramaMaker.output_resolution, ' ', %PanoramaMaker.texture_filter, ' ', %PanoramaMaker.antialias_msaa)
	%PanoramaMaker.save_file_name = %SceneFileName.text
	if %PanoramaMaker.save_file_name:
		print('SAVING: ', %PanoramaMaker.save_file_name)
		var output_file:String = await %PanoramaMaker.save_panorama()
		var message:String = "Saved: {filename}".format({"filename": output_file})
		# save skybox
		if save_skybox: await %PanoramaMaker.save_skybox()
		# Show preview popup
		%NotificationWindow.title = message
		%NotificationWindow.show()
		preview_panorama_image(output_file)


func _on_notification_window_close_requested() -> void:
	%ErrorLabel.text = ''
	%NotificationWindow.hide()
	# show main content after modal close
	%PanoramaMaker.visible = true
	%MyScene.visible = true
	get_tree().paused = false


func _on_notification_window_focus_exited() -> void:
	%ErrorLabel.text = ''
	%NotificationWindow.hide()
	# show main content after modal close
	%PanoramaMaker.visible = true
	%MyScene.visible = true
	get_tree().paused = false


func _on_antialias_check_box_toggled(toggled_on: bool) -> void:
	print('ANTIALIAS CHOICE: ', toggled_on)
	%PanoramaMaker.antialias_msaa = toggled_on
	%PanoramaMaker.setup()


func _on_scenes_about_to_popup() -> void:
	update_scened_menu()


func _on_renders_about_to_popup() -> void:
	update_renders_menu()


func _on_capture_resolution_options_item_selected(index: int) -> void:
	#@export_enum("256", "512", "1024", "2048", "4096") var capture_resolution:String = "1024"
	var selection:String = str(%CaptureResolutionOptions.get_selected_id())
	print('CAPTURE RES. OPTION: ', index, ' - ', selection)
	%PanoramaMaker.capture_resolution = selection
	%PanoramaMaker.setup()


func _on_output_resolution_options_item_selected(index: int) -> void:
	#@export_enum("512", "1024", "2048", "4096", "8192") var output_resolution:String = "2048"
	var selection:String = str(%OutputResolutionOptions.get_selected_id())
	print('OUTPUT RES. OPTION: ', index, ' - ', selection)
	%PanoramaMaker.output_resolution = selection
	%PanoramaMaker.setup()


func _on_texture_filter_options_item_selected(index: int) -> void:
	# "linear" or "nearest"
	var selection:String = %TextureFilterOptions.get_item_text(%TextureFilterOptions.get_selected_id())
	print('FILTER OPTION: ', index, ' - ', selection)
	%PanoramaMaker.texture_filter = selection
	%PanoramaMaker.setup()


func _on_skybox_check_box_toggled(toggled_on: bool) -> void:
	print('SKYBOX: ', toggled_on)
	save_skybox = toggled_on
