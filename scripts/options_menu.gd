# res://scripts/options_menu.gd
extends Control

@onready var fullscreen_check_button: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FullscreenCheckButton
@onready var screen_shake_check_button: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScreenShakeCheckButton
@onready var damage_numbers_check_button: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DamageNumbersCheckButton
@onready var reset_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResetButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

var menu_buttons: Array[Control] = []

func _ready() -> void:
	GameSettings.load_settings()

	fullscreen_check_button.button_pressed = GameSettings.fullscreen_enabled
	screen_shake_check_button.button_pressed = GameSettings.screen_shake_enabled
	damage_numbers_check_button.button_pressed = GameSettings.damage_numbers_enabled

	fullscreen_check_button.toggled.connect(_on_fullscreen_toggled)
	screen_shake_check_button.toggled.connect(_on_screen_shake_toggled)
	damage_numbers_check_button.toggled.connect(_on_damage_numbers_toggled)

	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

	menu_buttons = [
		fullscreen_check_button,
		screen_shake_check_button,
		damage_numbers_check_button,
		reset_button,
		back_button
	]

	_setup_menu_focus()

func _setup_menu_focus() -> void:
	for i in range(menu_buttons.size()):
		var button: Control = menu_buttons[i]
		var button_above: Control = menu_buttons[(i - 1 + menu_buttons.size()) % menu_buttons.size()]
		var button_below: Control = menu_buttons[(i + 1) % menu_buttons.size()]

		button.focus_mode = Control.FOCUS_ALL
		button.focus_neighbor_top = button_above.get_path()
		button.focus_neighbor_bottom = button_below.get_path()
		button.focus_neighbor_left = button.get_path()
		button.focus_neighbor_right = button.get_path()

		button.mouse_entered.connect(func(target_button: Control = button) -> void:
			target_button.grab_focus()
		)

	fullscreen_check_button.grab_focus()

func _on_fullscreen_toggled(value: bool) -> void:
	GameSettings.set_fullscreen_enabled(value)

func _on_screen_shake_toggled(value: bool) -> void:
	GameSettings.set_screen_shake_enabled(value)

func _on_damage_numbers_toggled(value: bool) -> void:
	GameSettings.set_damage_numbers_enabled(value)

func _on_reset_pressed() -> void:
	GameSettings.reset_settings()

	fullscreen_check_button.button_pressed = GameSettings.fullscreen_enabled
	screen_shake_check_button.button_pressed = GameSettings.screen_shake_enabled
	damage_numbers_check_button.button_pressed = GameSettings.damage_numbers_enabled

	fullscreen_check_button.grab_focus()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
