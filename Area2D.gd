extends Area2D


onready var particle = get_parent()

var z_range = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func sort_particle_into_nucleus():
	var rand_index = (randi()%z_range)-z_range
	
	z_index = rand_index
	
