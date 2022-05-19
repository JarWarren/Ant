extends TileMap

enum BRUSH {ANT, PHEROMONE}
enum ROTATION {
	UP = 2,
	RIGHT = 3,
	DOWN = 4,
	LEFT = 5
	}

const HEIGHT = 38
const WIDTH = 64
const TILE_SIZE = 16

@onready var brushes: ItemList = $CanvasLayer/ItemList
@onready var rotation_texture = $CanvasLayer/TextureRect
@onready var simulate_checkbox = $CanvasLayer/CheckBox
@onready var speed_slider = $CanvasLayer/HBoxContainer/VBoxContainer/HSlider

var ants = []
var brush = BRUSH.ANT
var brush_rotation = ROTATION.UP
var generation_number = 0
var is_simulating = false
var population = 0
var rotations = []
var time = 0

func _ready():
	# time = speed_slider.value
	brushes.select(brush)
	for row in range(HEIGHT):
		for column in range(WIDTH):
			_set_tile(Vector2(column, row), 0)


func _process(_delta):
	if Input.is_action_just_pressed("click"):
		var click_coordinate = (get_global_mouse_position() / TILE_SIZE).floor()
		var id = get_cell_source_id(0, click_coordinate, false)
		match brush:
			BRUSH.ANT:
				_set_ant(click_coordinate, brush_rotation)
			BRUSH.PHEROMONE:
				_set_tile(click_coordinate, 1 - id)
	if Input.is_action_just_pressed("ant"):
		brush = BRUSH.ANT
		brushes.select(brush)
	if Input.is_action_just_pressed("tile"):
		brush = BRUSH.PHEROMONE
		brushes.select(brush)
	if Input.is_action_just_pressed("simulate"):
		is_simulating = !is_simulating
		simulate_checkbox.button_pressed = is_simulating
	if Input.is_action_just_pressed("rotate"):
		var raw_value = int(brush_rotation)
		brush_rotation = raw_value + 1
		if brush_rotation >= 6:
			brush_rotation = 2
		match brush_rotation:
			ROTATION.UP:
				rotation_texture.texture = load("res://ant.PNG")
			ROTATION.RIGHT:
				rotation_texture.texture = load("res://right.PNG")
			ROTATION.DOWN:
				rotation_texture.texture = load("res://down.PNG")
			ROTATION.LEFT:
				rotation_texture.texture = load("res://left.PNG")
	if Input.is_action_just_pressed("reset"):
		_reset_board()
	if is_simulating:
		# time -= 1
		# if time <= 0:
			# time = speed_slider.value
		for i in range(ants.size() - 1):
			_move_ant(i)
		if ants.size() == 1:
			_move_ant(0)


func _move_ant(index: int):
	if index >= ants.size(): return
	var ant = ants[index]
	var ant_rotation = rotations[index]
	_set_tile(ant, 1 - get_cell_source_id(0, ant, false))
	_set_ant(ant)
	match ant_rotation:
		ROTATION.UP:
			ant.y -= 1
			ant_rotation = ROTATION.RIGHT if get_cell_source_id(0, ant, false) == 0 else ROTATION.LEFT
		ROTATION.RIGHT:
			ant.x += 1
			ant_rotation = ROTATION.DOWN if get_cell_source_id(0, ant, false) == 0 else ROTATION.UP
		ROTATION.DOWN:
			ant.y += 1
			ant_rotation = ROTATION.LEFT if get_cell_source_id(0, ant, false) == 0 else ROTATION.RIGHT
		ROTATION.LEFT:
			ant.x -= 1
			ant_rotation = ROTATION.UP if get_cell_source_id(0, ant, false) == 0 else ROTATION.DOWN
	_set_ant(ant, ant_rotation)


func _set_tile(coordinate: Vector2, id: int):
	set_cell(0, coordinate, id, Vector2.ZERO, 0)


func _set_ant(coordinate: Vector2, ant_rotation: ROTATION = ROTATION.UP):
	if coordinate in ants:
		erase_cell(1, coordinate)
		var index = ants.find(coordinate)
		ants.remove_at(index)
		rotations.remove_at(index)
	else:
		set_cell(1, coordinate, ant_rotation, Vector2.ZERO, 0)
		ants.append(coordinate)
		rotations.append(ant_rotation)


func _reset_board():
	is_simulating = false
	simulate_checkbox.button_pressed = false
	for row in range(HEIGHT):
		for column in range(WIDTH):
			_set_tile(Vector2(column, row), 0)
	for ant in ants:
		erase_cell(1, ant)
		rotations = []
		ants = []
