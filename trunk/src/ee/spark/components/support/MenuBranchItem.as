package ee.spark.components.support
{
	import ee.spark.components.Menu;
	import ee.spark.events.ItemEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import mx.core.IUIComponent;
	import mx.events.StateChangeEvent;
	import mx.managers.IFocusManagerComponent;
	
	/**
	 * This item renderer represents a branch in the menu. In other words, a renderer 
	 * which contains a sub menu.
	 * 
	 * <p>The default skin is ee.spark.skins.MenuBranchItem. If the host component is 
	 * a MenuBar, the default skin ee.spark.skins.MenuBarBranchItem.</p>
	 */
	public class MenuBranchItem extends BranchItem
	{
		[SkinPart(required="true")]
		/**
		 * The sub menu. Shown when skin state is open.
		 */
		public var menu:Menu;
		
		private var _children:IList;
		
		public function MenuBranchItem()
		{
		}
		
		/**
		 * Overridden in order to listen to StateChangeEvent.CURRENT_STATE_CHANGE. Yhis 
		 * is used to shift focus to the sub menu on opening and back when closing.
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			
			skin.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, _skinCurrentStateChangeHandler);
		}
		
		/**
		 * Overridden to remove StateChangeEvent.CURRENT_STATE_CHANGE handler.
		 */
		override protected function detachSkin():void
		{
			skin.removeEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, _skinCurrentStateChangeHandler);
			
			super.detachSkin();
		}
		
		/**
		 * Overridden in order to add listeners to the menu, set the owner of the menu 
		 * to this and to set the dataProvider
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case menu:
				{
					menu.owner = this;
					menu.addEventListener(MouseEvent.ROLL_OUT, _menuRollOutHandler);
					menu.addEventListener(ItemEvent.ITEM_SELECT, _itemSelectHandler);
					menu.addEventListener(KeyboardEvent.KEY_DOWN, _menuKeyDownHandler);
					_updateDataProvider();
					break;
				}
			}
		}
		
		/**
		 * Overridden in order to remove listeners from the menu.
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			switch (instance)
			{
				case menu:
				{
					menu.removeEventListener(MouseEvent.ROLL_OUT, _menuRollOutHandler);
					menu.removeEventListener(ItemEvent.ITEM_SELECT, _itemSelectHandler);
					menu.removeEventListener(KeyboardEvent.KEY_DOWN, _menuKeyDownHandler);
					break;
				}
			}
			
			super.partRemoved(partName, instance);
		}
		
		/**
		 * @private
		 * 
		 * If the new state is open, set the focus. If the old state was open, shift 
		 * focus back to the owner.
		 */
		private function _skinCurrentStateChangeHandler(e:StateChangeEvent):void
		{
			if (e.newState == "open")
			{
				focusManager.setFocus(menu);
				if (showsCaret) menu.moveNext();
			} else if (e.oldState == "open")
			{
				focusManager.setFocus(IFocusManagerComponent(owner));
			}
		}
		
		/**
		 * @private
		 */
		private function _menuRollOutHandler(e:MouseEvent):void
		{
			rollOutHandler(e);
		}
		
		/**
		 * @private 
		 */
		private function _itemSelectHandler(e:ItemEvent):void
		{
			//manual bubbling
			dispatchEvent(e);
		}
		
		/**
		 * @private 
		 */
		private function _menuKeyDownHandler(e:KeyboardEvent):void
		{
			//manual bubbling
			dispatchEvent(e);
		}
		
		/**
		 * @private 
		 * 
		 * Determines if the given interactive object is a sub menu by walking 
		 * the owner chain backwards.
		 */
		private function _isSubMenu(interactiveObject:InteractiveObject):Boolean
		{
			var isSubMenu:Boolean = false;
			
			var component:IUIComponent = IUIComponent(interactiveObject);
			var owner:DisplayObjectContainer;
			
			while (component)
			{
				if (component == menu)
				{
					isSubMenu = true;
					break;
				}
				
				owner = component.owner;
				if (owner is IUIComponent)
				{
					component = IUIComponent(owner);
				} else
				{
					component = null;
				}
			}
			
			return isSubMenu;
		}

		/**
		 * Prevent rollover to set hovered
		 */
		override protected function rollOverHandler(e:MouseEvent):void
		{
		}		
		
		/**
		 * Prevent rollout to remove hovered and if needed
		 * dispatch rollout for menu.
		 */
		override protected function rollOutHandler(e:MouseEvent):void
		{
			if (!_isSubMenu(e.relatedObject))
			{
				if (e.currentTarget == menu)
				{
					//we need to manually bubble for menu events
					dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey));
				}
			} else
			{
				e.stopImmediatePropagation();
			}
		}
		
		/**
		 * @private
		 */
		private function _updateDataProvider():void
		{
			if (menu) menu.dataProvider = _children;	
		}
		
		public function get children():IList
		{
			return _children;
		}
		
		public function set children(value:IList):void
		{
			if (_children != value)
			{
				_children = value;
				_updateDataProvider();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set data(value:Object):void
		{
			if (data != value)
			{
				super.data = value;
			}
		}
	}
}