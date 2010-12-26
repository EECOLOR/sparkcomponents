package ee.spark.components.support
{
	import ee.spark.events.DisclosureEvent;
	
	import flash.events.Event;
	
	import spark.components.ToggleButton;

	[Event(name="disclosureChange", type="ee.spark.events.DisclosureEvent")]
	
	public class TreeBranchItem extends BranchItem
	{
		[SkinPart(required="true")]
		public var disclosureButton:ToggleButton;
		
		public function TreeBranchItem()
		{
			super();
		}
		
		/**
		 * Overridden in order to add listeners to the disclosureButton
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case disclosureButton:
				{
					disclosureButton.addEventListener(Event.CHANGE, _disclosureButtonChangeHandler);
					break;
				}
			}
		}
		
		/**
		 * Overridden in order to add listeners from the disclosureButton.
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case disclosureButton:
				{
					disclosureButton.removeEventListener(Event.CHANGE, _disclosureButtonChangeHandler);
					break;
				}
			}
			
			super.partRemoved(partName, instance);
		}
		
		private function _disclosureButtonChangeHandler(e:Event):void
		{
			e.stopPropagation();
			
			dispatchEvent(new DisclosureEvent(DisclosureEvent.DISCLOSURE_CHANGE, false, false, disclosureButton.selected));
		}
	}
}