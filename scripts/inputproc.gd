extends Node2D

var touches = {} # Diccionario para rastrear el estado de múltiples dedos a la vez
var gameOver = false

func _ready():
	pass

func _input(event):
	event = make_input_local(event)
	
	if event is InputEventScreenTouch:
		if event.pressed:
			# Registramos un nuevo dedo en la pantalla usando su índice único
			touches[event.index] = {
				"prev": event.position,
				"curr": event.position,
				"active": false
			}
		else:
			# El dedo soltó la pantalla, lo eliminamos del estado
			if touches.has(event.index):
				touches.erase(event.index)
				update() # Forzamos borrado de la línea visual
				
	elif event is InputEventScreenDrag:
		if touches.has(event.index):
			touches[event.index].curr = event.position
			touches[event.index].active = true
			update()

func _physics_process(delta):
	if gameOver: return
	
	var space_state = get_world_2d().get_direct_space_state()
	
	# Procesamos el raycast para CADA dedo registrado
	for index in touches.keys():
		var t = touches[index]
		if t.active and t.curr != t.prev:
			var result = space_state.intersect_ray(t.prev, t.curr)
			if not result.empty():
				if result.collider.has_method("cut"):
					result.collider.cut()
			
			# Actualizamos la posición previa para el siguiente frame físico
			t.prev = t.curr

func _draw():
	if gameOver: return
	
	# Dibujamos una línea de corte independiente para cada dedo
	for index in touches.keys():
		var t = touches[index]
		if t.active and t.curr != t.prev:
			draw_line(t.curr, t.prev, Color(1, 0 ,0), 10)
