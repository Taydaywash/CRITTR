extends pause_tab
# Each category becomes a button in the top bar.
# Each entry inside it becomes a row on the left side.
# Each entry has an image on the right side

# Entry fields:
# title : String — display name
# body_text : String — description
# image_path : String — "res://..." or "" for a placeholder color
# locked : bool — if true it is locked and cannot be opened

var categories: Array[Dictionary] = [
	{
		"name": "Crittrs",
		"entries": [
			{
				"title": "Rabbit",
				"body_text": """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "Frog",
				"body_text": """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "???",
				"body_text": "",  
				"image_path": "",
				"locked": true,
			},
			{
				"title": "???",
				"body_text": "",
				"image_path": "",
				"locked": true,
			},
		],
	},
	{
		"name": "Abilities",
		"entries": [
			{
				"title": "Dash",
				"body_text": """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "Grapple",
				"body_text": """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "???",
				"body_text": "",
				"image_path": "",
				"locked": true,
			},
		],
	},
	{
		"name": "World",
		"entries": [
			{
				"title": "The Arctic",
				"body_text": """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked":     false,
			},
			{
				"title": "Toxic Marsh",
				"body_text":  """Placeholder. Placeholder. Placeholder. Placeholder. 
				Placeholder. Placeholder. Placeholder. Placeholder. Placeholder. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "???",
				"body_text": "",
				"image_path": "",
				"locked": true,
			},
		],
	},
	{
		"name": "Other",
		"entries": [
			{
				"title": "Collectables",
				"body_text": """0 scrap found. Ever since the ship crashed, 
				your ships parts have been scattered all across the area. """,
				"image_path": "",
				"locked": false,
			},
			{
				"title": "???",
				"body_text": "",
				"image_path": "",
				"locked": true,
			},
		],
	},
]

const LEFT_WIDTH      := 400
const MAIN_TAB_HEIGHT := 52
const ENTRY_HEIGHT    := 42
const LOCKED_MODULATE := Color.LIGHT_GRAY

# Image Place Holders
var modulate_colors: Array[Color] = [
	Color.SEASHELL,
	Color.LIGHT_SKY_BLUE,
	Color.LIGHT_GREEN,
	Color.LIGHT_GOLDENROD,
	Color.LIGHT_PINK,
	Color.LIGHT_CORAL,
]

var active_category: int = 0
var active_entry: int = -1
var category_buttons: Array = []
var entry_list: VBoxContainer
var image_rect: TextureRect
var hint_label: Label
var entry_nodes: Array = []

func _ready() -> void:
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ui)
	build_layout(ui)
	select_category(0)

##  get_node("PauseScreen/StuffTab").unlock_entry("Animals", "Wolf")
func unlock_entry(category_name: String, entry_title: String) -> void:
	for cat in categories:
		if cat["name"] == category_name:
			for entry in cat["entries"]:
				if entry["title"] == entry_title:
					entry["locked"] = false
	if category_index(category_name) == active_category:
		select_category(active_category)

func lock_entry(category_name: String, entry_title: String) -> void:
	for cat in categories:
		if cat["name"] == category_name:
			for entry in cat["entries"]:
				if entry["title"] == entry_title:
					entry["locked"] = true
	if category_index(category_name) == active_category:
		select_category(active_category)

## Returns true if the entry is currently unlocked.
func is_unlocked(category_name: String, entry_title: String) -> bool:
	for cat in categories:
		if cat["name"] == category_name:
			for entry in cat["entries"]:
				if entry["title"] == entry_title:
					return not entry.get("locked", false)
	return false

func build_layout(ui: Control) -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	ui.add_child(margin)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	margin.add_child(root)

	root.add_child(make_top_bar())

	var hbox := HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 0)
	root.add_child(hbox)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(LEFT_WIDTH, 0)
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN   
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hbox.add_child(scroll)

	entry_list = VBoxContainer.new()
	entry_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry_list.add_theme_constant_override("separation", 0)
	scroll.add_child(entry_list)

	var sep := VSeparator.new()
	sep.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(sep)

	var right := Panel.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(right)

	image_rect = TextureRect.new()
	image_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	right.add_child(image_rect)

	hint_label = Label.new()
	hint_label.text = "Select an entry to view details"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	right.add_child(hint_label)

func make_top_bar() -> Control:
	var bar := PanelContainer.new()
	bar.custom_minimum_size = Vector2(0, MAIN_TAB_HEIGHT)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	bar.add_child(hbox)

	category_buttons.clear()

	for i in categories.size():
		var cat: Dictionary = categories[i]
		var btn := Button.new()
		btn.text = cat["name"]
		btn.toggle_mode = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 15)
		hbox.add_child(btn)
		category_buttons.append(btn)

		var idx := i
		btn.toggled.connect(func(on: bool) -> void:
			if on and active_category != idx:
				select_category(idx)
			else:
				btn.set_pressed_no_signal(true)
		)

	return bar

func select_category(index: int) -> void:
	active_category = index
	active_entry = -1
	clear_image()

	for i in category_buttons.size():
		category_buttons[i].set_pressed_no_signal(i == index)

	for child in entry_list.get_children():
		child.queue_free()
	entry_nodes.clear()

	var entries: Array = categories[index]["entries"]
	for i in entries.size():
		var node := make_entry(index, i, entries[i])
		entry_list.add_child(node)
		entry_nodes.append(node)

func make_entry(cat_idx: int, entry_idx: int, data: Dictionary) -> VBoxContainer:
	var locked: bool = data.get("locked", false)

	var wrapper := VBoxContainer.new()
	wrapper.add_theme_constant_override("separation", 0)
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn := Button.new()
	btn.text = data["title"]
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.toggle_mode = not locked
	btn.disabled = locked
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, ENTRY_HEIGHT)
	btn.add_theme_font_size_override("font_size", 13)

	var icon := Label.new()
	icon.text = "🔒" if locked else "▼"
	icon.vertical_alignment  = VERTICAL_ALIGNMENT_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.add_theme_font_size_override("font_size", 11)

	if locked:
		btn.modulate  = LOCKED_MODULATE
		icon.modulate = LOCKED_MODULATE

	row.add_child(btn)
	row.add_child(icon)
	wrapper.add_child(row)

	var body := MarginContainer.new()
	body.visible = false
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("margin_left", 10)
	body.add_theme_constant_override("margin_right", 10)
	body.add_theme_constant_override("margin_top", 6)
	body.add_theme_constant_override("margin_bottom", 6)

	var label := Label.new()
	label.text = data.get("body_text", "")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	body.add_child(label)
	wrapper.add_child(body)

	wrapper.set_meta("btn", btn)
	wrapper.set_meta("body", body)
	wrapper.set_meta("icon", icon)

	if not locked:
		btn.toggled.connect(func(on: bool) -> void:
			on_entry_toggled(cat_idx, entry_idx, on, body, icon)
		)

	return wrapper

func on_entry_toggled(cat_idx: int, entry_idx: int, on: bool,
		body: Control, icon: Label) -> void:
	if on:
		if active_entry >= 0 and active_entry != entry_idx:
			var prev: VBoxContainer = entry_nodes[active_entry]
			prev.get_meta("btn").button_pressed = false
			prev.get_meta("body").visible = false
			prev.get_meta("icon").text = "▼"

		active_entry = entry_idx
		body.visible  = true
		icon.text = "▲"
		show_image(cat_idx, entry_idx)
	else:
		body.visible  = false
		icon.text = "▼"
		if active_entry == entry_idx:
			active_entry = -1
			clear_image()

func show_image(cat_idx: int, entry_idx: int) -> void:
	hint_label.visible = false
	var path: String = categories[cat_idx]["entries"][entry_idx]["image_path"]
	if path != "" and ResourceLoader.exists(path):
		image_rect.texture = load(path)
	else:
		#Pick random color if no image
		var color: Color = modulate_colors[(cat_idx * 3 + entry_idx) % modulate_colors.size()]
		image_rect.texture = solid_color(color)
	image_rect.modulate = Color.WHITE

func clear_image() -> void:
	image_rect.texture = null
	hint_label.visible = true

func solid_color(color: Color) -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func category_index(cat_name: String) -> int:
	for i in categories.size():
		if categories[i]["name"] == cat_name:
			return i
	return -1
