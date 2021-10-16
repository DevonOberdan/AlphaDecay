extends Node2D


# grab all recipes
# grab all atoms
#connect atom signal to recipes

onready var transition = $CanvasLayer/LevelUI/SceneTransitionRect
onready var success_ui = $CanvasLayer/LevelUI/SuccessContainer
onready var scene_button = $CanvasLayer/LevelUI/SuccessContainer/SceneButton

onready var recipe_button = $CanvasLayer/LevelUI/ResetButton
var atoms = []
var recipes = []


var atom_group = "Atoms"
var recipe_group = "Recipes"

var recipes_completed = 0

func _ready():
	success_ui.hide()
	
	scene_button.connect("scene_prompted", self, "clean_up_level")
	
	if transition:
		transition.show()
		scene_button.connect("scene_prompted", transition, "transition_to")
	
	for atom in get_tree().get_nodes_in_group(atom_group):
		atoms.append(atom)
	for recipe in get_tree().get_nodes_in_group(recipe_group):
		recipes.append(recipe)
		
	for atom in atoms:
		for rec in recipes:
			atom.connect("particle_count_updated", rec, "check_atom_against_recipe")

	for rec in recipes:
		rec.connect("recipe_completed", self, "check_level_completion")

func check_level_completion(recipe):
	recipes_completed+=1
	
	for atom in atoms:
		atom.disconnect("particle_count_updated", recipe, "check_atom_against_recipe")
	recipe.disconnect("recipe_completed", self, "check_level_completion")
	
	if recipes_completed == recipes.size():
		success_ui.show()



func clean_up_level(scene_path):
	success_ui.hide()
	recipe_button.hide()
	for recipe in recipes:
		recipe.hide()
	for atom in atoms:
		atom.tooltip.hide()


func _on_Button_pressed():
	pass # Replace with function body.
