<script>
	print(textlabel)

	function x()
		print "Hello world!"
	end
</script>

<Frame Name="bruh" AnchorPoint={Vector2.new(0.5, 0.5)}>
	<Frame BackgroundTransparency="0.5">
		<ScrollingFrame Active>
			<TextLabel on:click={x} />
			<TextLabel bind:this={textlabel} />
		</ScrollingFrame>

		<TextLabel />
	</Frame>

	<TextLabel>
		<UIPadding />
	</TextLabel>
</Frame>

<Frame Name="frame2" Active AnchorPoint={Vector2.new(0.4, 0.4)}>
	<Frame BackgroundTransparency="0.5">
		<ScrollingFrame>
			<TextLabel />
		</ScrollingFrame>

		<TextLabel />
	</Frame>

	<TextLabel>
		<UIPadding />
	</TextLabel>
</Frame>