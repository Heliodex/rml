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
local Fusion = require(script.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local function UICorner(corner)
	return New "UICorner" {
		CornerRadius = UDim.new(corner or 0.2, 0),
	}
end

New "TextButton" {
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.9),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Text = "yeah",
	Parent = Widget,

	BackgroundColor3 = Color3.new(),
	TextColor3 = Color3.new(1, 1, 1),

	[OnEvent "Activated"] = function()
		local selection = Selection:get()[1]
		if selection and selection:IsA "LuaSourceContainer" then
			Parse(selection)
		else
			warn "invalid selection"
		end
	end,

	[Children] = UICorner(),
}
