extends NavigationAgent3D

var agent: RID = get_rid()
# Enable avoidance
NavigationServer3D.agent_set_avoidance_enabled(agent, true)
# Create avoidance callback
NavigationServer3D.agent_set_avoidance_callback(agent, Callable(self, "_avoidance_done"))
