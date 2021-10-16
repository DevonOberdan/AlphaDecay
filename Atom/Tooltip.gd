extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var proton_label = $HBoxContainer/ProtonToolLabel
onready var neutron_label = $HBoxContainer/NeutronToolLabel
onready var electron_label = $HBoxContainer/ElectronToolLabel
onready var atom = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	var offset = rect_position
	rect_position = atom.get_global_transform_with_canvas().get_origin()+ offset
	
	for child in get_children():
		child.mouse_filter = MOUSE_FILTER_IGNORE




func _on_Atom_particle_count_updated(p, n, e):
	proton_label.text=String(p)
	neutron_label.text=String(n)
	electron_label.text=String(e)
