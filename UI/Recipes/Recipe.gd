tool
extends TextureRect


export var protons = 0 setget writeProtonCount
export var neutrons = 0 setget writeNeutronCount
export var electrons = 0 setget writeElectronCount

export var element = "" setget write_element

var complete = false setget setCompletion

onready var colorBG = $ColorBackground
var completion_color = "c3f8c5"
#onready var n_label = $HBoxContainer/HBoxContainer5/NeutronLabel
#onready var e_label = $HBoxContainer/HBoxContainer6/ElectronLabel
#
#onready var element_label = $MarginContainer/ElementLabel
onready var level = get_tree().get_root().get_node("Level")

var atom_group = "Atoms"

signal recipe_completed(recipe)

func writeProtonCount(val):
	var p_label = get_node("HBoxContainer4/ProtonLabel")
	p_label.text = String(val)
	protons = val
	
func writeNeutronCount(val):
	var n_label = get_node("HBoxContainer/HBoxContainer5/NeutronLabel")
	n_label.text = String(val)
	neutrons=val

func writeElectronCount(val):
	var e_label = get_node("HBoxContainer/HBoxContainer6/ElectronLabel")
	e_label.text = String(val)
	electrons=val
	
func write_element(val):
	var element_label = get_node("MarginContainer/ElementLabel")
	element_label.text = val
	element=val

func setCompletion(val):
	complete = val
	
	#completion effect

	
	if complete:
		colorBG.modulate = Color(completion_color)
		emit_signal("recipe_completed", self)
	

func check_atom_against_recipe(atom_protons, atom_neutrons, atom_electrons):
	

	if atom_protons==protons and atom_neutrons==neutrons and atom_electrons==electrons:
		setCompletion(true)


