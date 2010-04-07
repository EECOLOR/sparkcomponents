package ee.spark.components
{
	import ee.spark.components.support.MenuBranchItem;
	import ee.spark.components.support.MenuLeafItem;
	import ee.spark.components.support.MenuSeparator;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.mx_internal;
	
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.core.NavigationUnit;
	import spark.events.IndexChangeEvent;
	import spark.layouts.VerticalLayout;
	import spark.skins.spark.ListSkin;
	
	use namespace mx_internal;
	
	[Event(name="menuItemClick",type="ee.spark.components.MenuEvent")]
	
	public class Menu extends List
	{
		static private const SEPARATOR:IFactory = new ClassFactory(MenuSeparator);
		static private const BRANCH:IFactory = new ClassFactory(MenuBranchItem);
		static private const LEAF:IFactory = new ClassFactory(MenuLeafItem);
		
		private var _selectedItem:Object;
		
		protected var preventSelection:Boolean;

		public function Menu()
		{
			labelField = "@label";
			itemRendererFunction = getItemRenderer;
			useVirtualLayout = false;
			preventSelection = true;
			addEventListener(MenuEvent.MENU_ITEM_CLICK, menuItemClickHandler);
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
		 * Overridden to prevent selection and dispatch menu click event
		 */
		override protected function itemSelected(index:int, selected:Boolean):void
		{
			var renderer:Object = dataGroup ? dataGroup.getElementAt(index) : null;
			
			if (renderer is IItemRenderer)
			{
				var itemRenderer:IItemRenderer = IItemRenderer(renderer);
				var data:Object = itemRenderer.data;
				var newSelected:Boolean = preventSelection ? false : selected;
				
				if (selected || itemRenderer.selected != newSelected)
				{
					super.itemSelected(index, newSelected);
					
					//reset index
					if (preventSelection && selectedIndex != -1) selectedIndex = -1;
					
					if (selected && !isBranch(data))
					{
						var menuEvent:MenuEvent = new MenuEvent(MenuEvent.MENU_ITEM_CLICK, true, false, itemRenderer.data);
						
						//dispatch roll out event in order to close the list
						dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
						
						//dispatch the click event
						dispatchEvent(menuEvent);
					}
				}
			}
		}
		
		/**
		 * Custom key handling
		 */
		override protected function keyDownHandler(e:KeyboardEvent):void
		{
			if (!dataProvider || !layout || e.isDefaultPrevented()) return;
			
			var navigationUnit:uint = e.keyCode;    
			if (navigationUnit == Keyboard.SPACE)
			{
				setSelectedIndex(caretIndex, true); 
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
						openOrCloseItem(true);
						break;
					}
					case NavigationUnit.LEFT:
					{
						openOrCloseItem(false);
						break;
					}
				}
			}			
		}
		
		public function moveNext():void
		{
			var currentCaretIndex:int = caretIndex;
			
			if (currentCaretIndex < dataProvider.length - 1)
			{
				var proposedCaretIndex:int = currentCaretIndex + 1;
				
				//find the next non-separator
				
				while (isSeparator(dataProvider.getItemAt(proposedCaretIndex)))
				{
					proposedCaretIndex += 1;
				}
				
				if (proposedCaretIndex < dataProvider.length)
				{
					//we found a valid item
					setCurrentCaretIndex(proposedCaretIndex);
				} else
				{
					//do nothing
				}
			} else
			{
				//do nothing
			}
		}
		
		public function movePrevious():void
		{
			var currentCaretIndex:int = caretIndex == -1 ? dataProvider.length : caretIndex;
			
			if (currentCaretIndex > 0)
			{
				var proposedCaretIndex:int = currentCaretIndex - 1;
				
				//find the next non-separator
				
				while (isSeparator(dataProvider.getItemAt(proposedCaretIndex)))
				{
					proposedCaretIndex -= 1;
				}
				
				if (proposedCaretIndex > -1)
				{
					//we found a valid item
					setCurrentCaretIndex(proposedCaretIndex);
				} else
				{
					//do nothing
				}
			} else
			{
				//do nothing
			}
		}
		
		protected function openOrCloseItem(open:Boolean):void
		{
			if (caretIndex > -1)
			{
				var renderer:Object = dataGroup ? dataGroup.getElementAt(caretIndex) : null;
				
				if (renderer is MenuBranchItem)
				{
					MenuBranchItem(renderer).open = open;
				}
			}
		}
		
		protected function menuItemClickHandler(e:MenuEvent):void
		{
			trace("menuItemClickHandler");
			setCurrentCaretIndex(-1);
		}
	}
}