package ee.spark.components.support
{
	import mx.collections.IList;

	public interface IHierarchicalModel
	{
		function canHaveChildren(object:Object):Boolean;
		function hasChildren(object:Object):Boolean;
		function getChildren(object:Object):IList;
		function getParent(object:Object):Object;
		function getDepth(object:Object):uint;
		function get source():IList;
	}
}