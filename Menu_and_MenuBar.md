# Usage #

```
<?xml version="1.0" encoding="utf-8"?>
<s:HGroup xmlns:fx="http://ns.adobe.com/mxml/2009" 
		 xmlns:s="library://ns.adobe.com/flex/spark" 
		 xmlns:mx="library://ns.adobe.com/flex/mx" xmlns:components="ee.spark.components.*">
	<fx:Declarations>
		<s:XMLListCollection id="xmlListCollection">
			<fx:XMLList xmlns="">
				<menuItem label="one">
					<menuItem label="one - one" />
					<menuItem label="one - two" />
					<menuItem label="one - three" />
				</menuItem>
				<menuItem label="two" />
				<menuItem separator="true" />
				<menuItem label="three">
					<menuItem label="three - one" />
					<menuItem label="three - two" />
					<menuItem separator="true" />
					<menuItem label="three - three" />
					<menuItem label="three - four" />
					<menuItem separator="true" />
					<menuItem label="three - five" />
					<menuItem label="three - six" />
					<menuItem separator="true" />
					<menuItem label="three - seven" />
					<menuItem label="three - eight" />
					<menuItem separator="true" />
					<menuItem label="three - nine" />
					<menuItem label="three - ten" />
				</menuItem>
				<menuItem label="four">
					<menuItem label="four - one" />
					<menuItem label="four - two" />
					<menuItem label="four - three very long label to test width shizzle">
						<menuItem label="four - three - one" />
						<menuItem label="four - three - two" />
						<menuItem label="four - three - three" />
					</menuItem>
					<menuItem label="four - four" />
					<menuItem label="four - five">
						<menuItem label="four - five - one" />
						<menuItem label="four - five - two" />
						<menuItem label="four - five - three" />
					</menuItem>
				</menuItem>
				<menuItem label="five">
					<menuItem label="five - one very long label to test jump shizzle" />
				</menuItem>
			</fx:XMLList>
		</s:XMLListCollection>
	</fx:Declarations>

	<components:Menu dataProvider="{xmlListCollection}" menuItemClick="trace(event.item.toXMLString());" />
	<components:MenuBar dataProvider="{xmlListCollection}" menuItemClick="trace(event.item.toXMLString());" />
	
</s:HGroup>
```