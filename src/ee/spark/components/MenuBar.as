package ee.spark.components
{
	import spark.layouts.HorizontalLayout;
	
	public class MenuBar extends Menu
	{
		private var _clearSelectionPending:Boolean;
		
		public function MenuBar()
		{
			layout = new HorizontalLayout();
			preventSelection = false;
		}
		
		override protected function menuItemClickHandler(e:MenuEvent):void
		{
			super.menuItemClickHandler(e);
			
			selectedIndex = -1;
			callLater(invalidateProperties);
		}
	}
}