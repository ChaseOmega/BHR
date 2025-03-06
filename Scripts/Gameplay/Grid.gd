class_name Grid
extends Resource

# The grid's size in rows and columns.
@export var size := Vector2(20, 20)
# The size of a cell in pixels.
@export var cell_size := Vector2(80, 80)
	
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < size.y
	
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out

func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
