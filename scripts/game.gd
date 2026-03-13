extends Node2D

onready var fruits = get_node("Fruits")

var pineapple = preload("res://scenes/Pineapple.tscn")
var watermelon = preload("res://scenes/Watermelon.tscn")
var pear = preload("res://scenes/Pear.tscn")
var orange = preload("res://scenes/Orange.tscn")
var avocado = preload("res://scenes/Avocado.tscn")
var lemon = preload("res://scenes/Lemon.tscn")
var tomato = preload("res://scenes/Tomato.tscn")
var banana = preload("res://scenes/Banana.tscn")

var bomb = preload("res://scenes/Bomb.tscn")

var scores = [0, 0, 0]
var screen_width = 0
var screen_height = 0

var game_time = 45.0
var is_game_over = false

var lane_colors = [
	Color(0.3, 0.5, 1.0, 0.15),
	Color(0.6, 0.85, 1.0, 0.15),
	Color(1.0, 1.0, 1.0, 0.15)
]

func _ready():
	screen_width = get_viewport_rect().size.x
	screen_height = get_viewport_rect().size.y
	update()
	
	if has_node("Control/TimeLabel"):
		get_node("Control/TimeLabel").add_color_override("font_color", Color("#ffc629"))
		
	for i in range(1, 4):
		var lbl = "Control/Label" + str(i)
		if has_node(lbl):
			var node = get_node(lbl)
			node.add_color_override("font_color", Color("#ffc629"))
			node.rect_scale = Vector2(1.5, 1.5)
			node.set_text("$0")

func _draw():
	var lane_width = screen_width / 3.0
	for i in range(3):
		var rect = Rect2(i * lane_width, 0, lane_width, screen_height)
		draw_rect(rect, lane_colors[i])
	
	draw_line(Vector2(lane_width, 0), Vector2(lane_width, screen_height), Color(1, 1, 1), 5)
	draw_line(Vector2(lane_width * 2, 0), Vector2(lane_width * 2, screen_height), Color(1, 1, 1), 5)

func _process(delta):
	if is_game_over: return
	
	game_time -= delta
	
	if has_node("Control/TimeLabel"):
		var time_label = get_node("Control/TimeLabel")
		time_label.set_text("Tiempo: " + str(int(game_time)))
		
		if game_time <= 10.0 and game_time > 0:
			time_label.add_color_override("font_color", Color("#8a2432"))
			time_label.rect_pivot_offset = time_label.rect_size / 2.0
			var pulse = 0.7 + abs(sin(game_time * PI)) * 0.3
			time_label.rect_scale = Vector2(pulse, pulse)
		else:
			time_label.add_color_override("font_color", Color("#ffc629"))
			time_label.rect_scale = Vector2(0.7, 0.7)
			
	if game_time <= 0:
		game_time = 0
		if has_node("Control/TimeLabel"):
			get_node("Control/TimeLabel").rect_scale = Vector2(0.7, 0.7)
		trigger_game_over()

func _on_Generator_timeout():
	if is_game_over: return
	
	for i in range(0, int(rand_range(10, 18))):
		var type = int(rand_range(0, 9))
		var obj
		match type:
			0: obj = pineapple.instance()
			1: obj = watermelon.instance()
			2: obj = pear.instance()
			3: obj = orange.instance()
			4: obj = avocado.instance()
			5: obj = lemon.instance()
			6: obj = tomato.instance()
			7: obj = banana.instance()
			8: obj = bomb.instance()
			
		var lane_width = screen_width / 3.0
		var lane_index = i % 3
		var min_x = (lane_index * lane_width) + 100
		var max_x = ((lane_index + 1) * lane_width) - 100
		var spawn_x = rand_range(min_x, max_x)
		
		obj.generate(Vector2(spawn_x, screen_height))
		
		var points = 1
		obj.linear_velocity *= 0.75
		
		if type == 0:
			obj.linear_velocity *= 1.5
			points = 5
		
		if type != 8:
			obj.connect("score", self, "inc_score", [points])
		else:
			obj.connect("explode_bomb", self, "penalize_all_players")
		
		fruits.add_child(obj)

func trigger_game_over():
	is_game_over = true
	get_node("InputProcessor").gameOver = true
	get_node("GameOverScreen").start(scores)

func inc_score(cut_x_position, points_earned):
	if is_game_over: return
	
	var lane_width = screen_width / 3.0
	var player_index = int(cut_x_position / lane_width)
	player_index = clamp(player_index, 0, 2) 
	
	scores[player_index] += points_earned
	
	var label_name = "Control/Label" + str(player_index + 1)
	if has_node(label_name):
		get_node(label_name).set_text("$" + str(scores[player_index]))

func penalize_all_players():
	if is_game_over: return
	for i in range(3):
		scores[i] = max(0, scores[i] - 1) 
		var label_name = "Control/Label" + str(i + 1)
		if has_node(label_name):
			get_node(label_name).set_text("$" + str(scores[i]))
