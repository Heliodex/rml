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

local Fusion = require(script.Fusion)
local New = Fusion.New

New "TextButton" {
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Text = "yeah",
	Parent = Widget,
}
