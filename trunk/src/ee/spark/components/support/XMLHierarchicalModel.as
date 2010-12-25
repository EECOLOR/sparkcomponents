package ee.spark.components.support
{
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	
	public class XMLHierarchicalModel implements IHierarchicalModel
	{
		private var _xmlListCollection:XMLListCollection;
		
		public function XMLHierarchicalModel(xmlListCollection:XMLListCollection)
		{
			_xmlListCollection = xmlListCollection;
		}
		
		public function hasChildren(object:Object):Boolean
		{
			return object ? (object as XML).children().length() > 0 : false;
		}
		
		public function getChildren(object:Object):IList
		{
			return new XMLListCollection((object as XML).children());
		}
		
		public function canHaveChildren(object:Object):Boolean
		{
			return true;
		}
		
		public function get source():IList
		{
			return null;
		}
	}
}