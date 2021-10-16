extends RigidBody2D
class_name Particle

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum States{
	FLOATING,
	GRABBED,
	SETTLING,
	IN_ATOM,
	LAUNCHING
	DYING
}

export(States) var state

var mouse_hovering = false

var rng = RandomNumberGenerator.new()

var float_impulse = 10
var launch_impulse = 100

var default_layer_index = 0

onready var particle_area :Area2D= $ParticleArea

onready var thump_sound = $ThumpPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	particle_area.connect("mouse_entered", self, "_on_ParticleArea_mouse_entered")
	particle_area.connect("mouse_exited", self, "_on_ParticleArea_mouse_exited")
	
func rand_launch(speed):
	var rand_radian = rng.randf_range(0, 2*PI)
	var x_dir = cos(rand_radian)
	var y_dir = sin(rand_radian)
	apply_central_impulse(Vector2(x_dir,y_dir)*speed)


func _integrate_forces(state):
	rotation_degrees=0

func _input(event):
	if mouse_hovering:
		if event is InputEventMouseButton and event.button_index==BUTTON_LEFT:
			if !grabbing() and event.pressed and is_grabbable():
				set_grab_state()
			elif grabbing() and !event.pressed:
				set_release_state()


		
	if event is InputEventMouseMotion:
		if state==States.GRABBED:
			position = event.position
			

func set_grab_state():
	state = States.GRABBED

	linear_velocity = Vector2()
	angular_velocity = 0

func set_release_state():
	handle_release()


func handle_release():
	pass

func release():
	
	
	mode = MODE_RIGID
	apply_central_impulse(Input.get_last_mouse_speed())
	state = States.FLOATING

func is_grabbable():
	return state != States.IN_ATOM and state != States.SETTLING
func grabbing():
	return state==States.GRABBED

func _on_ParticleArea_mouse_entered():
	mouse_hovering = true


func _on_ParticleArea_mouse_exited():
	
	if(!grabbing()):
		mouse_hovering = false
