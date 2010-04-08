package ee.spark.components
{
	import ee.spark.components.support.MenuBranchItem;
	import ee.spark.components.support.MenuLeafItem;
	import ee.spark.components.support.MenuSeparator;
	import ee.spark.events.MenuEvent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.core.NavigationUnit;
	import spark.events.RendererExistenceEvent;
	
	use namespace mx_internal;
	
	[Event(name="menuItemClick",type="ee.spark.events.MenuEvent")]
	
	public class Menu extends List
	{
		static private const SEPARATOR:IFactory = new ClassFactory(MenuSeparator);
		static private const BRANCH:IFactory = new ClassFactory(MenuBranchItem);
		static private const LEAF:IFactory = new ClassFactory(MenuLeafItem);
		
		private var _currentOpenItem:MenuBranchItem;
		private var _currentHoveredItem:MenuLeafItem;
		
		protected var preventSelection:Boolean;

		public function Menu()
		{
			labelField = "@label";
			itemRendererFunction = getItemRenderer;
			useVirtualLayout = false;
			preventSelection = true;
			addEventListener(MenuEvent.MENU_ITEM_CLICK, menuItemClickHandler);
		}

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
		
		protected function isSeparator(data:Object):Boolean
		{
			var xml:XML = XML(data);
			return xml ? xml.hasOwnProperty("@separator") && xml.@separator.toString() == "true" : false;
		}
		
		protected function isBranch(data:Object):Boolean
		{
			return data ? XML(data).children().length() > 0 : false;
		}
		
		protected function getItemRenderer(data:Object):IFactory
		{
			var itemRenderer:IFactory;
			
			if (isSeparator(data))
			{
				itemRenderer = SEPARATOR;
			} else if (isBranch(data))
			{
				itemRenderer = BRANCH;
			} else
			{
				itemRenderer = LEAF;
			}
			
			return itemRenderer;
		}
		
		/**
		 * Adds listeners for roll over and rollout
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
		 * Overridden to prevent selection and dispatch menu click event
		 * 
		 * We screwed up drag possibilities by overriding it like this
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
		
		protected function rendererRollOverHandler(e:MouseEvent):void
		{
			if (caretIndex > -1) setCurrentCaretIndex(-1);
			
			var currentTarget:Object = e.currentTarget;
			
			if (currentTarget is MenuLeafItem)
			{
				_addHover(MenuLeafItem(currentTarget));
				leafRollOver(MenuLeafItem(currentTarget), e);
			}
		}

		protected function rendererRollOutHandler(e:MouseEvent):void
		{
			var currentTarget:Object = e.currentTarget;
			
			if (currentTarget is MenuLeafItem)
			{
				_removeHover();
				leafRollOut(MenuLeafItem(currentTarget), e);
			}
		}
		
		protected function leafRollOver(item:MenuLeafItem, e:MouseEvent):void
		{
			if (item is MenuBranchItem) openItem(MenuBranchItem(item));
		}
		
		protected function leafRollOut(item:MenuLeafItem, e:MouseEvent):void
		{
			closeItem(false);
		}
		
		/**
		 * Custom key handling
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
		
		protected function focusKeyDownHandler(e:KeyboardEvent):void
		{
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
					case NavigationUnit.RIGHT:
					{
						renderer = dataGroup ? dataGroup.getElementAt(caretIndex) : null;
						
						if (renderer is MenuBranchItem)
						{
							openItem(MenuBranchItem(renderer));
						}
						break;
					}
				}
			}	
		}
		
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
		
		protected function handleSelect(itemRenderer:IItemRenderer):void
		{
			var data:Object = itemRenderer.data;
			
			var shouldSelect:Boolean = !preventSelection;
			
			if (isBranch(data))
			{
				if (shouldSelect)
				{
					var proposedSelectedIndex:int = dataProvider.getItemIndex(itemRenderer.data);
					
					if (selectedIndex == proposedSelectedIndex)
					{
						closeItem();
					} else
					{
						openItem(MenuBranchItem(itemRenderer));
					}
				} else
				{
					openItem(MenuBranchItem(itemRenderer));
				}
			} else
			{
				if (!isSeparator(data))
				{
					var menuEvent:MenuEvent = new MenuEvent(MenuEvent.MENU_ITEM_CLICK, true, false, itemRenderer.data);
					
					//dispatch roll out event in order to close the list
					dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
					
					//dispatch the click event
					dispatchEvent(menuEvent);
				}
			}
		}		
		
		override public function setFocus():void
		{
			if (_currentOpenItem && _currentOpenItem.open)
			{
				//transfer the focus to the menu
				if (_currentOpenItem.menu) focusManager.setFocus(_currentOpenItem.menu);
			} else
			{
				super.setFocus();
			}
		}
		
		protected function openItem(item:MenuBranchItem):void
		{
			if (item != _currentOpenItem)
			{
				if (_currentOpenItem) _currentOpenItem.open = false;
				_currentOpenItem = item;
				if (_currentOpenItem) _currentOpenItem.open = true;
			}
		}		
		
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
		
		private function _addHover(item:MenuLeafItem):void
		{
			if (item != _currentHoveredItem)
			{
				if (_currentHoveredItem) _currentHoveredItem.hovered = false;
				_currentHoveredItem = item;
				if (_currentHoveredItem) _currentHoveredItem.hovered = true;
			}
		}
		
		private function _removeHover():void
		{
			if (_currentHoveredItem)
			{
				_currentHoveredItem.hovered = false;
				_currentHoveredItem = null;
			}
		}
		
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
		
		protected function caretOut():void
		{
			closeItem();
		}
		
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
		
		protected function menuItemClickHandler(e:MenuEvent):void
		{
			setCurrentCaretIndex(-1);
		}
		
		protected function get currentOpenItem():MenuBranchItem
		{
			return _currentOpenItem;
		}
	}
}