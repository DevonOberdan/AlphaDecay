extends Node2D
class_name Shell

var default_shell_radius = 145

var electron_count = 0

export var electron_start_count = 2
export  var electron_max_count = 4

enum SIZES{
	INNER,
	MID,
	OUTER
}

export(SIZES) var size

onready var path = $Path2D

#onready var electron_container = get_tree().get_root().get_node("Level/ElectonContainer")

onready var shell_sprite = $Sprite

onready var parent_atom = get_parent().get_parent()

onready var path_follow_scene = preload("res://Shell/ElectronPathFollow.tscn")

var test = true

var path_follows : Array

var electrons : Array

var electron_pf_positions = {}

#var path_follow_containers
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	for i in range(0, electron_max_count):
		var pf = path_follow_scene.instance()
		path.add_child(pf)
		rng.randomize()
		var rand_offset = float(i)/electron_max_count#rng.randf_range(0, 1)

		pf.unit_offset = rand_offset
		path_follows.append(pf)
	

	call_deferred("populate_electrons")


func populate_electrons():
	
	var follows = path_follows
	follows.shuffle()
	
	var i =0
	for pf in follows:
		
		if i >= electron_start_count:
			return
			
		var new_electron = parent_atom.electron_scene.instance()
		
		var root = get_tree().get_root()
		var level = root.get_node("Level")
		level.add_child(new_electron)
		#electron_container.add_child(new_electron)
		
		pf.get_node("RemoteTransform2D").remote_path = new_electron.get_path()
		electron_pf_positions[new_electron.name] = pf

		new_electron.setup(parent_atom, Vector2())
		
		electrons.append(new_electron)
		
		new_electron.shell = self
		electron_count+=1
		parent_atom.total_electron_count +=1
		
		i+=1



func has_space():
	return electron_count < path_follows.size()
	
func has_electron(electron):
	return electrons.has(electron)

func remove_electron(electron):
	electrons.erase(electron)
	electron_count -=1
	
	var pf_node = electron_pf_positions[electron.name]
	
	var node : RemoteTransform2D = path_follows[path_follows.find(pf_node)].get_node("RemoteTransform2D")
	
	node.remote_path = ""

func add_electron(electron):

	for pf_node in path_follows:
		if not pf_node.get_node("RemoteTransform2D").remote_path:
			electron.path_follow_node = pf_node
			electron_pf_positions[electron.name] = pf_node
			break
	
	electrons.append(electron)
	electron.shell = self
	electron_count +=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
