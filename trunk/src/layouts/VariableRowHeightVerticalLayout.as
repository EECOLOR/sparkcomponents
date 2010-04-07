package layouts
{
	import ee.spark.components.support.MenuSeparator;
	import ee.spark.components.support.MinimalLayoutElement;
	
	import mx.core.ILayoutElement;
	
	import spark.layouts.VerticalLayout;
	
	public class VariableRowHeightVerticalLayout extends VerticalLayout
	{
		static private const MINIMAL_LAYOUT_ELEMENT:ILayoutElement = new MenuSeparator();
		
		public function VariableRowHeightVerticalLayout()
		{
		}
		
		override public function get typicalLayoutElement():ILayoutElement
		{
			if (useVirtualLayout) return MINIMAL_LAYOUT_ELEMENT;
			
			return super.typicalLayoutElement;
		}
	}
}