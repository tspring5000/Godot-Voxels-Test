extends Node3D
var rng = RandomNumberGenerator.new()

func init_trees():
	rng.randomize()

# Generates a tree dictionary which can be passed into add_voxel_set()
func create_tree(
	start: Vector3,
	voxel_size: float = 1.0,
	min_size: int = 4,
	max_size: int = 8,
	trunk_col: Color = Color.BROWN,
	leaf_col: Color = Color.GREEN
) -> Dictionary:
	var result = {}
	var height = rng.randi_range(min_size, max_size)
	
	# Create trunk
	var last_pos = start
	for _i in range(height):
		last_pos.y += voxel_size
		result[last_pos] = trunk_col
	
	# Create leaves
	result[last_pos + Vector3(1, 0, 0)] = leaf_col
	result[last_pos - Vector3(1, 0, 0)] = leaf_col
	result[last_pos + Vector3(0, 0, 1)] = leaf_col
	result[last_pos - Vector3(0, 0, 1)] = leaf_col
	result[last_pos + Vector3(0, 1, 0)] = leaf_col
	
	return result
