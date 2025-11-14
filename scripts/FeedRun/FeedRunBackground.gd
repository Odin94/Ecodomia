extends Node2D

const TILE_SIZE = 32
const GRID_WIDTH = 11
const GRID_HEIGHT = 32
const SCROLL_SPEED = 100.0

const GROUND_TILE_SCENE = preload("res://scenes/FeedRun/GroundTile.tscn")
const SPRITESHEET_PATH = "res://assets/tiles/pyxel_map.png"

const GRASS_COORDS = Vector2(0, 0)
const WEEDS_COORDS = Vector2(5, 1)
const FLOWERS_COORDS = Vector2(6, 1)
const GRASS_LEFT_DIRT_COORDS = Vector2(2, 2)
const GRASS_RIGHT_DIRT_COORDS = Vector2(0, 2)

onready var tile_container := $GroundTiles
onready var spritesheet_texture := load(SPRITESHEET_PATH) as Texture
var sprite_regions := []
var random_sprite_regions := []
var grass_left_dirt_texture: AtlasTexture
var grass_right_dirt_texture: AtlasTexture
var tiles := []
var scroll_offset: float = 0.0
var initial_y_offset: float = 0.0
var should_scroll := true

func _ready():
	load_spritesheet()
	create_initial_grid()

func load_spritesheet():
	var sheet_width = spritesheet_texture.get_width()
	var sheet_height = spritesheet_texture.get_height()
	var sprites_per_row = sheet_width / TILE_SIZE
	var sprites_per_col = sheet_height / TILE_SIZE
	
	for y in range(sprites_per_col):
		for x in range(sprites_per_row):
			var atlas = AtlasTexture.new()
			atlas.atlas = spritesheet_texture
			atlas.region = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			sprite_regions.append(atlas)
	
	grass_left_dirt_texture = get_sprite_at_coords(GRASS_LEFT_DIRT_COORDS)
	grass_right_dirt_texture = get_sprite_at_coords(GRASS_RIGHT_DIRT_COORDS)
	
	var grass_texture = get_sprite_at_coords(GRASS_COORDS)
	var weeds_texture = get_sprite_at_coords(WEEDS_COORDS)
	var flowers_texture = get_sprite_at_coords(FLOWERS_COORDS)
	
	random_sprite_regions = []
	# Appending multiple times to make it more likely to get grass
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(grass_texture)
	random_sprite_regions.append(weeds_texture)
	random_sprite_regions.append(flowers_texture)
	
	if random_sprite_regions.empty():
		push_error("No random sprite regions loaded")
	
	if sprite_regions.empty():
		push_error("No sprite regions loaded")

func get_sprite_at_coords(coords: Vector2) -> AtlasTexture:
	var sprites_per_row = int(spritesheet_texture.get_width() / TILE_SIZE)
	var index = int(coords.y) * sprites_per_row + int(coords.x)
	if index >= 0 and index < sprite_regions.size():
		return sprite_regions[index]
	push_error("Invalid sprite coordinates: " + str(coords))
	return null

func create_initial_grid():
	initial_y_offset = -32
	
	for row in range(GRID_HEIGHT):
		var row_tiles = []
		for col in range(GRID_WIDTH):
			var tile = GROUND_TILE_SCENE.instance()
			var sprite = tile.get_node("Sprite")
			
			if col == 0:
				sprite.texture = grass_left_dirt_texture
			elif col == GRID_WIDTH - 1:
				sprite.texture = grass_right_dirt_texture
			else:
				sprite.texture = random_sprite_regions[randi() % random_sprite_regions.size()]
			
			var x_pos = (col - GRID_WIDTH / 2.0 + 0.5) * TILE_SIZE
			var y_pos = row * TILE_SIZE + initial_y_offset
			tile.position = Vector2(x_pos, y_pos)
			
			tile_container.add_child(tile)
			row_tiles.append(tile)
		tiles.append(row_tiles)

func _process(delta):
	if not should_scroll:
		return
	
	scroll_offset += SCROLL_SPEED * delta
	
	# TODOdin: Review this remove logic
	var tiles_to_remove = int(scroll_offset / TILE_SIZE)
	
	if tiles_to_remove > 0:
		remove_bottom_tiles(tiles_to_remove)
		add_top_tiles(tiles_to_remove)
		scroll_offset = fmod(scroll_offset, TILE_SIZE)
	
	update_tile_positions()

func remove_bottom_tiles(count):
	for _i in range(min(count, tiles.size())):
		if tiles.size() > 0:
			var row = tiles.pop_back()
			for tile in row:
				tile.queue_free()

func add_top_tiles(count):
	for _i in range(count):
		var row_tiles = []
		for col in range(GRID_WIDTH):
			var tile = GROUND_TILE_SCENE.instance()
			var sprite = tile.get_node("Sprite")
			
			if col == 0:
				sprite.texture = grass_left_dirt_texture
			elif col == GRID_WIDTH - 1:
				sprite.texture = grass_right_dirt_texture
			else:
				sprite.texture = random_sprite_regions[randi() % random_sprite_regions.size()]
			
			tile_container.add_child(tile)
			row_tiles.append(tile)
		tiles.push_front(row_tiles)

func set_should_scroll(value: bool):
	should_scroll = value

func update_tile_positions():
	for row_idx in range(tiles.size()):
		var row = tiles[row_idx]
		for col_idx in range(row.size()):
			var tile = row[col_idx]
			var x_pos = (col_idx - GRID_WIDTH / 2.0 + 0.5) * TILE_SIZE
			var y_pos = initial_y_offset + row_idx * TILE_SIZE + scroll_offset
			tile.position = Vector2(x_pos, y_pos)
