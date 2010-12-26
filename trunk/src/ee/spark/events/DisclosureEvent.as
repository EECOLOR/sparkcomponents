package ee.spark.events
{
	import flash.events.Event;
	
	public class DisclosureEvent extends Event
	{
		static public const DISCLOSURE_CHANGE:String = "disclosureChange";
		
		private var _open:Boolean;
		
		public function DisclosureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, open:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new DisclosureEvent(type, bubbles, cancelable, open);
		}
		
		public function get open():Boolean
		{
			return _open;
		}
	}
}