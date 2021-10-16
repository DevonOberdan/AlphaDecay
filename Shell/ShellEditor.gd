tool
extends Node2D

var shell_scene = preload("res://Shell/Shell.tscn")

export(int, "0","1","2","3") var shell_count = 1 setget setShells


var collision_radii = [61,77,102,120]
var shell_scales = [0.125, 0.16,0.19]
var shell_capacities = [2,8,18]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var duplicated = false

func setShells(var count):
	if Engine.editor_hint:
		var coll_shape : CollisionShape2D = get_parent().get_node("AtomArea/CollisionShape2D")

		print(duplicated)
		if !duplicated:
			coll_shape.shape = coll_shape.shape.duplicate()
		
		var current_children = get_child_count()
		print(current_children)
		if current_children < count:
			for i in range(current_children, count):
				var shell = shell_scene.instance()
				add_child(shell)
				shell.set_owner(get_tree().get_edited_scene_root())
				shell.scale = Vector2(shell_scales[i],shell_scales[i])
				
				
				print(i)
				shell.electron_max_count = get_parent().electron_shell_capacities[i]
		elif current_children > count:
			for i in range(current_children, count, -1):
				var outer_shell = get_child(i-1)
				remove_child(outer_shell)
				outer_shell.queue_free()
				
		coll_shape.shape.radius = collision_radii[count]
		
		shell_count = count
		print("after: ",shell_count)
