# res://scripts/main_menu.gd
extends Control

@onready var start_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StartButton
@onready var options_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var exit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	_setup_menu_focus()

func _setup_menu_focus() -> void:
	start_button.focus_mode = Control.FOCUS_ALL
	options_button.focus_mode = Control.FOCUS_ALL
	exit_button.focus_mode = Control.FOCUS_ALL

	start_button.focus_neighbor_bottom = options_button.get_path()
	start_button.focus_neighbor_top = exit_button.get_path()

	options_button.focus_neighbor_top = start_button.get_path()
	options_button.focus_neighbor_bottom = exit_button.get_path()

	exit_button.focus_neighbor_top = options_button.get_path()
	exit_button.focus_neighbor_bottom = start_button.get_path()

	start_button.mouse_entered.connect(func() -> void: start_button.grab_focus())
	options_button.mouse_entered.connect(func() -> void: options_button.grab_focus())
	exit_button.mouse_entered.connect(func() -> void: exit_button.grab_focus())

	start_button.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
