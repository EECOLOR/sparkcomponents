package ee.spark.components.support
{
	import ee.spark.components.SkinnableItemRenderer;
	
	import flash.events.MouseEvent;

	public class MenuLeafItem extends SkinnableItemRenderer
	{
		public function MenuLeafItem()
		{
		}
		
		
		protected override function getCurrentSkinState():String
		{
			var s:String = super.getCurrentSkinState();
			//trace(label, s);
			return s;
		}

		
		override public function set showsCaret(value:Boolean):void
		{
			if (showsCaret != value)
			{
				super.showsCaret = value;
				
				trace("caret", value ? "to me" : "removed", label);
			}
		}
	}
}