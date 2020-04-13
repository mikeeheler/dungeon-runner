class_name Hero
extends KinematicBody2D

signal facing_changed(facing)

enum {
    FACING_LEFT,
    FACING_RIGHT
}

enum {
    STANDING,
    WALKING,
    RUNNING
}

const ACCELERATION = 400
const FRICTION = 400
const MAX_SPEED = 100
const RUN_SPEED = 50

var _facing = FACING_RIGHT setget _set_facing
var look_direction = Vector2.RIGHT
var move_state = STANDING
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var interactRay = $Interaction

func _physics_process(_delta):
    velocity = move_and_slide(velocity)
    interactRay.cast_to = look_direction * 16


func _process(delta):
    var direction = Vector2.ZERO

    if Input.is_action_pressed("ui_down"):
        direction += Vector2.DOWN
    if Input.is_action_pressed("ui_left"):
        direction += Vector2.LEFT
    if Input.is_action_pressed("ui_right"):
        direction += Vector2.RIGHT
    if Input.is_action_pressed("ui_up"):
        direction += Vector2.UP

    if direction.is_equal_approx(Vector2.ZERO):
        velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    else:
        direction = direction.normalized()
        look_direction = direction
        if direction.x < 0:
            _set_facing(FACING_LEFT)
        elif direction.x > 0:
            _set_facing(FACING_RIGHT)
        velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

    match move_state:
        STANDING:
            if not velocity.is_equal_approx(Vector2.ZERO):
                move_state = WALKING
        WALKING:
            if velocity.length() >= RUN_SPEED:
                move_state = RUNNING
                animationPlayer.play("run")
            elif velocity.is_equal_approx(Vector2.ZERO):
                move_state = STANDING
        RUNNING:
            if velocity.length() < RUN_SPEED:
                move_state = WALKING
                animationPlayer.play("idle")


func _set_facing(facing_dir):
    if _facing == facing_dir:
        return

    _facing = facing_dir
    emit_signal("facing_changed", _facing)


func _on_facing_changed(facing):
    $Sprite.flip_h = facing == FACING_LEFT


func _unhandled_input(event):
    if event.is_action_pressed("ui_interact"):
        _handle_interact()
        get_tree().set_input_as_handled()


func _handle_interact():
    if not interactRay.is_colliding():
        return

    var collider = interactRay.get_collider()
    if collider.has_method("interact"):
        collider.call("interact", self)
