package ee.spark.components.support
{
	import mx.collections.IList;

	public interface IHierarchicalDataProvider extends IList
	{
		function showChildren(object:Object):void;
		function hideChildren(object:Object):void;
	}
}