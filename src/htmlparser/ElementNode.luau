local Set = {}
Set.mt = { __index = Set }

function Set:new(values)
	local instance = {}
	local isSet
	if getmetatable(values) == Set.mt then
		isSet = true
	end

	if type(values) == "table" then
		if not isSet and #values > 0 then
			for _, v in ipairs(values) do
				instance[v] = true
			end
		else
			for k in pairs(values) do
				instance[k] = true
			end
		end
	elseif values ~= nil then
		instance = { [values] = true }
	end
	return setmetatable(instance, Set.mt)
end

function Set:add(e)
	if e ~= nil then
		self[e] = true
	end

	return self
end

function Set:remove(e)
	if e ~= nil then
		self[e] = nil
	end

	return self
end

function Set:tolist()
	local res = {}
	for k in pairs(self) do
		table.insert(res, k)
	end
	return res
end

-- Set.to_list = Set.tolist

Set.mt.__add = function(a, b)
	local res, a2, b2 = Set:new(), Set:new(a), Set:new(b)
	for k in pairs(a2) do
		res[k] = true
	end
	for k in pairs(b2) do
		res[k] = true
	end
	return res
end

-- Subtraction
Set.mt.__sub = function(a, b)
	local res, a2, b2 = Set:new(), Set:new(a), Set:new(b)
	for k in pairs(a2) do
		res[k] = true
	end
	for k in pairs(b2) do
		res[k] = nil
	end
	return res
end

-- Intersection
Set.mt.__mul = function(a, b)
	local res, a2 = Set:new(), Set:new(a)
	for k in pairs(a2) do
		res[k] = b[k]
	end
	return res
end

-- -- String representation
-- Set.mt.__tostring = function(set)
-- 	local s = "{"
-- 	local sep = ""
-- 	for k in pairs(set) do
-- 		s ..= sep .. tostring(k)
-- 		sep = ", "
-- 	end
-- 	return s .. "}"
-- end

local ElementNode = {}
ElementNode.mt = { __index = ElementNode }
function ElementNode:new(index, nameortext, node, descend, openstart, openend)
	local instance = {
		index = index,
		name = nameortext,
		level = 0,
		parent = nil,
		root = nil,
		nodes = {},
		_openstart = openstart,
		_openend = openend,
		_closestart = openstart,
		_closeend = openend,
		attributes = {},
		id = nil,
		deepernodes = Set:new(),
		deeperelements = {},
		deeperattributes = {},
	}

	instance.attrs = instance.attributes
	instance.children = instance.nodes
	instance.descendants = instance.deepernodes
	instance.descendant_elements = instance.deeperelements
	instance.descendant_attrs = instance.deeperattributes

	if not node then
		instance.name = "root"
		instance.root = instance
		instance._text = nameortext
		local length = string.len(nameortext)
		instance._openstart, instance._openend = 1, length
		instance._closestart, instance._closeend = 1, length
	elseif descend then
		instance.root = node.root
		instance.parent = node
		instance.level = node.level + 1
		table.insert(node.nodes, instance)
	else
		instance.root = node.root
		instance.parent = node.parent or node -- XXX: adds some safety but needs more testing for heisenbugs in corner cases
		instance.level = node.level
		table.insert(
			(node.parent and node.parent.nodes or node.nodes),
			instance
		) -- XXX: see above about heisenbugs
	end
	return setmetatable(instance, ElementNode.mt)
end

function ElementNode:text()
	return string.sub(self.root._text, self._openstart, self._closeend)
end
-- ElementNode.gettext = ElementNode.text

-- function ElementNode:settext(c)
-- 	self.root._text = c
-- end

-- function ElementNode:textonly()
-- 	return (self:text():gsub("<[^>]*>", ""))
-- end

-- function ElementNode:content()
-- 	return string.sub(self.root._text, self._openend + 1, self._closestart - 1)
-- end
-- ElementNode.getcontent = ElementNode.content

function ElementNode:addattribute(k, v)
	self.attributes[k] = v
end

local function insert(table, name, node)
	table[name] = table[name] or Set:new()
	table[name]:add(node)
end

function ElementNode:close(closestart, closeend)
	if closestart and closeend then
		self._closestart, self._closeend = closestart, closeend
	end
	-- inform hihger level nodes about this element's existence in their branches
	local node = self
	while true do
		node = node.parent
		if not node then
			break
		end
		node.deepernodes:add(self)
		insert(node.deeperelements, self.name, self)
		for k in pairs(self.attributes) do
			insert(node.deeperattributes, k, self)
		end
	end
end

-- local function escape(s)
-- 	-- escape all ^, $, (, ), %, ., [, ], *, +, - , and ? with a % prefix
-- 	return string.gsub(s, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%" .. "%1")
-- end

-- local function select(self, s)
-- 	if not s or type(s) ~= "string" or s == "" then
-- 		return Set:new()
-- 	end
-- 	local sets = {
-- 		[""] = self.deeperelements,
-- 		["["] = self.deeperattributes,
-- 	}
-- 	local function match(t, w)
-- 		local m, e, v
-- 		if t == "[" then
-- 			w, m, e, v = string.match(
-- 				w,
-- 				"([^=|%*~%$!%^]+)" -- w = 1 or more characters up to a possible "=", "|", "*", "~", "$", "!", or "^"
-- 					.. "([|%*~%$!%^]?)" -- m = an optional "|", "*", "~", "$", "!", or "^", preceding the optional "="
-- 					.. "(=?)" -- e = the optional "="
-- 					.. "(.*)" -- v = anything following the "=", or else ""
-- 			)
-- 		end
-- 		local matched = Set:new(sets[t][w])
-- 		-- attribute value selectors
-- 		if e == "=" then
-- 			if #v < 2 then
-- 				v = "'" .. v .. "'"
-- 			end -- values should be quoted
-- 			v = string.sub(v, 2, #v - 1) -- strip quotes
-- 			if m == "!" then
-- 				matched = Set:new(self.deepernodes)
-- 			end -- include those without that attribute
-- 			for node in pairs(matched) do
-- 				local a = node.attributes[w]

-- 				if
-- 					(m == "" and a ~= v) -- equals
-- 					or (m == "!" and a == v) -- not equals
-- 					or (m == "|" and string.match(a, "^[^-]*") ~= v) -- prefix
-- 					or (m == "*" and string.match(a, escape(v)) ~= v) -- contains
-- 					or (m == "^" and string.match(a, "^" .. escape(v)) ~= v) -- starts with
-- 					or (m == "$" and string.match(a, escape(v) .. "$") ~= v) -- ends with
-- 				then
-- 					matched:remove(node)
-- 					-- word
-- 				elseif m == "~" then
-- 					matched:remove(node)
-- 					for word in string.gmatch(a, "%S+") do
-- 						if word == v then
-- 							matched:add(node)
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end -- for node
-- 		end -- if v
-- 		return matched
-- 	end

-- 	local subjects, resultset, childrenonly = Set:new { self }
-- 	for part in string.gmatch(s, "%S+") do
-- 		repeat
-- 			if part == ">" then
-- 				childrenonly = true --[[goto nextpart]]
-- 				break
-- 			end
-- 			resultset = Set:new()
-- 			for subject in pairs(subjects) do
-- 				local star = subject.deepernodes
-- 				if childrenonly then
-- 					star = Set:new(subject.nodes)
-- 				end
-- 				resultset += star
-- 			end
-- 			childrenonly = false
-- 			if part == "*" then --[[goto nextpart]]
-- 				break
-- 			end
-- 			local excludes, filter = Set:new()
-- 			local pos = 0
-- 			while true do
-- 				local switch, stype, name, eq, quote
-- 				_, pos, switch, stype, name, eq, quote = string.find(
-- 					part,
-- 					"(%(?%)?)" -- switch = a possible ( or ) switching the filter on or off
-- 						.. "([:%[#.]?)" -- stype = a possible :, [, #, or .
-- 						.. "([%w-_\\]+)" -- name = 1 or more alfanumeric chars (+ hyphen, reverse slash and uderscore)
-- 						.. "([|%*~%$!%^]?=?)" -- eq = a possible |=, *=, ~=, $=, !=, ^=, or =
-- 						.. "(['\"]?)", -- quote = a ' or " delimiting a possible attribute value
-- 					pos + 1
-- 				)

-- 				if not name then
-- 					break
-- 				end

-- 				repeat
-- 					if ":" == stype then
-- 						filter = name
-- 						--[[goto nextname]]
-- 						break
-- 					end

-- 					if ")" == switch then
-- 						filter = nil
-- 					end

-- 					if "[" == stype and "" ~= quote then
-- 						local value
-- 						_, pos, value = string.find(
-- 							part,
-- 							`(%b{quote}{quote})]`,
-- 							pos
-- 						)
-- 						name ..= eq .. value
-- 					end
-- 					local matched = match(stype, name)
-- 					if filter == "not" then
-- 						excludes += matched
-- 					else
-- 						resultset *= matched
-- 					end
-- 					-- ::nextname::
-- 					break
-- 				until true
-- 			end
-- 			resultset -= excludes
-- 			subjects = Set:new(resultset)
-- 			-- ::nextpart::
-- 			break
-- 		until true
-- 	end
-- 	resultset = resultset:tolist()
-- 	table.sort(resultset, function(a, b)
-- 		return a.index < b.index
-- 	end)
-- 	return resultset
-- end

-- function ElementNode:select(s)
-- 	return select(self, s)
-- end
-- ElementNode.mt.__call = select

return ElementNode
