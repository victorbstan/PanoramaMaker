extends MeshInstance3D

var fnl = FastNoiseLite.new()
var mdt = MeshDataTool.new()

func _ready():
	fnl.frequency = 0.7

	mdt.create_from_surface(mesh, 0)

	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i).normalized()
		# Push out vertex by noise.
		vertex = vertex * (fnl.get_noise_3dv(vertex) * 0.5 + 0.75)
		mdt.set_vertex(i, vertex)

	# Calculate vertex normals, face-by-face.
	for i in range(mdt.get_face_count()):
		# Get the index in the vertex array.
		var a = mdt.get_face_vertex(i, 0)
		var b = mdt.get_face_vertex(i, 1)
		var c = mdt.get_face_vertex(i, 2)
		# Get vertex position using vertex index.
		var ap = mdt.get_vertex(a)
		var bp = mdt.get_vertex(b)
		var cp = mdt.get_vertex(c)
		# Calculate face normal.
		var n = (bp - cp).cross(ap - bp).normalized()
		# Add face normal to current vertex normal.
		# This will not result in perfect normals, but it will be close.
		mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))

	# Run through vertices one last time to normalize normals and
	# set color to normal.
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex_normal(i).normalized()
		mdt.set_vertex_normal(i, v)
		mdt.set_vertex_color(i, Color(v.x, v.y, v.z))

	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
