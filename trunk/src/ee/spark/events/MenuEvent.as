package ee.spark.events
{
	import flash.events.Event;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ListEvent;
	
	public class MenuEvent extends Event
	{
		static public const MENU_ITEM_CLICK:String = "menuItemClick";
		
		public var item:Object;
		
		public function MenuEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, item:Object=null)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
		override public function clone():Event
		{
			var menuEvent:MenuEvent = new MenuEvent(type, bubbles, cancelable, item);
			return menuEvent;
		}
	}
}