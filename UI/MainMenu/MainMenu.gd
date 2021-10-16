extends Control


onready var transition = $SceneTransitionRect
onready var start_button = $StartButton
#onready var credits_button = $CreditsButton
# Called when the node enters the scene tree for the first time.
func _ready():
	transition.show()
	start_button.connect("scene_prompted", transition, "transition_to")
