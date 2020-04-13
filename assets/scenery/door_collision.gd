extends StaticBody2D

signal interacted_with(unit)

func interact(unit):
    emit_signal("interacted_with", unit)
