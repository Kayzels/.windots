local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local opacity = 0.92

config.default_prog = { "pwsh" }

local tokyo_scheme = wezterm.get_builtin_color_schemes()["tokyonight_moon"]
tokyo_scheme.background = "#1d262a"

config.color_schemes = {
	["tokyonight_moon"] = tokyo_scheme,
}

local use_back = true

---@param appearance string
---@return { scheme: string, img: string}
local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return { scheme = "tokyonight_moon", img = os.getenv("WindotsRepo") .. "\\wezterm\\images\\back_dark.png" }
	else
		return { scheme = "catppuccin-latte", img = os.getenv("WindotsRepo") .. "\\wezterm\\images\\back_light.png" }
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	---@type string
	local appearance = window:get_appearance()
	local new_vals = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= new_vals.scheme then
		overrides.color_scheme = new_vals.scheme
	end
	if use_back and not overrides.background then
		overrides.background = {
			{
				source = {
					File = new_vals.img,
				},
				height = "Cover",
			},
		}
	else
		if not use_back and overrides.background then
			overrides.background = nil
		end
	end
	window:set_config_overrides(overrides)
end)

config.front_end = "WebGpu"

config.use_fancy_tab_bar = true

config.font = wezterm.font_with_fallback({
	{
		family = "Maple Mono Seven NF",
		harfbuzz_features = { "zero", "cv01", "cv03" },
	},
	{
		family = "JetBrainsMono Nerd Font",
		weight = "Medium",
		harfbuzz_features = { "cv08", "cv12", "cv14" },
	},
	"Cambria Math",
})
config.font_size = 11.0
config.adjust_window_size_when_changing_font_size = false
config.font_rules = {
	-- Sticking with Maple Mono NF for now, but Version 6, not 7, because cursive seems to be gone in 7.
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

-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = "a", mods = "ALT", timeout_milliseconds = 2000 }

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
		key = "f",
		mods = "LEADER",
		action = wezterm.action.EmitEvent("toggle-focus-mode"),
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
	{
		key = "a",
		mods = "LEADER|ALT",
		action = wezterm.action.SendKey({ key = "a", mods = "ALT" }),
	},
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
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

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Not found"
end

wezterm.log_info(get_appearance())

return config
