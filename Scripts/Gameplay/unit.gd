class_name Unit
extends Path2D

signal walk_finished

@export var map: TileMapLayer
@export var skin: Texture:
	get:
		return skin
	set(value):
		skin = value
@export var move_range := 6
@export var skin_offset := Vector2.ZERO :
	get:
		return skin_offset
	set(value):
		skin_offset = value
@export var move_speed := 6.0
@export var cell := Vector2i.ZERO :
	get:
		return cell
	set(value):
		cell = value
var is_selected := false :
	get:
		return is_selected
	set(value):
		is_selected = value
var _is_walking := false :
	get:
		return _is_walking
	set(value):
		_is_walking = value
@export var _sprite: Sprite2D
@export var _anim_player: AnimationPlayer
@export var _path_follow: PathFollow2D
@export var player: int


func _ready() -> void:
	map = get_node("../TileMapLayer")
	set_process(false)

	self.cell = map.local_to_map(position)
	position = map.map_to_local(cell)
	curve = Curve2D.new()



func _process(delta: float) -> void:
	_path_follow.progress = _path_follow.progress + (move_speed * delta)

	if _path_follow.progress_ratio >= 1.0 || curve.point_count == 1:
		_set_is_walking(false)
		_path_follow.progress = 0.0
		position = map.map_to_local(cell)
		curve.clear_points()
		walk_finished.emit()
		_anim_player.play("Idle")


func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		position = map.map_to_local(cell)
		return

	for point in path:
		curve.add_point(Vector2((map.map_to_local(point))) - position)
	cell = path[-1]
	_set_is_walking(true)


func set_cell(value: Vector2) -> void:
	cell = Vector2i(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("Glow")
	else:
		_anim_player.play("Idle")


func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		await ready
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		await ready
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)
