-- local Table = require(script.Parent.Table)
local htmlparser = require(script.Parent.htmlparser)

return function(selected)
	-- Ensure the entire script is inside a comment
	local source = string.match(selected.Source, "^%s*%-%-%[%[(.*)%]%]%s*$") or error "invalid script"
	local html = htmlparser.parse(source)
	selected:ClearAllChildren()
	html.instance = selected

	print "---------- parsing... ----------"

	local function children(e)
		if e.level > 0 then
			local s = pcall(function()
				local instance = Instance.new(e.name)
				instance.Name = e.name

				for a, v in pairs(e.attrs) do
					local s2 = pcall(function()
						instance[a] = v
					end)
					if not s2 then
						warn("Invalid attribute: " .. a .. " = " .. v)
					end
				end

				e.instance = instance
				instance.Parent = e.parent.instance
			end)
			if not s then
				error("Invalid instance name: " .. e.name)
			end

		end

		print(string.rep("\t", e.level + 1) .. e.name .. if #e.children > 0 then ":" else "")
		for _, v in ipairs(e.children) do
			children(v)
		end
	end

	children(html)
end
