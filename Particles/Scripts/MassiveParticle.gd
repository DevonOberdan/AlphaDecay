extends Particle
class_name MassiveParticle

onready var area = $ParticleArea

#var mouse_hovering = false

#var grabbed = false

#var in_nucleus_range = false
var nucleus_position : Vector2

var potential_nucleus

var owner_nucleus = null setget set_owner_nucleus

var MAX_SPEED = 10

var just_released_cached = false

var bodyState : Physics2DDirectBodyState

onready var proton_sprite = preload("res://Particles/Sprites/Proton_dark.png") 
onready var neutron_sprite = preload("res://Particles/Sprites/Neutron_dark.png")
onready var sprite = $Particle
onready var anim_player = $AnimationPlayer

enum Types{
	PROTON,
	NEUTRON
}
export(Types) var type


func _ready():
	default_layer_index = 0
	if potential_nucleus:
		state = States.IN_ATOM
	else:
		state = States.FLOATING
		rand_launch(float_impulse)
		
	connect("body_entered", self, "_on_Particle_body_entered")

func _process(delta):
	
	
	
	match state:
		States.FLOATING:
			pass
		States.SETTLING:
			position = lerp(position,nucleus_position, 0.02)
			
			if (position - nucleus_position).length() < 0.1 :
				mode = MODE_STATIC
				state = States.IN_ATOM
		States.IN_ATOM:
			pass
		States.GRABBED:
			pass
		States.LAUNCHING:
			pass
		States.FLOATING:
			pass



func _physics_process(delta):
	pass

func set_owner_nucleus(nucleus):

	if(nucleus):

		start_settle_into_nucleus(nucleus)
		nucleus.claim_particle(self)

func check_nucleus_placement():
	var parent = get_parent()
	
	if parent.is_in_group("Nuclei"):
		start_settle_into_nucleus(parent)
		
		
		
func start_settle_into_nucleus(nucleus):
	rng.randomize()

	var rand_radian = rng.randf_range(0, 2*PI)
	var full_radius = nucleus.shape_rad

	randomize()
	var rand_radius = randi() % int(nucleus.cluster_radius)

	var circle_x = cos(rand_radian) * rand_radius
	var circle_y = sin(rand_radian) * rand_radius

	var nucleus_point = nucleus.area.get_global_transform().origin
	var x = nucleus_point.x + circle_x
	var y = nucleus_point.y + circle_y

	nucleus_position = Vector2(x,y)
	set_deferred("mode", MODE_STATIC)
	state = States.SETTLING

func abort_from_nucleus():
	set_owner_nucleus(null)

func change_type(new_z_index):
	randomize()
	z_index = new_z_index
	
	if type==Types.PROTON:
		type = Types.NEUTRON
		anim_player.play("Change")
	else:
		type = Types.PROTON
		anim_player.play_backwards("Change")


func set_grab_state():
	.set_grab_state()
	set_collision_layer_bit(default_layer_index,false)
	set_collision_mask_bit(default_layer_index,false)
func set_release_state():
	.set_release_state()
	set_collision_layer_bit(default_layer_index,true)
	set_collision_mask_bit(default_layer_index,true)


func handle_release():
	if(potential_nucleus):
		set_owner_nucleus(potential_nucleus)
	else:
		release()


func _on_Particle_body_entered(body):
	if mode == MODE_RIGID:
		thump_sound.play()
