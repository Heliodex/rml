local Table = require(script.Parent.Table)

return function(source)
	-- Ensure the entire script is inside a comment
	source = string.match(source, "^%s*%-%-%[%[(.*)%]%]%s*$")
	if not source then
		error "invalid script"
	end

	local rlines = {}
	for rawline in string.gmatch(source, "[^\n]+") do
		table.insert(rlines, rawline)
	end

	--[[
		This is an example snippet of a markup language used for creating user interfaces in Lua.

		itemA
			propertyA: abcde
			itemB
				propertyB: fghij
			itemC
				propertyC: klmno
				itemD
					propertyD: pqrst
					itemE
						propertyE: uvwxy
				itemF
					itemG
						propertyF: zabcd
		itemH
			propertyA: efghi

		It arranges the UI elements into a hierarchical structure with each element having properties, and each can have other elements as children.
		The code is then transformed into a Lua table of items, like this:

		{
			__children = {
				{
					__name = "itemA",
					propertyA = "abcde",
					__children = {
						{
							__name = "itemB",
							propertyB = "fghij",
						},
						{
							__name = "itemC",
							propertyC = "klmno",
							__children = {
								{
									__name = "itemD",
									propertyD = "pqrst",
									{
										__name = "itemE",
										propertyE = "uvwxy",
									},
								},
								{
									__name = "itemF",
									__children = { 
										{
											__name = "itemG",
											propertyF = "zabcd",
										}
									},
								},
							},
						},
					},
				},
				{
					__name = "itemH",
					propertyH = "efghi",
				},
			},
		}

		Write a function for converting "lines", a table of lines of markup, into a table like this.
		Use a system that makes it easy to maneuver up and down several levels of indentation, and to have multiple items 
		Make sure the system is able to easily differentiate between properties and children.
	]]

	local result = {}
	local current
	local stack = {}

	for i, line in ipairs(rlines) do
		local ctabs, child = string.match(line, "^(\t*)(%a+)$")
		local prop, value = string.match(line, "^\t*(%a+):%s*(.+)$")
		if child then
			-- child
			if current then
				if not current.__dontadd then
					table.insert(result, current)
				end
				table.insert(stack, current)
			end
			ctabs = #ctabs

			current = {
				__name = child,
				__line = i,
				__tabs = ctabs,
			}

			for i2 = #stack, 1, -1 do
				if stack[i2].__tabs + 1 == ctabs then
					print "ong"
					for i3 in pairs(result) do
						if result[i3] == stack[i2] then
							print "ongongong"
							result[i3].__children = result[i3].__children or {}
							table.insert(result[i3].__children, current)
							current.__dontadd = true -- seven fourty three am and my brain is a fried egg
							break
						end
					end
				end
			end
		elseif string.match(line, "^\t*%a+:%s*.+$") then
			-- property
			current[prop] = value
		else
			error("invalid syntax: " .. line)
		end
	end

	if not current.__dontadd then
		table.insert(result, current)
	end

	print(Table(result))
end
