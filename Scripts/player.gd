extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D

var canvas_modulate: CanvasModulate
var is_frozen = false

func _ready():
	add_to_group("Player")
	canvas_modulate = get_parent().find_child("CanvasModulate", true, false)

func _physics_process(delta):
	if is_frozen:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor(): velocity += get_gravity() * delta
		move_and_slide()
		anim.play("Idle")
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
	
	move_and_slide()
	update_animations()

func update_animations():
	anim.play("Run" if velocity.x != 0 else "Idle")

func _on_energy_collected():
	if canvas_modulate:
		canvas_modulate.color = canvas_modulate.color.lightened(0.05)
	point_light_2d.scale *= 1.1
