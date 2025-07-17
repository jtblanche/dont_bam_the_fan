extends Node
#
#func _update_device_list():
	##var devices = Input.get_connected_joypads()
	##for device_id in devices:
		##var name = Input.get_joy_name(device_id)
		##print("device: ", device_id, ", type: ", name)
	## Initial check for connected joypads
	#var connected_joypads = Input.get_connected_joypads()
	#print("Connected Joypad IDs on start: ", connected_joypads)
	#
	### Set up initial player inputs based on connected devices
	##for i in range(connected_joypads.size()):
		##var device_id = connected_joypads[i]
		### Assign player 1, player 2, etc. based on connection order
		### In a real game, you'd have a more robust player assignment system
		##player_inputs[device_id] = {
			##"player_index": i + 1,
			##"controller_type": "Unknown", # We'll try to determine this
			##"button_prompts": {} # Store specific button prompt textures/names
		##}
		##print("Player %d assigned to device ID: %d" % [player_inputs[device_id].player_index, device_id])
		##
	### Connect to joypad connection/disconnection signals
	##Input.joy_connection_changed.connect(_on_joy_connection_changed)
	#
#
#func _on_device_connections_changed(device_id: int, connected: bool):
	#print("device connections have changed: ")
	#print("device: ", device_id)
	#print("connected: ", connected, "\n")
	#_update_device_list()
#
#func _ready() -> void:
	#Input.joy_connection_changed.connect(_on_device_connections_changed)
	#_update_device_list()
