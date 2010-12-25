package ee.spark.events
{
	import flash.events.Event;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ListEvent;
	
	/**
	 * Event dispatched by HierarchicalList and it's subclasses
	 */
	public class ItemEvent extends Event
	{
		/**
		 * Dispatched when a leaf item is selected
		 */
		static public const ITEM_SELECT:String = "itemSelect";
		
		private var _item:Object;
		
		public function ItemEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, item:Object=null)
		{
			super(type, bubbles, cancelable);
			_item = item;
		}
		
		/**
		 * Overridden in order to clone the MenuEvent.
		 */
		override public function clone():Event
		{
			var itemEvent:ItemEvent = new ItemEvent(type, bubbles, cancelable, item);
			return itemEvent;
		}
		
		/**
		 * The related item
		 */
		public function get item():Object
		{
			return _item;
		}
	}
}