local M = {}

M.scheme = "tokyonight_moon"

function M.apply_to_config(config)
	config.color_scheme = M.scheme
end

return M
