extends RigidBody2D

onready var shape = get_node("Shape")
onready var sprite = get_node("Sprite")
onready var anim = get_node("Animation")

signal explode_bomb # MODIFICADO: Nueva señal específica para multijugador

var didCut = false

func _ready():
	randomize()

func generate(initialPos):
	position = initialPos
	var initialVel = Vector2(0, rand_range(-3800, -3200))
	if initialPos.x < 640:
		initialVel = initialVel.rotated(deg2rad(rand_range(0, -30)))
	else:
		initialVel = initialVel.rotated(deg2rad(rand_range(0, 30)))
	linear_velocity = initialVel
	angular_velocity = rand_range(-10, 10)

func cut():
	if didCut: return
	didCut = true
	emit_signal("explode_bomb") # MODIFICADO
	set_mode(MODE_KINEMATIC)
	anim.play("Explode")

func _process(delta):
	if position.y > 3900:
		queue_free()
