return {
	entry = function()
		local current = cx.active.current.hovered
		-- ya.manager_emit(current and current.cha.is_dir and "enter" or "open", { hovered = true })
		if not current.cha.is_dir then
			return
		end

		ya.manager_emit({ "enter", "paste", "leave" }, { hovered = true })
		-- ya.manager_emit("paste")
		-- ya.manager_emit("leave")
	end,
}
