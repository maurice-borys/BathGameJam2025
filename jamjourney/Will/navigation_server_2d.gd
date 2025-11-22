extends Node2D


func add_agent():
	var new_agent_rid: RID = NavigationServer2D.agent_create()
	var default_2d_map_rid: RID = get_world_2d().get_navigation_map()

	NavigationServer2D.agent_set_map(new_agent_rid, default_2d_map_rid)
	NavigationServer2D.agent_set_radius(new_agent_rid, 0.5)
	NavigationServer2D.agent_set_position(new_agent_rid, global_transform.origin)
