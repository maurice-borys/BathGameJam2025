extends Timer

var spawn_entity: PackedScene

func set_target(entity: PackedScene):
	spawn_entity = entity

	
func _on_timer_timeout():
	self.start()
