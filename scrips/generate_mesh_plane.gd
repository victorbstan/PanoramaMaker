@tool

extends MeshInstance3D

@export var update:bool = false
@export var heightmap:NoiseTexture2D
@export var max_height:float = 1
@export var offset_height:float = max_height / 2
# hack to refresh view
@export var vertex_vis:bool = false
@export var clear_ver_vis:bool = true
@export var save_mesh_on_update:bool = false
@export var mesh_name:String = "Terrain"
@export_dir var save_path:String = "res://assets/meshes/"

func _process(delta):
	if update:
		generate_mesh()
		update = false
		if save_mesh_on_update:
			save_mesh(mesh_name, mesh)

func generate_mesh():
	if clear_ver_vis:
		for i in get_children():
			i.free()

	var n_image = heightmap.get_image()
	var a_mesh:ArrayMesh
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var height = heightmap.height
	var width = heightmap.width
	for z in range(width):
		for x in range(height):
			var np = n_image.get_pixel(z, x)
			var y = np.get_luminance() * max_height + offset_height
			var vert = Vector3(x, y, z)
			# Prepare attributes for add_vertex.
			st.set_uv(Vector2(0, 0))
			st.set_color(np)
			# Call last for each vertex, adds the above attributes.
			st.add_vertex(vert)
			if vertex_vis: draw_sphere(vert, np)
	
	# make a quad
	for z in range(width - 1):
		for x in range(height - 1):
			var index0 = x + z * height
			var index1 = (x + 1) + z * height
			var index2 = x + (z + 1) * height
			var index3 = (x + 1) + (z + 1) * height
			# triangle 1
			st.add_index(index0)
			st.add_index(index1)
			st.add_index(index2)
			# triangle 2
			st.add_index(index1)
			st.add_index(index3)
			st.add_index(index2)

	# smooth surface normals
	st.generate_normals()
	st.generate_tangents()
	
	a_mesh = st.commit()
	mesh = a_mesh


func save_mesh(name:String, mesh:ArrayMesh):
	var resource_name:String = save_path+'/'+name+".tres"
	# Saves mesh to a .tres file with compression enabled.
	ResourceSaver.save(mesh, resource_name, ResourceSaver.FLAG_COMPRESS)


# for debuging view
func draw_sphere(pos:Vector3, color:Color):
	var ins = MeshInstance3D.new()
	ins.cast_shadow = false
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	sphere.material = mat
	ins.mesh = sphere
