extends Node3D
var voxels = {}
var voxel_size = 1.0
var default_mat = StandardMaterial3D.new()
var surface_tool = SurfaceTool.new()

# Vertices of a cube
const vertices = [
	Vector3(0,0,0), Vector3(1,0,0),
	Vector3(1,0,1), Vector3(0,0,1),
	Vector3(0,1,0), Vector3(1,1,0),
	Vector3(1,1,1), Vector3(0,1,1),
]

# ----- PRIVATE -----
func _create_voxel(color, pos):
	var left = voxels.get(pos - Vector3(1, 0, 0)) == null
	var right = voxels.get(pos + Vector3(1, 0, 0)) == null
	var back = voxels.get(pos - Vector3(0, 0, 1)) == null
	var front = voxels.get(pos + Vector3(0, 0, 1)) == null 
	var bottom = voxels.get(pos - Vector3(0, 1, 0)) == null
	var top = voxels.get(pos + Vector3(0, 1, 0)) == null
	
	if(!left and !right and !top and !bottom and !front and !back):
		return	# Block completely hidden
	
	surface_tool.set_color(color)
	
	if top:
		surface_tool.set_normal(Vector3(0, -1, 0))
		surface_tool.add_vertex((vertices[4] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[7] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[6] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[7] + pos) * voxel_size)
	if right:
		surface_tool.set_normal(Vector3(1, 0, 0))
		surface_tool.add_vertex((vertices[2] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[1] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[2] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[6] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
	if left:
		surface_tool.set_normal(Vector3(-1, 0, 0))
		surface_tool.add_vertex((vertices[0] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[7] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[3] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[0] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[4] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[7] + pos) * voxel_size)
	if front:
		surface_tool.set_normal(Vector3(0, 0, 1))
		surface_tool.add_vertex((vertices[6] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[2] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[3] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[3] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[7] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[6] + pos) * voxel_size)
	if back:
		surface_tool.set_normal(Vector3(0, 0, -1))
		surface_tool.add_vertex((vertices[0] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[1] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[5] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[4] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[0] + pos) * voxel_size)
	if bottom:
		surface_tool.set_normal(Vector3(0, 1, 0))
		surface_tool.add_vertex((vertices[1] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[3] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[2] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[1] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[0] + pos) * voxel_size)
		surface_tool.add_vertex((vertices[3] + pos) * voxel_size)


# ----- PUBLIC -----
func init_mesh(size: float = 1.0):
	voxels = {}
	surface_tool = SurfaceTool.new()
	default_mat = StandardMaterial3D.new()
	
	voxel_size = size
	default_mat.vertex_color_use_as_albedo = true
	default_mat.vertex_color_is_srgb = true
	surface_tool.set_material(default_mat)

func add_voxel(pos: Vector3, col: Color):
	voxels[pos] = col

func add_voxel_set(voxelset: Dictionary):
	for key in voxelset:
		add_voxel(key, voxelset[key])

func create_mesh(collision: bool = true) -> MeshInstance3D:
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for vox in voxels:
		_create_voxel(voxels[vox], vox)
	
	surface_tool.index()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.material_override = default_mat
	
	surface_tool.clear()
	
	if(collision):
		mesh_instance.create_trimesh_collision()
	
	return mesh_instance
