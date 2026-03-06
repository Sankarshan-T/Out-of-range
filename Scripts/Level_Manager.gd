extends Node2D

@export_group("Level Settings")
@export var level_no: int
@export var next_level: PackedScene 
@export var level_timeline: String = ""

@onready var level_label = find_child("LevelLabel", true, false)
@onready var energy_label = find_child("EnergyLabel", true, false)

func _ready() -> void:
	if level_label:
		level_label.text = "Level: " + str(level_no)
	update_energy_ui()

func _process(_delta: float) -> void:
	update_energy_ui()

func update_energy_ui() -> void:
	var total_energies = get_tree().get_nodes_in_group("Energies").size()
	if energy_label:
		energy_label.text = str(total_energies) + " to collect"
	
	if total_energies <= 0 and not is_queued_for_deletion():
		set_process(false) 
		complete_level()

func complete_level() -> void:
	await get_tree().create_timer(1.0).timeout
	
	var player = get_tree().get_first_node_in_group("Player")
	
	if level_timeline != "":
		if player: player.is_frozen = true
		Dialogic.start(level_timeline)
		await Dialogic.timeline_ended
		if player: player.is_frozen = false
	
	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		print("Mission Accomplished! (No next level set)")

func navigate_to_level(path: String) -> void:
	if path == "": return
	get_tree().call_deferred("change_scene_to_file", path)
