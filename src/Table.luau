return function(node)
	-- to make output beautiful
	local function tab(amt)
		local str = ""
		for _ = 1, amt do
			str ..= "\t"
		end
		return str
	end

	local cache, stack, output = {}, {}, {}
	local depth = 1
	local outputStr = "{\n"

	while true do
		local size = 0
		for _, _ in pairs(node) do
			size += 1
		end

		local curIndex = 1
		for k, v in pairs(node) do
			if (cache[node] == nil) or (curIndex >= cache[node]) then
				if string.find(outputStr, "}", outputStr:len()) then
					outputStr ..= ",\n"
				elseif not (string.find(outputStr, "\n", outputStr:len())) then
					outputStr ..= "\n"
				end

				-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
				table.insert(output, outputStr)
				outputStr = ""

				local key
				if type(k) == "number" or type(k) == "boolean" then
					key = "[" .. tostring(k) .. "]"
				else
					key = tostring(k)
				end

				if type(v) == "number" or type(v) == "boolean" then
					outputStr ..= tab(depth) .. key .. " = " .. tostring(v)
				elseif type(v) == "table" then
					outputStr ..= tab(depth) .. key .. " = {\n"
					table.insert(stack, node)
					table.insert(stack, v)
					cache[node] = curIndex + 1
					break
				else
					outputStr ..= tab(depth) .. key .. " = '" .. tostring(v) .. "'"
				end

				if curIndex == size then
					outputStr ..= "\n" .. tab(depth - 1) .. "}"
				else
					outputStr ..= ","
				end
			else
				-- close the table
				if curIndex == size then
					outputStr ..= "\n" .. tab(depth - 1) .. "}"
				end
			end

			curIndex += 1
		end

		if #stack > 0 then
			node = stack[#stack]
			stack[#stack] = nil
			depth = cache[node] == nil and depth + 1 or depth - 1
		else
			break
		end
	end

	-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
	table.insert(output, outputStr)
	outputStr = table.concat(output)

	print(outputStr)
end
