tool
extends Node2D
class_name Atom


var electron_scene = preload("res://Particles/Scenes/Electron.tscn")
var positron_scene = preload("res://Particles/Scenes/Positron.tscn")

var total_electron_count = 0 setget setElectronCount
var proton_count = 0 setget setProtonCount
var neutron_count = 0 setget setNeutronCount

var nucleus_count = 0

var p_n_difference = 0

var beta_balance_thresholds = [2,3,4,5]

export var decay_probabilities = [.25, .35, .65, .85]


export var start_protons = 0
export var start_neutrons = 0
export var start_electrons =0 setget set_start_electrons, get_start_electrons
export var electron_shell_capacities = [2,8,18]


var alpha_size_thresholds = [41,45,50,55]
var alpha_decay_amount = 2


var mid_beta_decay = false
var mid_alpha_decay = false

onready var alpha_timer = $AlphaTimer
onready var beta_timer = $BetaTimer

var decay_time_range = [2,5]

var electron_group = "Electrons"

var rng = RandomNumberGenerator.new()

onready var nucleus = get_node("Nucleus")

var electron_ejection_force = 100
var mass_particle_ejection_force = 300

onready var shells = $Shells

var shell_count

onready var area = $AtomArea

onready var alpha_sound = $AlphaPlayer
onready var beta_sound = $BetaPlayer

onready var unstable_sound = $UnstablePlayer

onready var tooltip = $CanvasLayer/Tooltip

signal particle_count_updated(p,n,e)

var start_particles_complete = false




func _ready():
	

	shell_count = shells.shell_count
	tooltip.hide()
	connect("particle_count_updated", self, "check_decay")


func set_start_electrons(val):
	start_electrons = val
	if !Engine.editor_hint:
		return

	
	if !shells:
		shells = get_node("Shells")
	
	if start_electrons==0:
		shells.shell_count = 0
	elif start_electrons <= electron_shell_capacities[0]:
		shells.shell_count = 1
		shells.get_child(0).electron_start_count = start_electrons
		
	elif start_electrons <= electron_shell_capacities[0]+electron_shell_capacities[1]:
		shells.shell_count = 2
		shells.get_child(0).electron_start_count = start_electrons
		shells.get_child(1).electron_start_count = start_electrons - electron_shell_capacities[0]
	else:
		shells.shell_count = 3
		var electrons_left = start_electrons
		shells.get_child(0).electron_start_count = electron_shell_capacities[0]
		shells.get_child(1).electron_start_count = start_electrons - electron_shell_capacities[0]
		shells.get_child(2).electron_start_count = start_electrons - electron_shell_capacities[0] - electron_shell_capacities[1]
	
func get_start_electrons():
	return start_electrons

func setProtonCount(val):
	
	proton_count = val
	p_n_difference = proton_count-neutron_count
	nucleus_count = proton_count+neutron_count
	print("proton")
	send_particle_signal()

func setNeutronCount(val):
	neutron_count = val
	p_n_difference = proton_count-neutron_count
	nucleus_count = proton_count+neutron_count
	print("neutron")
	send_particle_signal()
	
func setElectronCount(val):
	total_electron_count=val
	print(total_electron_count)
	send_particle_signal()



func send_particle_signal():
	if start_particles_complete:
		emit_signal("particle_count_updated", proton_count,neutron_count,total_electron_count)
	else:
		print(proton_count, ", ",neutron_count, ", ",total_electron_count)
		print(start_protons, ", ",start_neutrons, ", ",start_electrons)
		if proton_count==start_protons and neutron_count==start_neutrons and total_electron_count==start_electrons:
			start_particles_complete = true
			print("emitting")
			emit_signal("particle_count_updated", proton_count,neutron_count,total_electron_count)

func claim_electron(electron):
	var shell_list = shells.get_children()
	shell_list.shuffle()
	for shell_node in shell_list:
		var shell : Shell = shell_node
		if shell.has_space():
			shell.add_electron(electron)
			setElectronCount(total_electron_count+1)
			return
	
func lose_electron(electron):
	setElectronCount(total_electron_count-1)




func _process(delta):
	if Engine.editor_hint:
		return
		
	if mid_alpha_decay or mid_beta_decay:
		nucleus.anim_player.play("Unstable")
		if !unstable_sound.playing:
			unstable_sound.play()
	else:
		nucleus.anim_player.play("Stable")
		unstable_sound.stop()


func check_for_decay(delta):
	var decaying = false
	
	if abs(p_n_difference) >= beta_balance_thresholds[0]:
		decaying = true
		if roll_decay_dice(delta):
			if p_n_difference > 0:
				decay_beta_plus()
			elif p_n_difference < 0:
				decay_beta_minus()
	
	if nucleus_count > alpha_size_thresholds[0] and roll_decay_dice(delta):
		decaying=true
		decay_alpha()
	return decaying
	
func roll_decay_dice(delta):
	
	rng.randomize()
	
	var amount_over_minimum = abs(p_n_difference)-beta_balance_thresholds[0]
	var index = clamp(amount_over_minimum,0,decay_probabilities.size()-1)
	
	return decay_probabilities[index] * delta > rng.randf_range(0, 1)

func decay_beta_minus():
	nucleus.neutron_to_proton()
	setNeutronCount(neutron_count-1)
	setProtonCount(proton_count+1)
	
	var dist = area.get_node("CollisionShape2D").shape.radius + 50
	
	rng.randomize()
	var rand_radian = rng.randf_range(0, 2*PI)
	var x_dir = cos(rand_radian) *dist
	var y_dir = sin(rand_radian) *dist
	
	var spawn_vec = Vector2(x_dir,y_dir)

	launch_particle(spawn_electron(spawn_vec), spawn_vec.normalized(), electron_ejection_force)
	beta_sound.play()
	

func decay_beta_plus():
	nucleus.proton_to_neutron()
	setNeutronCount(neutron_count+1)
	setProtonCount(proton_count-1)
	
	var dist = area.get_node("CollisionShape2D").shape.radius + 50
	
	rng.randomize()
	var rand_radian = rng.randf_range(0, 2*PI)
	var x_dir = cos(rand_radian) *dist
	var y_dir = sin(rand_radian) *dist
	
	var spawn_vec = Vector2(x_dir,y_dir)

	launch_particle(spawn_positron(spawn_vec), spawn_vec.normalized(), electron_ejection_force)
	beta_sound.play()

func decay_alpha():
	var p_count = 0
	var n_count = 0
	
	rng.randomize()
	var rand_radian = rng.randf_range(0, 2*PI)
	var x_dir = cos(rand_radian)
	var y_dir = sin(rand_radian)
	
	var decay_dir = Vector2(x_dir,y_dir)
	
	for i in range(0,alpha_decay_amount):
		var proton = nucleus.protons[i]
		var neutron = nucleus.neutrons[i]
		
		proton.state = proton.States.FLOATING
		neutron.state = neutron.States.FLOATING

		proton.mode = proton.MODE_RIGID
		neutron.mode = neutron.MODE_RIGID
		
		launch_particle(proton, decay_dir, mass_particle_ejection_force)
		launch_particle(neutron, decay_dir, mass_particle_ejection_force)
	
	alpha_sound.play()
	

func spawn_electron(spawn_point):
	var electron = electron_scene.instance()
	electron.state = electron.States.LAUNCHING
	var root = get_tree().get_root()
	root.get_node("Level").add_child(electron)

	electron.setup(null, spawn_point+get_global_transform().origin)
	return electron
	
func spawn_positron(spawn_point):
	var positron = positron_scene.instance()
	positron.state = positron.States.LAUNCHING
	var root = get_tree().get_root()
	root.get_node("Level").add_child(positron)

	positron.setup(null, spawn_point+get_global_transform().origin)
	return positron

func in_atom(particle):
	return particle.owner_atom == self

func launch_particle(particle, dir, speed):
	
	particle.apply_central_impulse(dir*speed)


func accepting_electrons():
	for shell in shells.get_children():
		if shell.has_space():
			return true
	return false



func check_decay(p,n,e):
	if mid_alpha_decay:
		pass
	elif nucleus_count > alpha_size_thresholds[0]:
		rng.randomize()
		var time = rng.randf_range(decay_time_range[0], decay_time_range[1])
		
		alpha_timer.wait_time = time
		alpha_timer.start()
		mid_alpha_decay=true
	
	if mid_beta_decay:
		pass
	elif abs(p_n_difference) >= beta_balance_thresholds[0]:
		rng.randomize()
		var time = rng.randf_range(decay_time_range[0], decay_time_range[1])
		
		beta_timer.wait_time = time
		beta_timer.start()
		mid_beta_decay=true

func _on_AtomArea_area_entered(area):
	var particle : Node2D = area.get_parent()
	if particle.is_in_group(electron_group) and !in_atom(particle) and accepting_electrons() and particle.state != particle.States.LAUNCHING:
		if particle.state == particle.States.GRABBED:
			particle.potential_atom = self
		else:
			particle.owner_atom = self


func _on_AtomArea_area_exited(area):
	var electron : Electron = area.get_parent()
	if in_atom(electron):
		pass
	else:
		electron.potential_atom = null
		if electron.state == electron.States.LAUNCHING:
			electron.state = electron.States.FLOATING
		


func _on_AtomArea_mouse_entered():
	tooltip.show()


func _on_AtomArea_mouse_exited():
	tooltip.hide()



func _on_BetaTimer_timeout():
	if p_n_difference > 0:
		decay_beta_plus()
	elif p_n_difference < 0:
		decay_beta_minus()
	mid_beta_decay=false


func _on_AlphaTimer_timeout():
	decay_alpha()
	mid_alpha_decay=false
