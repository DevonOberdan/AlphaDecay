extends Node2D
class_name Nucleus

var particle_group = "MassiveParticles"


var sorting_z_range_max = 10

var particles_changed = 0

var settling_particle = false

onready var shadow = $Shadow
onready var anim_player = $AnimationPlayer

onready var area = get_node("Area2D")
onready var collision_shape : CollisionShape2D = get_node("Area2D/CollisionShape2D")
onready var atom : Atom = get_parent()

var shape_rad=0

export var cluster_radius = 30

var rng = RandomNumberGenerator.new()

var protons = []
var neutrons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape : CircleShape2D = collision_shape.shape
	shape_rad = shape.radius
	

func proton_to_neutron():
	randomize()
	var rand_ind = randi()%protons.size()
	var p = protons[rand_ind]
	
	p.change_type(sorting_z_range_max+particles_changed)
	
	protons.remove(rand_ind)
	neutrons.append(p)
	particles_changed+=1

func neutron_to_proton():
	randomize()
	var rand_ind = randi()%neutrons.size()
	var p = neutrons[rand_ind]
	
	p.change_type(sorting_z_range_max+particles_changed)
	
	neutrons.remove(rand_ind)
	protons.append(p)
	particles_changed+=1

func update_particles(particle : MassiveParticle):
	if particle.type == particle.Types.PROTON:
		protons.append(particle)
		atom.proton_count+=1
	else:
		neutrons.append(particle)
		atom.neutron_count+=1

	
func claim_particle(particle : MassiveParticle):
	sort_new_particle(particle)
	update_particles(particle)


func sort_new_particle(particle):
	var rand_index = (randi()%sorting_z_range_max)
	particle.z_index = rand_index



func _on_Area2D_area_entered(area):
	var particle : Node2D = area.get_parent()
	if particle.is_in_group(particle_group):
		if particle.state == particle.States.GRABBED:
			particle.potential_nucleus = self
		else:
			particle.owner_nucleus = self

func _on_Area2D_area_exited(area):
	var particle = area.get_parent() 
	if particle.is_in_group(particle_group):
		if in_nucleus(particle):
			particle.abort_from_nucleus()
			if particle.type == particle.Types.PROTON:
				protons.erase(particle)
				atom.proton_count -=1
			else:
				neutrons.erase(particle)
				atom.neutron_count -=1
			
		particle.potential_nucleus = null
		
func in_nucleus(particle):
	return protons.has(particle) or neutrons.has(particle)
