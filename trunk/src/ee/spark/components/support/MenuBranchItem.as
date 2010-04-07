package ee.spark.components.support
{
	import ee.spark.components.Menu;
	import ee.spark.components.MenuEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.XMLListCollection;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.managers.FocusManager;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.DataGroup;
	import spark.components.IItemRenderer;
	import spark.components.PopUpAnchor;
	import spark.components.supportClasses.DropDownListBase;
	import spark.skins.spark.ListSkin;
	
	[SkinState("open")]
	
	public class MenuBranchItem extends MenuLeafItem
	{
		[SkinPart(required="true")]
		public var menu:Menu;
		
		private var _open:Boolean;
		
		public function MenuBranchItem()
		{
		}
		
		override protected function attachSkin():void
		{
			super.attachSkin();
			
			skin.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, _skinCurrentStateChangeHandler);
		}
		
		override protected function detachSkin():void
		{
			skin.removeEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, _skinCurrentStateChangeHandler);
			
			super.detachSkin();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case menu:
				{
					menu.owner = this;
					menu.addEventListener(MouseEvent.ROLL_OVER, _menuRollOverHandler);
					menu.addEventListener(MouseEvent.ROLL_OUT, _menuRollOutHandler);
					menu.addEventListener(MenuEvent.MENU_ITEM_CLICK, _menuItemClickHandler);
					menu.addEventListener(KeyboardEvent.KEY_DOWN, _menuKeyDownHandler);
					_setDataProvider();
					break;
				}
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case menu:
				{
					menu.removeEventListener(MouseEvent.ROLL_OVER, _menuRollOverHandler);
					menu.removeEventListener(MouseEvent.ROLL_OUT, _menuRollOutHandler);
					break;
				}
			}
			
			super.partRemoved(partName, instance);
		}
		
		override protected function getCurrentSkinState():String
		{
			if (_open) return "open";
			
			return super.getCurrentSkinState();
		}
		
		private function _skinCurrentStateChangeHandler(e:StateChangeEvent):void
		{
			if (e.newState == "open" && showsCaret)
			{
				focusManager.setFocus(menu);
				menu.moveNext();
			} else if (e.oldState == "open" && showsCaret)
			{
				focusManager.setFocus(IFocusManagerComponent(owner));
			}
		}
		
		private function _menuRollOverHandler(e:MouseEvent):void
		{
			rollOverHandler(e);
		}
		
		private function _menuRollOutHandler(e:MouseEvent):void
		{
			rollOutHandler(e);
		}
		
		private function _menuItemClickHandler(e:MenuEvent):void
		{
			//manual bubbling
			dispatchEvent(e);
		}
		
		private function _menuKeyDownHandler(e:KeyboardEvent):void
		{
			if (open && (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.LEFT)) open = false;
		}
		
		private function _isSubMenu(interactiveObject:InteractiveObject):Boolean
		{
			var isSubMenu:Boolean = false;
			
			var component:UIComponent = UIComponent(interactiveObject);
			var owner:DisplayObjectContainer;
			
			while (component)
			{
				if (component == menu)
				{
					isSubMenu = true;
					break;
				}
				
				owner = component.owner;
				if (owner is UIComponent)
				{
					component = UIComponent(owner);
				} else
				{
					component = null;
				}
			}
			
			return isSubMenu;
		}

		override protected function rollOutHandler(e:MouseEvent):void
		{
			if (!_isSubMenu(e.relatedObject))
			{
				showsCaret = false;
				super.rollOutHandler(e);
				
				if (e.currentTarget == menu)
				{
					//we need to manually bubble for menu events
					dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey));
				}
			}
		}
		
		override protected function rollOverHandler(e:MouseEvent):void
		{
			super.rollOverHandler(e);
		}
		
		
		
		private function _setDataProvider():void
		{
			if (menu) menu.dataProvider = new XMLListCollection(XML(data).children());	
		}
		
		public function get open():Boolean
		{
			return _open;
		}
		
		public function set open(value:Boolean):void
		{
			if (_open != value)
			{
				_open = value;
				invalidateSkinState();
			}
		}
		
		override protected function set hovered(value:Boolean):void
		{
			super.hovered = value;
			
			open = value;
		}
		
		override public function set showsCaret(value:Boolean):void
		{
			if (showsCaret != value)
			{
				super.showsCaret = value;
			}
		}
		
		override public function set data(value:Object):void
		{
			if (data != value)
			{
				super.data = value;
				
				_setDataProvider();
			}
		}
	}
}