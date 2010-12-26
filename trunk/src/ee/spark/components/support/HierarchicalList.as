package ee.spark.components.support
{
	import ee.spark.events.ItemEvent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import mx.core.IFactory;
	import mx.core.mx_internal;
	
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.core.NavigationUnit;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched when a menu leaf item is clicked.
	 */
	[Event(name="menuItemClick",type="ee.spark.events.ItemEvent")]
	
	/**
	 * Base class for hierarchical lists
	 */
	public class HierarchicalList extends List
	{
		/**
		 * If set to true prevents item selection.
		 * 
		 * @default true
		 */
		protected var preventSelection:Boolean;		
		
		private var _model:IHierarchicalModel;
		
		public function HierarchicalList()
		{
			super();
		}
		
		/**
		 * Determines which item renderer to use for the given object.
		 * 
		 * @see LeafItem
		 * @see BranchItem
		 */ 
		protected function getItemRenderer(data:Object):IFactory
		{
			var itemRenderer:IFactory;
			
			if (model.hasChildren(data))
			{
				itemRenderer = branchItemRendererFactory;
			} else
			{
				itemRenderer = leafItemRendererFactory;
			}
			
			return itemRenderer;
		}
		
		/**
		 * Dispatches the item select event
		 */
		protected function dispatchSelectEvent(data:Object):void
		{
			dispatchEvent(new ItemEvent(ItemEvent.ITEM_SELECT, true, false, data));
		}
		
		/**
		 * The model that is used to determine the properties of this hierarchical list.
		 * <p/>
		 * When it's set it will set the model's source as dataProvider
		 */
		public function get model():IHierarchicalModel
		{
			return _model;
		}
		
		public function set model(value:IHierarchicalModel):void
		{
			_model = value;
			dataProvider = getDataProvider(_model);
		}
		
		protected function getDataProvider(model:IHierarchicalModel):IList
		{
			return _model.source;
		}
		
		/**
		 * Overridden in order to create a model if none exists for the given list. Can only 
		 * create a model for XMLListCollection.
		 */
		override public function set dataProvider(list:IList):void
		{
			if (!_model || _model.source != list)
			{
				_model = createModel(list);
			}
			
			super.dataProvider = list;
		}
		
		protected function createModel(list:IList):IHierarchicalModel
		{
			var model:IHierarchicalModel;
			
			//we need to create a new model
			if (list is XMLListCollection)
			{
				model = new XMLHierarchicalModel(XMLListCollection(list));
			} else if (list)
			{
				throw new Error("This component does not support any dataProviders other than XMLListCollections");
			} else
			{
				//list is null, no need to throw an error
			}

			return model;
		}
		
		/**
		 * Should be overridden in order to provide the branch item renderer factory
		 */
		protected function get branchItemRendererFactory():IFactory
		{
			throw new Error("Subclasses should implement this method");
		}
		
		/**
		 * Should be overridden in order to provide the leaf item renderer factory
		 */
		protected function get leafItemRendererFactory():IFactory
		{
			throw new Error("Subclasses should implement this method");
		}
	}
}