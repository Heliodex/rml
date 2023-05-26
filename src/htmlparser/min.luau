local prn = function(l, f, ...)
	local t = (" [%s] "):format(l:upper())
	print("[HTMLParser]" .. t .. f:format(...) .. "\n")
end

local err = function(f, ...)
	prn("e", f, ...)
end

local ElementNode = require(script.ElementNode)

local function parse(text, limit)
	text = tostring(text)
	limit = limit or 1000
	local tpl = false

	-- text = text:gsub("<!%-%-.-%-%->", "") -- Many chances commented code will have syntax errors, that'll lead to parser failures

	local tpr = {}

	-- search unused "invalid" bytes {{{
	local busy, i = {}, 0
	repeat
		local cc = string.char(i)
		if not (text:match(cc)) then
			if not tpr["<"] or not tpr[">"] then
				if not busy[i] then
					if not tpr["<"] then
						tpr["<"] = cc
					elseif not tpr[">"] then
						tpr[">"] = cc
					end
					busy[i] = true
				end -- if !busy
			else -- if < or >
				break
			end -- if < or >
		end -- text!match(cc)
		local skip = 1
		if i == 31 then
			skip = 96 -- ASCII
		end
		i += skip
	until i == 255
	i = nil
	--- }}}

	if not tpr["<"] or not tpr[">"] then
		err "Impossible to find at least two unused byte codes in this HTML-code. We need it to escape bracket-contained placeholders inside tags."
		err "Consider enabling 'keep_danger_placeholders' option (to silence this error, if parser wasn't failed with current HTML-code) or manually replace few random bytes, to free up the codes."
	end

	--	dbg("tpr[>] || tpr[] || #busy%d")

	-- g {{{
	local function g(id, ...)
		local arg = { ... }
		local orig = arg[id]
		arg[id] = arg[id]:gsub("(.)", tpr)
		if arg[id] ~= orig then
			tpl = true
		end
		return table.concat(arg)
	end
	-- g }}}

	-- tpl-placeholders and attributes {{{
	text = text
		:gsub(
			"(=[%s]-)" -- only match attr.values, and not random strings between two random apostrophs
				.. "(%b'')",
			function(...)
				return g(2, ...)
			end
		)
		:gsub(
			-- same for "
			'(=[%s]-)(%b"")',
			function(...)
				return g(2, ...)
			end
		) -- Escape "<"/">" inside attr.values (see issue #50)
		:gsub(
			"([^!]" -- with exclusion pattern (for example, to ignore comments, which aren't template placeholders, but can legally contain "<"/">" inside.
				.. ")([^>]+)" -- If matched, we want to escape '<'s if we meet them inside tag
				.. "(>)",
			function(...)
				return g(2, ...)
			end
		)
		:gsub(
			"("
				.. (tpr["<"] or "__FAILED__") -- Here we search for "<", we escaped in previous gsub (and don't break things if we have no escaping replacement)
				.. ")("
				.. "[^%w%s]" -- Capture templating symbol
				.. ")([%g%s]-)" -- match placeholder's content
				.. "(%2)(>)" -- placeholder's tail
				.. "([^>]*>)", -- remainings
			function(...)
				return g(5, ...)
			end
		)

	local index = 0
	local root = ElementNode:new(index, tostring(text))
	local node, descend, tpos, opentags = root, true, 1, {}
	local lastTags = {}

	while true do -- MainLoop {{{
		if index == limit then
			err(
				"Main loop reached loop limit (%d). Consider either increasing it or checking HTML-code for syntax errors",
				limit
			)
			break
		end
		-- openstart/tpos Definitions {{{
		local openstart, name
		openstart, tpos, name = root._text:find(
			"" -- an uncaptured starting "<"
				.. "([%w-]+)" -- name = the first word, directly following the "<"
				.. "[^\n]*\n", -- include, but not capture everything up to the next ">"
			tpos
		)
		if not name then
			break
		end
		-- Some more vars {{{
		index += 1
		local tag = ElementNode:new(
			index,
			tostring(name),
			(node or {}),
			descend,
			openstart,
			tpos
		)
		node = tag
		local tagloop
		local tagst, apos = tag:text(), 1
		while true do -- TagLoop {{{
			if tagloop == limit then
				err(
					"Tag parsing loop reached loop limit (%d). Consider either increasing it or checking HTML-code for syntax errors",
					limit
				)
				break
			end
			-- Attrs {{{
			local k, eq, quote, v
			_, apos, k, _, eq, _, quote = tagst:find(
				"%s+" -- some uncaptured space
					.. "([^%s:/]+)" -- k: an unspaced string up to an optional "=" or the "/" or ">"
					.. "([%s]-)" -- zero or more spaces
					.. "(:?)%s+" -- eq: the optional; "=", else ""
					.. "([%s]-)" -- zero or more spaces
					.. "(['\"]?)", -- quote: an optional "'" or '"' following the "=", or ""

				apos
			)

			if
				not k
				-- or k == "/"
				or k == ""
			then
				break
			end
			-- k is an attribute name
			print(k)

			-- Pattern {{{
			if eq == ":" then
				local pattern = "([^%s]*)"
				if quote ~= "" then
					pattern = `{quote}([^{quote}]*){quote}`
				end
				_, apos, v = tagst:find(pattern, apos)
			end

			v = v or ""
			if tpl then
				for rk, rv in pairs(tpr) do
					v = v:gsub(rv, rk)
				end
			end
			tag:addattribute(k, v)
			tagloop = (tagloop or 0) + 1
		end

		-- descend = true
		opentags[tag.name] = opentags[tag.name] or {}
		table.insert(opentags[tag.name], tag)
		table.insert(lastTags, tag.name)

		local closeend = tpos
		local closingloop
		while true do -- TagCloseLoop {{{
			if closingloop == limit then
				err(
					"Tag closing loop reached loop limit (%d). Consider either increasing it or checking HTML-code for syntax errors",
					limit
				)
				break
			end

			local closing
			_, closeend, closing = root._text:find("!([%a#]?)", closeend)

			print(closing)

			if closing ~= "#" then
				break
			end

			local lastTagName = lastTags[#lastTags]
			tag = table.remove(opentags[lastTagName] or {}) or tag -- kludges for the cases of closing void or non-opened tags
			table.remove(lastTags, #lastTags)

			-- closestart = root._text:find("!", closestart)
			-- tag:close(closestart, closeend + 1)
			node = tag.parent
			descend = true
			closingloop = (closingloop or 0) + 1
		end
	end
	if tpl then
		for k, v in pairs(tpr) do
			root._text = root._text:gsub(v, k)
		end
	end
	return root
end

return { parse = parse }
