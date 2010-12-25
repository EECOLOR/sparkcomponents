package ee.spark.components
{
	import ee.spark.components.support.BranchItem;
	import ee.spark.components.support.HierarchicalList;
	import ee.spark.components.support.LeafItem;
	import ee.spark.components.support.MenuBranchItem;
	import ee.spark.components.support.MenuLeafItem;
	import ee.spark.components.support.MenuSeparator;
	import ee.spark.events.ItemEvent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	
	import spark.core.NavigationUnit;
	import spark.events.RendererExistenceEvent;
	
	use namespace mx_internal;
	
	/**
	 * An extension of the list component to provide menu like capabilities.
	 * 
	 * <p>Requires xml an XMLListCollection as a dataProvider, the structure of the 
	 * xml is like this:</p>
	 * 
	 * <p><pre>
	 * &lt;menuItem label="menu item 1"&gt;
	 * 	&lt;menuItem label="sub menu item 1" /&gt;
	 * 	&lt;menuItem label="sub menu item 2" /&gt;
	 * &lt;/menuItem&gt;
	 * &lt;menuItem label="menu item 2" /&gt;
	 * &lt;menuItem separator="true" /&gt;
	 * &lt;menuItem label="menu item 3"&gt;
	 * 	&lt;menuItem label="sub menu item 3" /&gt;
	 * 	&lt;menuItem separator="true" /&gt;
	 * 	&lt;menuItem label="sub menu item 4" /&gt;
	 * &lt;/menuItem&gt;
	 * </pre></p>
	 * 
	 * <p>The name of the xml element is free. A separator attribute determines if 
	 * an element represents a separator.</p>
	 * 
	 * <p>The Menu control has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>labelField</td><td>&#64;label</td></tr>
	 *     <tr><td>itemRendererFunction</td><td>getItemRenderer</td></tr>
	 *     <tr><td>useVirtualLayout</td><td>false</td></tr>
	 *     <tr><td>preventSelection</td><td>true</td></tr>
	 *     <tr><td>Default skin class</td><td>ee.spark.skins.MenuSkin</td></tr>
	 *  </table>
	 * 
	 * @see #getItemRenderer()
	 */
	public class Menu extends HierarchicalList
	{
		static private const SEPARATOR:IFactory = new ClassFactory(MenuSeparator);
		static private const BRANCH:IFactory = new ClassFactory(MenuBranchItem);
		static private const LEAF:IFactory = new ClassFactory(MenuLeafItem);
		
		private var _currentHoveredItem:LeafItem;
		
		public function Menu()
		{
			labelField = "@label";
			itemRendererFunction = getItemRenderer;
			useVirtualLayout = false;
			preventSelection = true;
			addEventListener(ItemEvent.ITEM_SELECT, itemSelectHandler);
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
		
		/**
		 * Overridden in order to add handlers for RendererExistenceEvent of dataGroup
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case dataGroup:
				{
					dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, _rendererAddHandler);
					dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, _rendererRemoveHandler);
					break;
				}
			}
		}
		
		/**
		 * Overridden in order to remove handlers for RendererExistenceEvent of dataGroup
		 */		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case dataGroup:
				{
					dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, _rendererAddHandler);
					dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, _rendererRemoveHandler);
					break;
				}
			}
			
			super.partRemoved(partName, instance);
		}
		
		/**
		 * Utility method to determine if the given data object represents a separator.
		 */ 
		protected function isSeparator(data:Object):Boolean
		{
			var xml:XML = XML(data);
			return xml ? xml.hasOwnProperty("@separator") && xml.@separator.toString() == "true" : false;
		}
		
		/**
		 * Determines which item renderer to use for the given object.
		 * 
		 * @see MenuLeafItem
		 * @see MenuBranchItem
		 * @see MenuSeparator
		 */ 
		override protected function getItemRenderer(data:Object):IFactory
		{
			var itemRenderer:IFactory;
			
			if (isSeparator(data))
			{
				itemRenderer = SEPARATOR;
			} else
			{
				itemRenderer = super.getItemRenderer(data);
			}
			
			return itemRenderer;
		}
		
		/**
		 * Overridden in order to set the children of the MenuBranchItem
		 */
		override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
		{
			super.updateRenderer(renderer, itemIndex, data);
			
			if (renderer is MenuBranchItem)
			{
				MenuBranchItem(renderer).children = model.getChildren(data);
			}
		}
		
		/**
		 * @private
		 */
		private function _rendererAddHandler(e:RendererExistenceEvent):void
		{
			var renderer:IVisualElement = e.renderer;
			
			if (renderer)
			{
				renderer.addEventListener(MouseEvent.ROLL_OVER, rendererRollOverHandler);
				renderer.addEventListener(MouseEvent.ROLL_OUT, rendererRollOutHandler);
			}
		}
		
		/**
		 * @private
		 */
		private function _rendererRemoveHandler(e:RendererExistenceEvent):void
		{
			var renderer:IVisualElement = e.renderer;
			
			if (renderer)
			{
				renderer.removeEventListener(MouseEvent.ROLL_OVER, rendererRollOverHandler);
				renderer.removeEventListener(MouseEvent.ROLL_OUT, rendererRollOutHandler);
			}
		}
		
		/**
		 * Resets the current caret index and sets hovered to true for the rolled 
		 * over item. 
		 */ 
		protected function rendererRollOverHandler(e:MouseEvent):void
		{
			if (caretIndex > -1) setCurrentCaretIndex(-1);
			
			var currentTarget:Object = e.currentTarget;
			
			if (currentTarget is LeafItem)
			{
				_addHover(LeafItem(currentTarget));
				leafRollOver(LeafItem(currentTarget), e);
			}
		}

		/**
		 * Sets the hovered to false for the rolled out item.
		 */ 
		protected function rendererRollOutHandler(e:MouseEvent):void
		{
			var currentTarget:Object = e.currentTarget;
			
			if (currentTarget is LeafItem)
			{
				_removeHover();
				leafRollOut(LeafItem(currentTarget), e);
			}
		}
		
		/**
		 * Opens the given item if it's a BranchItem
		 * 
		 * @see BranchItem
		 */
		protected function leafRollOver(item:LeafItem, e:MouseEvent):void
		{
			if (item is BranchItem) openItem(BranchItem(item));
		}
		
		/**
		 * Closes any open item
		 */
		protected function leafRollOut(item:LeafItem, e:MouseEvent):void
		{
			closeItem(false);
		}

		/**
		 * Overridden in order to make a distinction between focussed an non-focussed events
		 */
		override protected function keyDownHandler(e:KeyboardEvent):void
		{
			if (!dataProvider || !layout || e.isDefaultPrevented()) return;
			
			if (focusManager.getFocus() == this)
			{
				focusKeyDownHandler(e);
			} else
			{
				noFocusKeyDownHandler(e);
			}
		}
		
		/**
		 * Called when the current menu has focus. Handles navigation through 
		 * the component.
		 */
		protected function focusKeyDownHandler(e:KeyboardEvent):void
		{
			var navigationUnit:uint = e.keyCode;
			var renderer:Object;
			
			switch (navigationUnit)
			{
				case NavigationUnit.UP:
				{
					movePrevious();
					break;
				}
				case NavigationUnit.DOWN:
				{
					moveNext();
					break;
				}
				default:
				{
					super.keyDownHandler(e);
					break;
				}
			}
		}
		
		/**
		 * Called when the menu does not have focus.
		 */
		protected function noFocusKeyDownHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case NavigationUnit.LEFT:
				{
					//prevent parent menu from closing
					e.stopImmediatePropagation();
					closeItem();
					break;
				}
				case Keyboard.ESCAPE:
				{
					closeItem();
					break;
				}
			}
		}		
		
		override protected function dispatchSelectEvent(data:Object):void
		{
			if (!isSeparator(data))
			{
				//dispatch roll out event in order to close the list
				dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
				
				super.dispatchSelectEvent(data);
			}
		}
		
		/**
		 * If an item is open, shift the focus to the open item.
		 */
		override public function setFocus():void
		{
			if (currentOpenItem && currentOpenItem.open)
			{
				//transfer the focus to the menu
				var openMenuBranchItem:MenuBranchItem = MenuBranchItem(currentOpenItem);
				if (openMenuBranchItem.menu) focusManager.setFocus(openMenuBranchItem.menu);
			} else
			{
				super.setFocus();
			}
		}
		
		/**
		 * @private
		 */
		private function _addHover(item:LeafItem):void
		{
			if (item != _currentHoveredItem)
			{
				if (_currentHoveredItem) _currentHoveredItem.hovered = false;
				_currentHoveredItem = item;
				if (_currentHoveredItem) _currentHoveredItem.hovered = true;
			}
		}
		
		/**
		 * @private
		 */
		private function _removeHover():void
		{
			if (_currentHoveredItem)
			{
				_currentHoveredItem.hovered = false;
				_currentHoveredItem = null;
			}
		}
		
		/**
		 * Moves the caret index forward, ignoring separators.
		 */
		public function moveNext():void
		{
			var currentCaretIndex:int = caretIndex;
			
			if (currentCaretIndex == -1 && _currentHoveredItem)
			{
				//set the current caret index to the hovers position
				currentCaretIndex = dataProvider.getItemIndex(_currentHoveredItem.data);
			}
			
			_removeHover();
			
			if (currentCaretIndex >= dataProvider.length -1) currentCaretIndex = -1;
			
			var proposedCaretIndex:int = currentCaretIndex + 1;
			//find the next non-separator
			while (isSeparator(dataProvider.getItemAt(proposedCaretIndex)))
			{
				proposedCaretIndex += 1;
			}
			
			if (proposedCaretIndex < dataProvider.length)
			{
				//we found a valid item, close the previous one
				caretOut();
				setCurrentCaretIndex(proposedCaretIndex);
			} else
			{
				//do nothing
			}
		}
		
		/**
		 * Moves the caret index backwards, ignoring separators.
		 */
		public function movePrevious():void
		{
			
			var currentCaretIndex:int = caretIndex;
			
			if (currentCaretIndex == -1 && _currentHoveredItem)
			{
				//set the current caret index to the hovers position
				currentCaretIndex = dataProvider.getItemIndex(_currentHoveredItem.data);
			}
			
			_removeHover();
			
			currentCaretIndex = currentCaretIndex <= -1 ? dataProvider.length : caretIndex;
			
			if (currentCaretIndex == 0) currentCaretIndex = dataProvider.length;
			
			var proposedCaretIndex:int = currentCaretIndex - 1;
			
			//find the next non-separator
			while (isSeparator(dataProvider.getItemAt(proposedCaretIndex)))
			{
				proposedCaretIndex -= 1;
			}
			
			if (proposedCaretIndex > -1)
			{
				//we found a valid item, close the previous one
				caretOut();
				setCurrentCaretIndex(proposedCaretIndex);
			} else
			{
				//do nothing
			}
		}
		
		/**
		 * Called when the caret moves away from an element. Closes the current open element.
		 */
		protected function caretOut():void
		{
			closeItem();
		}		
		
		/**
		 * Resets the current caret index.
		 */
		protected function itemSelectHandler(e:ItemEvent):void
		{
			setCurrentCaretIndex(-1);
		}
	}
}