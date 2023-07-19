extends Node3D
@export_group("Size")
@export var size : int = 128
@export var max_height : float = 20.0
@export_group("Height")
@export var noise : Noise
@export var height_mod : Curve
@export_group("Colours")
@export var palette : Gradient
@export_group("Trees")
@export_range(0, 1.0, 0.05) var tree_chance : float = 0.05
@export_range(0.0, 1.0, 0.05) var min_tree_height : float = 0.5
@export_range(0.0, 1.0, 0.05) var max_tree_height : float = 0.7
@export var trunk_col : Color = Color.BROWN
@export var leaf_col : Color = Color.GREEN
@onready var rng := RandomNumberGenerator.new()
var voxels : Dictionary = {}
var tree_positions : Array = []

func _ready():
	rng.randomize()
	noise.seed = rng.randi()
	generate_terrain()
	generate_trees()

func generate_terrain():
	VoxelTool.init_mesh()
	
	for x in range(size):
		for z in range(size):
			var value = noise.get_noise_2d(x, z)
			var output = (value + 1)/2
			var col = palette.sample(output)
			var height = height_mod.sample(output) * max_height
			_voxel_column(x, z, height, col)
			
			# Add trees
			if output > min_tree_height and output < max_tree_height:
				if tree_chance > rng.randf():
					tree_positions.append(Vector3(x, height - 2, z))
	
	VoxelTool.add_voxel_set(voxels)
	add_child(VoxelTool.create_mesh())

func _voxel_column(x, z, h, col):
	for i in range(h):
		voxels[Vector3(x, i, z)] = col

func generate_trees():
	VoxelTool.init_mesh()
	for pos in tree_positions:
		var tree = TreeTool.create_tree(
			pos,
			1.0,
			4, 8,
			trunk_col,
			leaf_col
		)
		VoxelTool.add_voxel_set(tree)
	add_child(VoxelTool.create_mesh(false))
