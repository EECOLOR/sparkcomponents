package ee.spark.components.support
{
	import ee.spark.components.SkinnableItemRenderer;

	/**
	 * Indicates the branch is open.
	 */
	[SkinState("open")]	
	
	public class BranchItem extends LeafItem
	{
		private var _open:Boolean;
		
		public function BranchItem()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			if (_open) return "open";
			
			return super.getCurrentSkinState();
		}
		
		/**
		 * If set to true will change the skin state to open
		 */
		public function get open():Boolean
		{
			return _open;
		}
		
		public function set open(value:Boolean):void
		{
			if (_open != value)
			{
				_open = value;
				invalidateSkinState();
			}
		}		
	}
}