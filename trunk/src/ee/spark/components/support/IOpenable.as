package ee.spark.components.support
{
	/**
	 * Utility interface to detemine if a component has a open state
	 */
	public interface IOpenable
	{
		/**
		 * If set to to true, the component should display an open state.
		 */
		function get open():Boolean;
		function set open(value:Boolean):void; 		
	}
}