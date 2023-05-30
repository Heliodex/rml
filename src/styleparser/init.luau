return function(source: string)
	type Node = {
		_name: string,
		_id: number,
		[number]: { Node },
		-- [string]: string, -- Cannot have more than one table indexer
	}

	local tree: { Node } = {}
	local lastTags: { Node } = {}
	local id = 1

	for _, str in pairs(string.split(source, "\n")) do
		-- Number of tabs at the start of the line
		local tabs = #(string.match(str, "^\t*") or "")
		str = string.sub(str, tabs + 1)

		if string.match(str, "^%s*%w+%s*$") then
			-- Line is a tag
			local tag: Node = {
				_name = string.match(str, "^%s*(%w+)%s*$"),
				_id = id,
			}

			local len = #lastTags

			if tabs < len then
				for i = len, tabs, -1 do
					table.remove(lastTags, i)
				end
			end

			local walk = tree
			for _, v in ipairs(lastTags) do
				local find

				for i, node in pairs(walk) do
					if node._id == v._id then
						find = i
						break
					end
				end

				walk = walk[find]
			end

			table.insert(lastTags, tag)
			table.insert(walk, tag)

			-- print(tag._name, lastTabs)
		elseif string.match(str, "^%s*%w+%s*:%s*.+%s*") then
			-- Line is a property, split by { key: value }
			local props = string.split(
				string.match(str, "^%s*(%w+%s*:%s*.+)%s*") or "",
				":"
			)
			for i, v in ipairs(props) do
				props[i] = string.gsub(v, "^%s*(.*)%s*$", "%1")
			end

			lastTags[#lastTags][props[1]] = props[2]
		end

		id += 1
	end

	return tree
end
