package ee.spark.components
{
	import ee.spark.components.support.IHoverable;
	
	import flash.debugger.enterDebugger;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.FlexEvent;
	
	import spark.components.IItemRenderer;
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.DefaultButtonSkin;
	import spark.skins.spark.DefaultItemRenderer;
	
	[Event(name="itemIndexChanged", type="flash.events.Event")]
	[Event(name="labelChanged", type="flash.events.Event")]
	
	[SkinState("dragging")]
	[SkinState("selectedAndShowsCaret")]
	[SkinState("hoveredAndShowsCaret")]
	[SkinState("normalAndShowsCaret")]
	[SkinState("selected")]
	[SkinState("hovered")]
	[SkinState("normal")]
	
	public class SkinnableItemRenderer extends SkinnableComponent implements IItemRenderer, IHoverable
	{
		[SkinPart(required="false")]
		public var labelDisplay:TextBase;
		
		private var _data:Object;
		private var _dragging:Boolean;
		private var _hovered:Boolean;
		private var _itemIndex:int;
		private var _label:String;
		private var _selected:Boolean;
		private var _showsCaret:Boolean;
		
		public function SkinnableItemRenderer()
		{
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case labelDisplay:
				{
					if (_label) labelDisplay.text = _label;
					break;
				}
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			if (dragging) return "dragging";
			if (selected && showsCaret) return "selectedAndShowsCaret";
			if (hovered && showsCaret) return "hoveredAndShowsCaret";
			if (showsCaret) return "normalAndShowsCaret"; 
			if (selected) return "selected";
			if (hovered) return "hovered";
			
			return "normal";			
		}
		
		protected function anyButtonDown(e:MouseEvent):Boolean
		{
			var type:String = e.type;
			return e.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
		}
		
		protected function rollOverHandler(e:MouseEvent):void
		{
			if (!anyButtonDown(e)) hovered = true;
		}
		
		protected function rollOutHandler(e:MouseEvent):void
		{
			hovered = false;
		}
		
		[Bindable("dataChange")]
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			if (_data != value)
			{
				_data = value;
				dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
			}
		}

		public function get dragging():Boolean
		{
			return _dragging;
		}

		public function set dragging(value:Boolean):void
		{
			if (_dragging != value)
			{
				_dragging = value;
				invalidateSkinState();
			}
		}

		public function get hovered():Boolean
		{
			return _hovered;
		}
		
		public function set hovered(value:Boolean):void
		{
			if (_hovered != value)
			{
				_hovered = value;
				invalidateSkinState();
			}
		}
		
		[Bindable("itemIndexChanged")]
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			if (_itemIndex != value)
			{			
				_itemIndex = value;
				
				dispatchEvent(new Event("itemIndexChanged"));
			}
		}

		[Bindable("labelChanged")]
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			if (_label != value)
			{
				_label = value;
				
				if (labelDisplay) labelDisplay.text = value;
				
				dispatchEvent(new Event("labelChanged"));
			}
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if (_selected != value)
			{
				_selected = value;
				invalidateSkinState();
			}
		}

		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}

		public function set showsCaret(value:Boolean):void
		{
			if (_showsCaret != value)
			{
				_showsCaret = value;
				invalidateSkinState();
			}
		}

	}
}