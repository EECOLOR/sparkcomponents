package ee.spark.components.support
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	public class HierarchicalDataProvider extends EventDispatcher implements IHierarchicalDataProvider
	{
		private var _internalDataProvider:ArrayList;
		private var _model:IHierarchicalModel;
		
		private var _visibleChildren:Dictionary;
		
		public function HierarchicalDataProvider(model:IHierarchicalModel)
		{
			_internalDataProvider = new ArrayList();
			_internalDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, _internalDataProviderCollectionChangeHandler);
			_internalDataProvider.source = model.source.toArray();
			
			_visibleChildren = new Dictionary(true);
		}
		
		private function _internalDataProviderCollectionChangeHandler(e:CollectionEvent):void
		{
			dispatchEvent(e);
		}

		private function _getContainingList(object:Object = null):IList
		{
			var parent:Object;
			if (object)
			{
				parent = _model.getParent(object);
			}
			
			var list:IList;
			if (parent)
			{
				list = _model.getChildren(parent);
			} else
			{
				list = _model.source;
			}
			
			return list;
		}
		
		public function addItem(object:Object):void
		{
			addItemAt(object, _internalDataProvider.length);
		}
		
		public function addItemAt(object:Object, index:int):void
		{
			//update the model
			var currentItem:Object;
			
			if (index > 0 && index < _internalDataProvider.length)
			{
				currentItem = _internalDataProvider.getItemAt(index);
			}
			
			var list:IList = _getContainingList(currentItem);
			
			var realIndex:uint = currentItem ? list.getItemIndex(currentItem) : index;
			list.addItemAt(object, realIndex);
			
			//update the internal dataProvider
			_internalDataProvider.addItemAt(object, index);
		}
		
		public function get length():int
		{
			return _internalDataProvider.length;
		}
		
		public function getItemAt(index:int, prefetch:int = 0):Object
		{
			return _internalDataProvider.getItemAt(index, prefetch);
		}
		
		public function getItemIndex(object:Object):int
		{
			return _internalDataProvider.getItemIndex(object);
		}
		
		public function itemUpdated(object:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
		{
			_internalDataProvider.itemUpdated(object, property, oldValue, newValue);
		}
		
		public function removeAll():void
		{
			//update the model
			_model.source.removeAll();
			
			//update the internal dataProvider
			_internalDataProvider.removeAll();
		}
		
		public function removeItemAt(index:int):Object
		{
			//update the model
			var item:Object = _internalDataProvider.getItemAt(index);
			var list:IList = _getContainingList(item);
			list.removeItemAt(list.getItemIndex(item));
			
			//update the internal dataProvider
			_internalDataProvider.removeItemAt(index);
			
			return item;
		}
		
		public function setItemAt(object:Object, index:int):Object
		{
			//update the model
			var item:Object = _internalDataProvider.getItemAt(index);
			var list:IList = _getContainingList(item);
			list.setItemAt(object, list.getItemIndex(item));
			
			//update the internal dataProvider
			_internalDataProvider.setItemAt(object, index);
			
			return item;
		}
		
		public function toArray():Array
		{
			return _internalDataProvider.toArray();
		}
		
		public function showChildren(object:Object):void
		{
			if (!_visibleChildren[object])
			{
				var children:IList = _model.getChildren(object);
				
				var startIndex:int = getItemIndex(object) + 1;
			
				var i:uint;
				var child:Object;
				for (i = 0; i < children.length; i++)
				{
					child = children.getItemAt(i);
					_internalDataProvider.addItemAt(child, startIndex + i);
				}
				
				_visibleChildren[object] = true;
			}
		}
		
		public function hideChildren(object:Object):void
		{
			if (_visibleChildren[object])
			{
				var children:IList = _model.getChildren(object);
				
				//loop backwards through the children in order to close them in a nested fasion
				var i:uint = children.length;
				var child:Object;
				var childIndex:int;
				while (i--)
				{
					child = children.getItemAt(i);
					childIndex = _internalDataProvider.getItemIndex(child);
					hideChildren(child);
					_internalDataProvider.removeItemAt(childIndex);
				}
				
				delete _visibleChildren[object];
			}
		}
		
		public function get model():IHierarchicalModel
		{
			return _model;
		}
	}
}