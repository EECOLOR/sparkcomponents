# Usage #

```
<?xml version="1.0" encoding="utf-8"?>
<s:HGroup xmlns:fx="http://ns.adobe.com/mxml/2009" 
		  xmlns:s="library://ns.adobe.com/flex/spark" 
		  xmlns:mx="library://ns.adobe.com/flex/mx" xmlns:components="ee.spark.components.*" xmlns:support="tests.support.*">
	<!-- test data -->
	<fx:Declarations>
		<s:ArrayList id="arrayList">
			<fx:Object label="one" property="1" />
			<fx:Object label="two" property="2" />
			<fx:Object label="three" property="3" />
			<fx:Object label="four" property="4" />
		</s:ArrayList>
	</fx:Declarations>	
	
	<s:VGroup>
		<s:Label text="default skin" />
		<s:List dragEnabled="true" 
				itemRenderer="ee.spark.components.SkinnableItemRenderer"
				dataProvider="{arrayList}" />
	</s:VGroup>
	
	<s:VGroup>
		<s:Label text="test skin" />
		<s:List dragEnabled="true"
				dataProvider="{arrayList}">
			<!-- you can also set skin class using styles -->
			<s:itemRenderer>
				<fx:Component>
					<components:SkinnableItemRenderer skinClass="tests.skins.TestItemRendererSkin" />
				</fx:Component>
			</s:itemRenderer>
		</s:List>
	</s:VGroup>
	
	<s:VGroup>
		<s:Label text="custom renderer" />
		<s:List dragEnabled="true"
				dataProvider="{arrayList}">
			<!-- you can also set skin class using styles -->
			<s:itemRenderer>
				<fx:Component>
					<support:CustomSkinnableItemRenderer skinClass="tests.skins.TestItemRendererSkin" />
				</fx:Component>
			</s:itemRenderer>
		</s:List>
	</s:VGroup>
	
	<s:VGroup>
		<s:Label text="spark original" />
		<s:List dragEnabled="true" 
				dataProvider="{arrayList}" />
	</s:VGroup>
</s:HGroup>
```

_tests.support.CustomSkinnableItemRenderer_
```
package tests.support
{
	import ee.spark.components.SkinnableItemRenderer;
	
	import spark.components.ComboBox;
	import spark.components.Label;
	import spark.skins.spark.ButtonSkin;
	import spark.skins.spark.ComboBoxSkin;
	import spark.skins.spark.DropDownListSkin;
	
	public class CustomSkinnableItemRenderer extends SkinnableItemRenderer
	{
		[SkinPart(required="false")]
		public var propertyDisplay:Label;
		
		public function CustomSkinnableItemRenderer()
		{
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case propertyDisplay:
				{
					if (data) propertyDisplay.text = data.property;
					break;
				}
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			if (propertyDisplay) propertyDisplay.text = value.property;
		}
	}
}
```