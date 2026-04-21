# res://scripts/level_select.gd
extends Control

@onready var test_level_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TestLevelButton
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

func _ready() -> void:
	test_level_button.pressed.connect(_on_test_level_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_setup_menu_focus()
	call_deferred("_focus_default_button")

func _process(_delta: float) -> void:
	_ensure_focus()

	if Input.is_action_just_pressed("ui_up"):
		_focus_previous_button()
		return

	if Input.is_action_just_pressed("ui_down"):
		_focus_next_button()
		return

	if Input.is_action_just_pressed("ui_accept"):
		_press_focused_button()
		return

func _setup_menu_focus() -> void:
	test_level_button.focus_mode = Control.FOCUS_ALL
	back_button.focus_mode = Control.FOCUS_ALL

	test_level_button.focus_neighbor_top = back_button.get_path()
	test_level_button.focus_neighbor_bottom = back_button.get_path()

	back_button.focus_neighbor_top = test_level_button.get_path()
	back_button.focus_neighbor_bottom = test_level_button.get_path()

	test_level_button.mouse_entered.connect(func() -> void: test_level_button.grab_focus())
	back_button.mouse_entered.connect(func() -> void: back_button.grab_focus())

func _focus_default_button() -> void:
	if test_level_button != null:
		test_level_button.grab_focus()

func _ensure_focus() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused == null:
		test_level_button.grab_focus()

func _focus_previous_button() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()

	if focused == null:
		test_level_button.grab_focus()
		return

	if focused == back_button:
		test_level_button.grab_focus()
	else:
		back_button.grab_focus()

func _focus_next_button() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()

	if focused == null:
		test_level_button.grab_focus()
		return

	if focused == test_level_button:
		back_button.grab_focus()
	else:
		test_level_button.grab_focus()

func _press_focused_button() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()

	if focused == null:
		test_level_button.grab_focus()
		return

	if focused == test_level_button:
		test_level_button.emit_signal("pressed")
		return

	if focused == back_button:
		back_button.emit_signal("pressed")
		return

func _on_test_level_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")
