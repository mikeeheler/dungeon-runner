extends Node2D

export(bool) onready var door_open setget _set_door_open

signal door_closed
signal door_opened

func _close_door():
    $DoorOpen.hide()
    $DoorClosed.show()
    $DoorCollision/CollisionShape2D.set_deferred("disabled", false)
    emit_signal("door_closed")
    
func _open_door():
    $DoorClosed.show()
    $DoorOpen.hide()
    $DoorCollision/CollisionShape2D.set_deferred("disabled", true)
    emit_signal("door_opened")

func _set_door_open(value):
    door_open = value
    if value:
        _open_door()
    else:
        _close_door()


func _on_door_interacted_with(unit):
    _open_door()
