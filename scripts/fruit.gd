extends RigidBody2D

onready var shape = get_node("Shape")
onready var sprite0 = get_node("Sprite0")
onready var body1 = get_node("Body1")
onready var body2 = get_node("Body2")
onready var sprite1 = get_node("Body1/Sprite1")
onready var sprite2 = body2.get_node("Sprite2")

var didCut = false

signal score
signal life

func _ready():
	randomize()

func generate(initialPos):
	position = initialPos
	var initialVel = Vector2(0, rand_range(-3800, -3200))
	if initialPos.x < 1920:
		initialVel = initialVel.rotated(deg2rad(rand_range(0, -30)))
	else:
		initialVel = initialVel.rotated(deg2rad(rand_range(0, 30)))
	linear_velocity = initialVel
	angular_velocity = rand_range(-10, 10)

func cut():
	if didCut: return
	didCut = true
	emit_signal("score", global_position.x)
	mode = MODE_KINEMATIC
	sprite0.queue_free()
	shape.queue_free()
	body1.mode = MODE_RIGID
	body2.mode = MODE_RIGID
	body1.apply_impulse(Vector2(0, 0), Vector2(-300, 0).rotated(rotation))
	body2.apply_impulse(Vector2(0, 0), Vector2(300, 0).rotated(rotation))
	body1.angular_velocity = angular_velocity
	body2.angular_velocity = angular_velocity

func _process(delta):
	if position.y > 3900:
		emit_signal("life")
		queue_free()
	if body1.position.y > 3900 and body2.position.y > 3900:
		queue_free()
