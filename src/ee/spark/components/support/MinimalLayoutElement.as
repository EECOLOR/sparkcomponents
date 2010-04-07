package ee.spark.components.support
{
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	import mx.core.IUIComponent;
	import mx.core.LayoutElementUIComponentUtils;
	import mx.core.UIComponent;
	
	public class MinimalLayoutElement extends UIComponent
	{
		static private const MINIMAL_STRANGE_NUMBER:Number = 1;
		static private const STRANGE_NUMBER:Number = 1;
		static private const PREFERRED_STRANGE_NUMBER:Number = 100;
		static private const MAX_STRANGE_NUMBER:Number = 100;
		
		public function MinimalLayoutElement()
		{
		}
		
		override public function get width():Number
		{
			return 0;
		}
		
		override public function get height():Number
		{
			return PREFERRED_STRANGE_NUMBER;
		}
		
		override protected function nonDeltaLayoutMatrix():Matrix
		{
			return null;
		}
		
		override public function get baseline():Object
		{
			return null;
		}
		
		override public function set baseline(value:Object):void
		{
		}
		
		override public function get baselinePosition():Number
		{
			return 0;
		}
		
		override public function get bottom():Object
		{
			return null;
		}
		
		override public function set bottom(value:Object):void
		{
		}
		
		override public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return STRANGE_NUMBER;
		}
		
		override public function getLayoutBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
			return 0;
		}
		
		override public function getMaxBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return MAX_STRANGE_NUMBER;
		}
		
		override public function getMaxBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
			return 0;
		}
		
		override public function getMinBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return MINIMAL_STRANGE_NUMBER;
		}
		
		override public function getMinBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
			return 0;
		}
		
		override public function getPreferredBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
			return PREFERRED_STRANGE_NUMBER;
		}
		
		override public function getPreferredBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
			return 0;
		}
		
		override public function get hasLayoutMatrix3D():Boolean
		{
			return false;
		}
		
		override public function get horizontalCenter():Object
		{
			return null;
		}
		
		override public function set horizontalCenter(value:Object):void
		{
		}
		
		override public function get includeInLayout():Boolean
		{
			return true;
		}
		
		override public function set includeInLayout(value:Boolean):void
		{
		}
		
		override public function get left():Object
		{
			return null;
		}
		
		override public function set left(value:Object):void
		{
		}
		
		override public function get percentHeight():Number
		{
			return NaN;
		}
		
		override public function set percentHeight(value:Number):void
		{
		}
		
		override public function get percentWidth():Number
		{
			return NaN;
		}
		
		override public function set percentWidth(value:Number):void
		{
		}
		
		override public function get right():Object
		{
			return null;
		}
		
		override public function set right(value:Object):void
		{
		}
		
		override public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean=true):void
		{
		}
		
		override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void
		{
		}
		
		override public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
		{
		}
		
		override public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
		{
		}
		
		override public function get top():Object
		{
			return null;
		}
		
		override public function set top(value:Object):void
		{
		}
		
		override public function transformAround(transformCenter:Vector3D, scale:Vector3D=null, rotation:Vector3D=null, translation:Vector3D=null, postLayoutScale:Vector3D=null, postLayoutRotation:Vector3D=null, postLayoutTranslation:Vector3D=null, invalidateLayout:Boolean=true):void
		{
		}
		
		override public function get verticalCenter():Object
		{
			return null;
		}
		
		override public function set verticalCenter(value:Object):void
		{
		}
		
	}
}