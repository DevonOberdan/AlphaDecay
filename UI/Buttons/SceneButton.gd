extends Button

export var scene: PackedScene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var click_player = $ClickPlayer

signal scene_prompted(value)





func _on_SceneButton_pressed():
	click_player.play()
	emit_signal("scene_prompted", scene.resource_path)
