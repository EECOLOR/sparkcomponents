package ee.spark.components
{
	import ee.spark.components.support.MenuBranchItem;
	import ee.spark.components.support.MenuLeafItem;
	import ee.spark.events.MenuEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.managers.IFocusManagerComponent;
	
	import spark.core.NavigationUnit;
	import spark.layouts.HorizontalLayout;
	
	use namespace mx_internal;
	
	public class MenuBar extends Menu
	{
		private var _clearSelectionPending:Boolean;
		
		public function MenuBar()
		{
			layout = new HorizontalLayout();
			preventSelection = false;
		}
		
		override protected function focusKeyDownHandler(e:KeyboardEvent):void
		{
			var navigationUnit:uint = e.keyCode;
			var renderer:Object;
			
			if (navigationUnit == Keyboard.SPACE)
			{
				super.focusKeyDownHandler(e);
			} else if (NavigationUnit.isNavigationUnit(navigationUnit))
			{
				switch (navigationUnit)
				{
					case NavigationUnit.LEFT:
					{
						movePrevious();
						break;
					}
					case NavigationUnit.RIGHT:
					{
						moveNext();
						break;
					}
					case NavigationUnit.DOWN:
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
		
		override protected function noFocusKeyDownHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case NavigationUnit.LEFT:
				{
					focusKeyDownHandler(e);
					break;
				}
				case NavigationUnit.RIGHT:
				{
					var focussedItem:IFocusManagerComponent = focusManager.getFocus();
					var preventAction:Boolean = false;
					
					if (focussedItem is Menu)
					{
						var menu:Menu = Menu(focussedItem);
						if (isBranch(menu.dataProvider.getItemAt(menu.caretIndex)))
						{
							preventAction = true;
						}
					}
					
					if (!preventAction) focusKeyDownHandler(e);
					break;
				}
				default:
				{
					super.noFocusKeyDownHandler(e);
					break;
				}
			}
		}			
		
		/**
		 * Only open on rollover if another branch is open
		 */
		override protected function leafRollOver(item:MenuLeafItem, e:MouseEvent):void
		{
			if (currentOpenItem)
			{
				if (item is MenuBranchItem) openItem(MenuBranchItem(item));
			}
		}
		
		/**
		 * Only open on caret change if another branch is open
		 */
		mx_internal override function setCurrentCaretIndex(value:Number):void
		{
			super.setCurrentCaretIndex(value);
			if (currentOpenItem && value > -1)
			{
				var renderer:IVisualElement = dataGroup ? dataGroup.getElementAt(value) : null;
				if (renderer is MenuBranchItem) openItem(MenuBranchItem(renderer));
			}			
		}
		
		/**
		 * Prevent closing on roll out
		 */
		override protected function leafRollOut(item:MenuLeafItem, e:MouseEvent):void
		{
		}
		
		/**
		 * Prevent closing on move out
		 */
		override protected function caretOut():void
		{
		}
		
		override protected function openItem(item:MenuBranchItem):void
		{
			if (item) selectedIndex = dataProvider.getItemIndex(item.data);
			super.openItem(item);
		}
		
		override protected function closeItem(restoreCaret:Boolean = true):void
		{
			selectedIndex = -1;
			super.closeItem();
		}		
		
		override protected function menuItemClickHandler(e:MenuEvent):void
		{
			super.menuItemClickHandler(e);
			
			selectedIndex = -1;
			closeItem();
			callLater(invalidateProperties);
		}
	}
}