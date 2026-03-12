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

var scores = [0, 0, 0, 0, 0]
var lives = 3 
var screen_width = 0
var screen_height = 0

# --- NUEVO: SISTEMA DE TIEMPO ---
var game_time = 90.0 # Tiempo de la partida en segundos (cámbialo al que quieras)
var is_game_over = false

# --- NUEVO: COLORES DE CARRILES ---
# Colores: Rojo, Azul, Verde, Amarillo, Morado. 
# El último valor (0.15) es la transparencia para que se vea el fondo.
var lane_colors = [
	Color(1, 0, 0, 0.15),
	Color(0, 0.5, 1, 0.15),
	Color(0, 1, 0, 0.15),
	Color(1, 1, 0, 0.15),
	Color(0.5, 0, 0.5, 0.15)
]

func _ready():
	screen_width = get_viewport_rect().size.x
	screen_height = get_viewport_rect().size.y
	# Llamamos a update() para que Godot ejecute la función _draw() una vez
	update()

# NUEVO: Dibuja los rectángulos de colores en el fondo
func _draw():
	var lane_width = screen_width / 5.0
	for i in range(5):
		var rect = Rect2(i * lane_width, 0, lane_width, screen_height)
		draw_rect(rect, lane_colors[i])

# NUEVO: Función que resta el tiempo cada frame
func _process(delta):
	if is_game_over: return
	
	game_time -= delta
	
	# Busca un Label llamado TimeLabel para mostrar el tiempo en pantalla
	if has_node("Control/TimeLabel"):
		get_node("Control/TimeLabel").set_text("Tiempo: " + str(int(game_time)))
		
	# Si el tiempo llega a cero, termina el juego
	if game_time <= 0:
		game_time = 0
		trigger_game_over()

func _on_Generator_timeout():
	if lives <= 0 or is_game_over: return
	
	for i in range(0, rand_range(1, 4)):
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
			
		# Aparecen justo debajo de la pantalla para que el salto sea natural
		obj.generate(Vector2(rand_range(100, screen_width - 100), screen_height + 50))
		
		if type != 8:
			obj.connect("score", self, "inc_score")
			obj.connect("life", self, "dec_life") 
		else:
			obj.connect("explode_bomb", self, "penalize_all_players")
		
		fruits.add_child(obj)

func dec_life():
	if is_game_over: return
	lives -= 1
	
	if lives == 2:
		get_node("Control/Bomb3").set_modulate(Color(1, 0 ,0))
	elif lives == 1:
		get_node("Control/Bomb2").set_modulate(Color(1, 0 ,0))
	elif lives == 0:
		get_node("Control/Bomb1").set_modulate(Color(1, 0 ,0))
		trigger_game_over()

# NUEVO: Centralizamos la lógica de fin de juego
func trigger_game_over():
	is_game_over = true
	get_node("InputProcessor").gameOver = true
	get_node("GameOverScreen").start()

func inc_score(cut_x_position):
	if lives <= 0 or is_game_over: return
	
	var lane_width = screen_width / 5.0
	var player_index = int(cut_x_position / lane_width)
	player_index = clamp(player_index, 0, 4) 
	
	scores[player_index] += 1
	
	var label_name = "Control/Label" + str(player_index + 1)
	if has_node(label_name):
		get_node(label_name).set_text(str(scores[player_index]))

func penalize_all_players():
	if is_game_over: return
	for i in range(5):
		scores[i] = max(0, scores[i] - 1) 
		var label_name = "Control/Label" + str(i + 1)
		if has_node(label_name):
			get_node(label_name).set_text(str(scores[i]))
