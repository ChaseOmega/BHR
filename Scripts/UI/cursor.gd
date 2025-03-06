# Player-controlled cursor. Allows them to navigate the game grid, select units, and move them.
# Supports both keyboard and mouse (or touch) input.
# The `tool` mode allows us to preview the drawing code you'll see below in the editor.
@tool
class_name Cursor
extends Node2D

@export var map: TileMapLayer
@export var ui_cooldown := 0.1

# Coordinates of the current cell the cursor is hovering.
var cell := Vector2.ZERO :
	get:
		return cell
	set(value):
		cell = value

var is_selected := false :
	get:
		return is_selected
	set(value):
		is_selected = value

# We use the timer to have a cooldown on the cursor movement.
@onready var _timer: Timer = $Timer
@onready var Sprite: Sprite2D = $Sprite2D


# When the cursor enters the scene tree, we snap its position to the centre of the cell and we
# initialise the timer with our ui_cooldown variable.
func _ready() -> void:
	map = get_node("../TileMapLayer")
	_timer.wait_time = ui_cooldown
	Sprite.scale = Vector2(float(map.tile_set.tile_size.x)/Sprite.texture.get_width(),float(map.tile_set.tile_size.y)/Sprite.texture.get_height())


func _unhandled_input(event: InputEvent) -> void:
	# If the user moves the mouse, we capture that input and update the node's cell in priority.
	if event is InputEventMouseMotion:
		set_cell(map.local_to_map(get_global_mouse_position()))
		print(cell)
	# If we are already hovering the cell and click on it, or we press the enter key, the player
	# wants to interact with that cell.
	elif event.is_action_pressed("ui_accept"):
		#  In that case, we emit a signal to let another node handle that input. The game board will
		#  have the responsibility of looking at the cell's content.
		SignalManager.selectCell.emit(cell)
		get_viewport().set_input_as_handled()

	# The code below is for the cursor's movement.
	# The following lines make some preliminary checks to see whether the cursor should move or not
	# if the user presses an arrow key.
	var should_move := event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return

	# Here, we update the cursor's current cell based on the input direction. See the set_cell()
	# function below to see what changes that triggers.
	if event.is_action("ui_right"):
		set_cell(self.cell + Vector2.RIGHT)
	elif event.is_action("ui_up"):
		set_cell(self.cell + Vector2.UP)
	elif event.is_action("ui_left"):
		set_cell(self.cell + Vector2.LEFT)
	elif event.is_action("ui_down"):
		set_cell(self.cell + Vector2.DOWN)

# This function controls the cursor's current position.
func set_cell(value: Vector2) -> void:
	# We first clamp the cell coordinates and ensure that we weren't trying to move outside the
	# grid's boundaries.
	var new_cell: Vector2 = value
	if new_cell.is_equal_approx(cell):
		return

	cell = new_cell
	# If we move to a new cell, we update the cursor's position, emit a signal, and start the
	# cooldown timer that will limit the rate at which the cursor moves when we keep the direction
	# key down.
	position = map.map_to_local(cell)
	SignalManager.moved.emit(cell)
	_timer.start()
