package ee.spark.components
{
	import ee.spark.components.support.BranchItem;
	import ee.spark.components.support.HierarchicalDataProvider;
	import ee.spark.components.support.HierarchicalList;
	import ee.spark.components.support.IHierarchicalDataProvider;
	import ee.spark.components.support.IHierarchicalModel;
	import ee.spark.components.support.TreeBranchItem;
	import ee.spark.components.support.TreeLeafItem;
	import ee.spark.events.DisclosureEvent;
	
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	
	import spark.events.RendererExistenceEvent;
	
	public class Tree extends HierarchicalList
	{
		static private const BRANCH:IFactory = new ClassFactory(TreeBranchItem);
		static private const LEAF:IFactory = new ClassFactory(TreeLeafItem);		
		
		private var _hierarchicalDataProvider:IHierarchicalDataProvider;
		
		public function Tree()
		{
			addEventListener(RendererExistenceEvent.RENDERER_ADD, _rendererAddHandler);
			addEventListener(RendererExistenceEvent.RENDERER_REMOVE, _rendererRemoveHandler);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get branchItemRendererFactory():IFactory
		{
			return BRANCH;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function get leafItemRendererFactory():IFactory
		{
			return LEAF;
		}		
		
		private function _rendererAddHandler(e:RendererExistenceEvent):void
		{
			var renderer:IVisualElement = e.renderer;
			
			if (renderer is TreeBranchItem)
			{
				TreeBranchItem(e.renderer).addEventListener(DisclosureEvent.DISCLOSURE_CHANGE, _disclosureChangeHandler);
			}
		}
		
		private function _rendererRemoveHandler(e:RendererExistenceEvent):void
		{
			var renderer:IVisualElement = e.renderer;
			
			if (renderer is TreeBranchItem)
			{
				TreeBranchItem(e.renderer).removeEventListener(DisclosureEvent.DISCLOSURE_CHANGE, _disclosureChangeHandler);
			}
		}
		
		private function _disclosureChangeHandler(e:DisclosureEvent):void
		{
			var item:TreeBranchItem = TreeBranchItem(e.currentTarget);
			var open:Boolean = e.open;
			
			if (item.open != open)
			{
				if (open)
				{
					openItem(item);
				} else
				{
					closeItem(item);
				}
			}
		}
		
		protected function openItem(item:BranchItem):void
		{
			item.open = true;
			
			_hierarchicalDataProvider.showChildren(item.data);
		}
		
		protected function closeItem(item:BranchItem):void
		{
			item.open = false;
			
			_hierarchicalDataProvider.hideChildren(item.data);
		}
		
		override protected function getDataProvider(model:IHierarchicalModel):IList
		{
			return new HierarchicalDataProvider(model);
		}
		
		override public function set dataProvider(list:IList):void
		{
			if (!(list is IHierarchicalDataProvider))
			{
				var model:IHierarchicalModel = createModel(list);
				list = new HierarchicalDataProvider(model);
			}
			
			_hierarchicalDataProvider = IHierarchicalDataProvider(list);
			
			super.dataProvider = list;
		}
	}
}