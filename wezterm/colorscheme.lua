local M = {}

M.scheme = "tokyonight_moon"

local back_dark = os.getenv("WindotsRepo") .. "\\wezterm\\images\\back_dark.png"
local back_light = os.getenv("WindotsRepo") .. "\\wezterm\\images\\back_light.png"

M.useBack = true

local function setBack(config, img)
	config.background = {
		{
			source = {
				File = img,
			},
			height = "Cover",
		},
	}
end
function M.apply_to_config(config)
	config.color_scheme = M.scheme
	if not M.useBack then
		return
	end
	if config.color_scheme == "tokyonight_moon" then
		setBack(config, back_dark)
	else
		setBack(config, back_light)
	end
end

return M
