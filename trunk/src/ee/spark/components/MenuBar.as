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
	
	/**
	 * The menu bar lays its items out in a horizontal fashion. The main difference 
	 * with menu is that items remain open even if they are rolled out.
	 * 
	 * <p>The MenuBar control has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>layout</td><td>HorizontalLayout</td></tr>
	 *     <tr><td>preventSelection</td><td>false</td></tr>
	 *     <tr><td>Default skin class</td><td>ee.spark.skins.MenuSkin</td></tr>
	 *  </table>
	 */
	public class MenuBar extends Menu
	{
		private var _clearSelectionPending:Boolean;
		
		public function MenuBar()
		{
			layout = new HorizontalLayout();
			preventSelection = false;
		}
		
		/**
		 * Overridden in order to have different navigational controls, the 
		 * layout is horizontal now.
		 */
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
		
		/**
		 * Overridden in order to have different navigational controls, the 
		 * layout is horizontal now.
		 */		
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
					
					/*
						check if the current focussed item is a branch, if so
						we need to prevent the next menu from showing.
					*/
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
		
		/**
		 * Overridden in order to set the selected index
		 */
		override protected function openItem(item:MenuBranchItem):void
		{
			if (item) selectedIndex = dataProvider.getItemIndex(item.data);
			super.openItem(item);
		}
		
		/**
		 * Overridden in order to remove the selected index
		 */
		override protected function closeItem(restoreCaret:Boolean = true):void
		{
			super.closeItem();
			selectedIndex = -1;
			//we might need to invalidate the properties later
			callLater(invalidateProperties);
		}		
		
		/**
		 * Removes the selected index and closes any open items
		 */
		override protected function menuItemClickHandler(e:MenuEvent):void
		{
			super.menuItemClickHandler(e);
			
			closeItem();
		}
	}
}