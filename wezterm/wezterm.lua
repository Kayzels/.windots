local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local opacity = 0.92

config.default_prog = { "pwsh" }

local scheme = wezterm.get_builtin_color_schemes()["tokyonight_moon"]
scheme.background = "#1d262a"

config.color_schemes = {
	["tokyonight_moon"] = scheme,
}

local colorscheme = require("colorscheme")
colorscheme.apply_to_config(config)

config.front_end = "WebGpu"

config.use_fancy_tab_bar = true

config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Medium" },
	"Cambria Math",
})
config.font_size = 10.0
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({ family = "Maple Mono NF", weight = "Bold", style = "Italic" }),
	},
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font({ family = "Maple Mono NF", weight = "DemiBold", style = "Italic" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({ family = "Maple Mono NF", style = "Italic" }),
	},
}

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 530

config.bold_brightens_ansi_colors = "No"

config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

wezterm.on("toggle-focus-mode", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.enable_tab_bar == false then
		overrides.enable_tab_bar = true
	else
		overrides.enable_tab_bar = false
	end
	window:set_config_overrides(overrides)
end)

wezterm.on("toggle-acrylic", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if (not overrides.win32_system_backdrop) or (overrides.win32_system_backdrop == "Disable") then
		overrides.win32_system_backdrop = "Acrylic"
		overrides.window_background_opacity = opacity
	else
		overrides.win32_system_backdrop = "Disable"
		overrides.window_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)

config.keys = {
	{
		key = " ",
		mods = "CTRL",
		action = act.SendKey({
			key = " ",
			mods = "CTRL",
		}),
	},
	{
		key = " ",
		mods = "SHIFT",
		action = act.SendKey({
			key = " ",
			mods = "SHIFT",
		}),
	},
	{
		key = "Enter",
		mods = "CTRL",
		action = act.SendKey({
			key = "Enter",
			mods = "CTRL",
		}),
	},
	{
		key = "Enter",
		mods = "SHIFT",
		action = act.SendKey({
			key = "Enter",
			mods = "SHIFT",
		}),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = act.SendKey({
			key = "Tab",
			mods = "CTRL",
		}),
	},
	{
		key = "f",
		mods = "CTRL | SHIFT",
		action = wezterm.action.EmitEvent("toggle-focus-mode"),
	},
	{
		key = "a",
		mods = "ALT",
		action = wezterm.action.EmitEvent("toggle-acrylic"),
	},
	{
		key = "t",
		mods = "CTRL",
		action = act.SendKey({
			key = "t",
			mods = "CTRL",
		}),
	},
	{
		key = "c",
		mods = "ALT",
		action = act.SendKey({
			key = "c",
			mods = "ALT",
		}),
	},
}

config.mouse_bindings = {
	-- Right click to paste from clipboard
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(wezterm.action.ClearSelection, pane)
			else
				window:perform_action(wezterm.action({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

return config
