--[[
	Selected word marker module for Textadept.
	Written by: Simon Lundmark

	Copyright (c) 2014 Simon Lundmark, Pixeldiet Entertainment AB.

	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
		claim that you wrote the original software. If you use this software
		in a product, an acknowledgement in the product documentation would be
		appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
		misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution. 
]]--

local M = {}

local WORD_INDICATOR = _SCINTILLA.next_indic_number()
buffer.indic_style[WORD_INDICATOR] = buffer.INDIC_BOX
buffer.indic_fore[WORD_INDICATOR] = "0xAAAAAA"

local allowed_characters = {
	['.'] = true,
	[','] = true,
	[':'] = true,
	[' '] = true,
	['\n'] = true,
	['\t'] = true,
	['('] = true,
	[')'] = true,
	['['] = true,
	[']'] = true,
}

local has_markers
local last_selected_text

local function remove_all_markers()
	has_markers = nil
	buffer.indicator_current = WORD_INDICATOR
	local length = buffer.length
	buffer:indicator_clear_range(0, length)
end

local function update_marker_selection()
	local selected_text, index = buffer:get_sel_text()
	if selected_text ~= last_selected_text then
		if has_markers then
			remove_all_markers()
		end
		
		last_selected_text = selected_text
			
		if selected_text and selected_text ~= "" and string.len(selected_text) >= 3 then
			buffer.indicator_current = WORD_INDICATOR
			local buffer_text = buffer:get_text()
			local index = 0

			has_markers = true

			local found_start, found_end = string.find(buffer_text, selected_text, index, true)
			while(found_start and found_end) do
				index = found_end
				local letter_before = string.sub(buffer_text, found_start-1, found_start-1)
				local letter_after = string.sub(buffer_text, found_end+1, found_end+1)
				if (not letter_before or allowed_characters[letter_before]) and
					(not letter_after or allowed_characters[letter_after]) then
					buffer:indicator_fill_range(found_start-1, found_end - found_start+1)
				end
				found_start, found_end = string.find(buffer_text, selected_text, index, true)
			end
		end
	end
end

-- Unfortunately this event is called very very often, but since we want to act on 
-- not only user input that's feeded by the ordinary event, but things such as deselection
-- which comes from doing simple scintilla-keybinds that aren't really feeded into textadept,
-- this is the place we need to check for updates. 
events.connect(events.UPDATE_UI, update_marker_selection)

-- Actually this exposes nothing. Maybe there is something that we want to expose, like settings?
return M
