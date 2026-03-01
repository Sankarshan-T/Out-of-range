extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var canvas_modulate: CanvasModulate = $"../CanvasModulate"
@onready var point_light_2d: PointLight2D = $PointLight2D

@export var level_timeline: String = "" 
@export var next_level: PackedScene 

var is_frozen = false

func _physics_process(delta):
	if is_frozen:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		anim.play("Idle")
		return
		
	var total_energies = get_tree().get_nodes_in_group("Energies").size()
		
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
	
	var label = get_tree().current_scene.find_child("Label", true, false)

	if label:
		label.text = str(total_energies) + " to collect"
	else:
		print("Warning: Could not find Label")
		
	move_and_slide()
	update_animations(direction)

func update_animations(direction):
	if velocity.x != 0:
		anim.play("Run")
	else:
		anim.play("Idle")
		
func _on_energy_collected():
	var light_step = 0.05
	
	var new_r = clamp(canvas_modulate.color.r + light_step, 0.0, 1.0)
	var new_g = clamp(canvas_modulate.color.g + light_step, 0.0, 1.0)
	var new_b = clamp(canvas_modulate.color.b + light_step, 0.0, 1.0)
	
	canvas_modulate.color = Color(new_r, new_g, new_b)
	point_light_2d.scale *= 1.1
	
	if get_tree().get_nodes_in_group("Energies").size() < 1:
		await get_tree().create_timer(1.0).timeout
		play_end_of_level()

func play_end_of_level():
	if level_timeline != "":
		is_frozen = true
		
		Dialogic.start(level_timeline)
		await Dialogic.timeline_ended
		
		is_frozen = false
	
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		print("drag next level into the Inspector!")
