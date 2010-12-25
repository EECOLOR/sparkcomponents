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
		
		private var _currentOpenItem:BranchItem;
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
		 * Opens the given item
		 */
		protected function openItem(item:BranchItem):void
		{
			if (item != _currentOpenItem)
			{
				if (_currentOpenItem) _currentOpenItem.open = false;
				_currentOpenItem = item;
				if (_currentOpenItem) _currentOpenItem.open = true;
			}
		}
		
		/**
		 * Closes the current item.
		 * 
		 * @param restoreCaret 		If set to true, the closing of the item restores the 
		 * 							caret index to the index of the last open item.
		 */ 
		protected function closeItem(restoreCaret:Boolean = true):void
		{
			if (_currentOpenItem)
			{
				if (restoreCaret) 
				{
					setCurrentCaretIndex(dataProvider.getItemIndex(_currentOpenItem.data));	
				} else
				{
					setCurrentCaretIndex(-1);
				}
				_currentOpenItem.open = false;
				_currentOpenItem = null;
			}
		}		
		
		
		/**
		 * Overridden to prevent selection and dispatch menu click event
		 * 
		 * <p>We screwed up drag possibilities by overriding it like this. If needed 
		 * in the future we could add code here to enable dragging</p> 
		 */
		override protected function item_mouseDownHandler(e:MouseEvent):void
		{
			var renderer:Object = e.currentTarget;
			
			if (renderer is IItemRenderer)
			{
				var itemRenderer:IItemRenderer = IItemRenderer(renderer);
				handleSelect(itemRenderer);
			}
		}			
		
		/**
		 * Overridden in order to provide custom key handling.
		 */
		override protected function keyDownHandler(e:KeyboardEvent):void
		{
			var hasFocus:Boolean = focusManager.getFocus() == this;
			if (!dataProvider || !layout || e.isDefaultPrevented() || !hasFocus) return;
			
			var navigationUnit:uint = e.keyCode;
			var renderer:Object;
			
			if (navigationUnit == Keyboard.SPACE)
			{
				renderer = dataGroup ? dataGroup.getElementAt(caretIndex) : null;
				
				if (renderer is IItemRenderer)
				{
					handleSelect(IItemRenderer(renderer));
				}
				e.preventDefault();
			} else if (NavigationUnit.isNavigationUnit(navigationUnit))
			{
				switch (navigationUnit)
				{
					case NavigationUnit.RIGHT:
					{
						renderer = dataGroup ? dataGroup.getElementAt(caretIndex) : null;
						
						if (renderer is BranchItem)
						{
							openItem(BranchItem(renderer));
						}
						break;
					}
				}
			}	
		}		
		
		/**
		 * Handles selecting an item. If the item is a branch it might be opened or closed.
		 * If the item is a leaf, a ItemEvent.ITEM_SELECT is dispatched.
		 */
		protected function handleSelect(itemRenderer:IItemRenderer):void
		{
			var data:Object = itemRenderer.data;
			
			var shouldSelect:Boolean = !preventSelection;
			
			if (model.hasChildren(data))
			{
				if (shouldSelect)
				{
					var proposedSelectedIndex:int = dataProvider.getItemIndex(itemRenderer.data);
					
					if (selectedIndex == proposedSelectedIndex)
					{
						closeItem();
					} else
					{
						openItem(BranchItem(itemRenderer));
					}
				} else
				{
					openItem(BranchItem(itemRenderer));
				}
			} else
			{
				dispatchSelectEvent(itemRenderer.data);
			}
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
			dataProvider = _model.source;
		}
		
		/**
		 * Overridden in order to create a model if none exists for the given list. Can only 
		 * create a model for XMLListCollection.
		 */
		override public function set dataProvider(list:IList):void
		{
			if (!_model || _model.source != list)
			{
				//we need to create a new model
				if (list is XMLListCollection)
				{
					_model = new XMLHierarchicalModel(XMLListCollection(list));
				} else if (list)
				{
					throw new Error("This component does not support any dataProviders other than XMLListCollections");
				} else
				{
					//list is null, no need to throw an error
				}
			}
			
			super.dataProvider = list;
		}
		
		/**
		 * Returns the current open item.
		 */
		protected function get currentOpenItem():BranchItem
		{
			return _currentOpenItem;
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