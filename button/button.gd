extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

# types :
# 0 : 2 position mode : on or off 
# 1 : the button will be blinking for a determined time before action occure (not a action that stand in time, like launching attack)
# 2 : like 0, but the button will be blinking for a determined time before being "on"
# 3 : the button will be blinking until the player click on it (used to turn off alarm)

signal left_click()

signal button_blinking_terminated()

export (int) var type = 0
export (Color) var color = Color()
export (int) var blinking_duration = 1
export (bool) var set_up = false
export (bool) var toggle = false

var blink = false
var hold = false
var waiting_for_queue_end = false
var blink_count = 0

func _set_hold_and_blink():
	if type == 0 or type == 2:
		hold = true
	else:
		hold = false
		
	if type == 1 or type == 2:
		blink = true
	else:
		blink = false
	
func _set_color():
	$"Cube001".material_override.emission = color
	$OmniLight.light_color = color
	
	if toggle == true:
		$"Cube001".material_override.emission_enabled = true
		$OmniLight.visible = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	if set_up == true:
		if type >= 3 and type < 0:
			print('type out of range, 0,1,2 or 3 are accepted only')
		else:
			_set_hold_and_blink()
			_set_color()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func set_up_button(ntype,ncolor,nblinking_duration=1):
	if ntype >= 3 and ntype < 0:
		print('type out of range, 0,1,2 or 3 are accepted only')
	else:
		type = ntype
		color = ncolor
		blinking_duration = nblinking_duration
		set_up = true
		_set_hold_and_blink()
		_set_color()
	pass
	

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			$AnimationPlayer.play("default")
			if set_up == true:
				if toggle == false:
					if type != 3:
						toggle = true
						if blink == true:
							blink_count = 1
							$AnimationPlayer2.play('blink')
						if hold == true:
							$AnimationPlayer2.play('light_on')
					
				elif toggle == true:
					toggle = false
					if hold == true:
						$AnimationPlayer2.play('light_off')
			$AudioStreamPlayer3D._on_Button_left_click()

func blink():
	toggle = true
	$AnimationPlayer2.play('blink')

func _on_AnimationPlayer2_animation_finished(anim_name):
	if (type == 1 or type == 2) and toggle == true and blink_count != blinking_duration:
		if type == 2 and blink_count == blinking_duration -1 :
			$AnimationPlayer2.play('light_on')
		else:
			$AnimationPlayer2.play('blink')
		blink_count += 1
		
		
		
	if type == 1 and toggle == true and blink_count == blinking_duration:
		toggle = false
		
	if type == 3 and toggle == true:
		$AnimationPlayer2.play('blink')
		
	
	if toggle == false:
		emit_signal("button_blinking_terminated")
		
	if anim_name == "light_on" or anim_name == "light_off":
		emit_signal("left_click")
