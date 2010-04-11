package ee.spark.events
{
	import flash.events.Event;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ListEvent;
	
	/**
	 * Event dispatched by menu and it's subclasses
	 */
	public class MenuEvent extends Event
	{
		/**
		 * Dispatched when a menu leaf item is selected
		 */
		static public const MENU_ITEM_CLICK:String = "menuItemClick";
		
		public var item:Object;
		
		public function MenuEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, item:Object=null)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
		/**
		 * Overridden in order to clone the MenuEvent.
		 */
		override public function clone():Event
		{
			var menuEvent:MenuEvent = new MenuEvent(type, bubbles, cancelable, item);
			return menuEvent;
		}
	}
}