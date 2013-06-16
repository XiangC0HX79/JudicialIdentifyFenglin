package app.model.vo
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class LoginVO extends UserVO
	{		
		public var listGroup:ArrayCollection = new ArrayCollection;
		public var listRole:ArrayCollection = new ArrayCollection;
		public var listRight:ArrayCollection = new ArrayCollection;
		
		public function LoginVO(item:Object)
		{
			super(item);
		}
	}
}