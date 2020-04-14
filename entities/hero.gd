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
const INTERACT_RAY_DIST = 8
const MAX_SPEED = 100
const RUN_SPEED = 50

var _facing = FACING_RIGHT setget _set_facing
var _look_direction = Vector2.RIGHT
var _move_state = STANDING
var _run_anim = "run_r"
var _velocity = Vector2.ZERO
var _walk_anim = "walk_r"

onready var animationPlayer = $AnimationPlayer
onready var interactRay = $Interaction
onready var animStateMachine = $AnimationTree.get("parameters/playback")


func _physics_process(_delta):
    _velocity = move_and_slide(_velocity)
    interactRay.cast_to = _look_direction * INTERACT_RAY_DIST


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
        _velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
    else:
        direction = direction.normalized()
        _look_direction = direction
        if direction.x < 0:
            _set_facing(FACING_LEFT)
        elif direction.x > 0:
            _set_facing(FACING_RIGHT)
        _velocity = _velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

    match _move_state:
        STANDING:
            if not _velocity.is_equal_approx(Vector2.ZERO):
                _move_state = WALKING
        WALKING:
            if _velocity.length() >= RUN_SPEED:
                _move_state = RUNNING
                animStateMachine.travel(_run_anim)
            elif _velocity.is_equal_approx(Vector2.ZERO):
                _move_state = STANDING
        RUNNING:
            if _velocity.length() < RUN_SPEED:
                _move_state = WALKING
                animStateMachine.travel(_walk_anim)


func _set_facing(facing_dir):
    if _facing == facing_dir:
        return

    _facing = facing_dir
    emit_signal("facing_changed", _facing)


func _on_facing_changed(facing):
    if facing == FACING_LEFT:
        _run_anim = "run_l"
        _walk_anim = "walk_l"
    elif facing == FACING_RIGHT:
        _run_anim = "run_r"
        _walk_anim = "walk_r"


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
