extends ColorRect


export(String, FILE, "*.tcsn") var next_scene_path

onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play_backwards("Fade")

	var button = get_parent().get_node("ResetButton")
	if button:
		button.connect("pressed", self, "reload_scene")
	


func transition_to(next_scene):
	anim_player.play("Fade")
	yield(anim_player, "animation_finished")
	
	get_tree().change_scene(next_scene)

func reload_scene():
	
	var button = get_parent().get_node("ResetButton")
	if button:
		button.hide()
	
	anim_player.play("Fade")
	yield(anim_player, "animation_finished")
	
	get_tree().reload_current_scene()

func _on_StartButton_scene_prompted():
	pass # Replace with function body.
