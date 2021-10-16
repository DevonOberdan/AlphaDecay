extends Particle
class_name Electron

var in_shell = true

#enum States{
#	IN_SHELL,
#	FLOATING,
#	DYING
#}
#
#export(States) var state


#export var radius = 10

onready var sprite_container = $SpriteContainer

#var rng = RandomNumberGenerator.new()

var follow_container : PathFollow2D

var in_shell_scale = Vector2()
var floating_scale = Vector2(1,1)


var potential_atom
var owner_atom = null setget set_owner_atom
var shell = null
var path_follow_node = null

var time_lerping = 0

func _ready():
	default_layer_index = 2


func setup(var parent, var new_pos):
	if parent:
		state = States.IN_ATOM
		owner_atom = parent
		scale = floating_scale
		

		mode = MODE_STATIC
		
	else:
		state = States.FLOATING
		scale = floating_scale


		
	default_layer_index = 2
	global_position = new_pos
	connect("body_entered", self, "_on_Particle_body_entered")

func _physics_process(delta):
	match state:
		States.IN_ATOM:
			pass
		States.FLOATING:
			pass
		States.SETTLING:
			time_lerping+=delta
		
			if (time_lerping <= 1.0):
				position = lerp(position,path_follow_node.get_global_transform().origin, .2)
			else:
				position = lerp(position,path_follow_node.get_global_transform().origin, .75)
				if (position - path_follow_node.get_global_transform().origin).length() < 5:
					mode = MODE_STATIC
					state = States.IN_ATOM
					path_follow_node.get_node("RemoteTransform2D").remote_path = get_path()
					time_lerping = 0
		States.DYING:
			#dying anim
			pass
		

func set_owner_atom(atom):
	if(atom):

		start_settle_into_atom(atom)
		atom.claim_electron(self)

func start_settle_into_atom(atom):
	state = States.SETTLING

func handle_release():
	if(potential_atom):
		set_owner_atom(potential_atom)
	else:
		release()

func check_shell_status():
	return get_parent().name == "Shell"
		

func _on_ParticleArea_body_entered(body : PhysicsBody2D):
	if body.get_collision_layer_bit(4):
		annihilate(body)

func annihilate(positron):
	if owner_atom:
		owner_atom.lose_electron(self)
	if shell:
		shell.remove_electron(self)

	positron.queue_free()
	call_deferred("queue_free")


func _on_Particle_body_entered(body):
	if mode == MODE_RIGID:
		thump_sound.play()
