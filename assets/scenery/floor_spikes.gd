extends Area2D

signal spikes_down
signal spikes_up

onready var animation = $AnimationPlayer


func _ready():
    emit_signal("spikes_down")


func on_activate_end():
    emit_signal("spikes_up")


func on_deactivate_end():
    emit_signal("spikes_down")
    animation.play("idle")


func _on_FlookSpikes_area_entered(_area):
    print("area_entered")
    animation.play("activate")


func _on_FloorSpikes_area_exited(_area):
    print("area_exited")
    animation.play("deactivate")
