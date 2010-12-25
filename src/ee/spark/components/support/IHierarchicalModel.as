package ee.spark.components.support
{
	import mx.collections.IList;

	public interface IHierarchicalModel
	{
		function hasChildren(object:Object):Boolean;
		function getChildren(object:Object):IList;
		function canHaveChildren(object:Object):Boolean;
		function get source():IList;
	}
}