<script>
	print(textlabel)

	function x()
		textlabel.BackgroundColor3 =
			if math.random(1, 2) == 1 then
				Color3.new(1, 0, 0)
			else
				Color3.new(0, 1, 0)
	end
</script>

<ScreenGui>
	<Frame
		Name="bru h"
		AnchorPoint={Vector2.new(0.5, 0.5)}
		Position={UDim2.fromScale(0.4, 0.4)}
		Size={UDim2.fromScale(0.5, 0.5)}
		BackgroundColor3={Color3.new(0.5, 0.5, 0.5)}>
		<UICorner 
			CornerRadius={UDim.new(0.05, 0)}
		/>
		<TextButton
			Position={UDim2.fromScale(0.3, 0.1)}
			Size={UDim2.fromScale(0.2, 0.2)}
			BackgroundColor3={Color3.new(1, 0, 1)}
			bind:this={textlabel}
			on:Activated={x}>
			Button
			<UICorner />
			<UIStroke
				ApplyStrokeMode="Border"
				Thickness={5}
				Color={Color3.new(0, 0, 1)}
			/>
		</TextButton>
	</Frame>
	<Frame
		Name="frame2"
		Active
		AnchorPoint={Vector2.new(0.5, 0.5)}
		Position={UDim2.fromScale(0.6, 0.6)}
		Size={UDim2.fromScale(0.5, 0.5)}>
		<TextLabel
			Position={UDim2.fromScale(0.1, 0.1)}
			Size={UDim2.fromScale(0.5, 0.1)}
			BackgroundColor3={Color3.new(0, 1, 1)}>
			Hello, world!
		</TextLabel>
		<UIGradient 
			Rotation={45}
			Color={ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 1, 0))}
		/>
	</Frame>
</ScreenGui>
