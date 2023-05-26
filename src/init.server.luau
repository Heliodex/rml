local Selection = game:GetService "Selection"

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left, --This can be changed
	false,
	false,
	200,
	200,
	150,
	150
)
local Widget = plugin:CreateDockWidgetPluginGui("rml", widgetInfo)
Widget.Title = "rml"

local toolbar = plugin:CreateToolbar "rml"
local toggle = toolbar:CreateButton("rml", "Toggle the rml panel", "")

toggle.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)

local Parse = require(script.Parse)

-- Basic instance creation function
function New(objectType: string)
	return function(dat)
		local obj = Instance.new(objectType)
		local parent

		for k, v in pairs(dat) do
			if type(k) == "string" then
				if k == "Parent" then
					parent = v
				else
					obj[k] = v
				end
			elseif type(k) == "number" and type(v) == "userdata" then
				v.Parent = obj
			end
		end

		obj.Parent = parent

		return obj
	end
end

(New "TextButton" {
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.9),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Text = "yeah",
	Parent = Widget,

	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(),
	TextColor3 = Color3.new(1, 1, 1),

	New "UICorner" {
		CornerRadius = UDim.new(0.2, 0),
	},
}).Activated:Connect(function()
	local selection = Selection:get()[1]
	if selection and selection:IsA "LuaSourceContainer" then
		Parse(selection)
	else
		warn "invalid selection"
	end
end)
