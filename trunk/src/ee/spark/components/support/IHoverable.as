package ee.spark.components.support
{
	/**
	 * Utility interface to detemine if a component has a hovered state
	 */
	public interface IHoverable
	{
		/**
		 * If set to to true, the component should display a hovered state.
		 */
		function get hovered():Boolean;
		function set hovered(value:Boolean):void; 
	}
}