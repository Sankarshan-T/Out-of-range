extends Area2D

signal energy_collected

func _on_body_entered(body: Node2D) -> void:
	remove_from_group("Energies")
	if body.has_method("_on_energy_collected"):
		self.energy_collected.connect(body._on_energy_collected)
		energy_collected.emit()
		queue_free()
