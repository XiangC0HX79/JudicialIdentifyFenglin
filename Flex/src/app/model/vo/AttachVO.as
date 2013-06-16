package app.model.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class AttachVO
	{
		public static const IMG_WIDTH:Number = 100;
		public static const IMG_HEIGHT:Number = 100;
		
		public var listImage:ArrayCollection;
				
		public var listConsultImage:ArrayCollection;
		
		public var consultResult:Boolean = false;	
		
		public var identifyDraft:Boolean = false;
		public var identifyFstExamin:Boolean = false;
		public var identifySndExamin:Boolean = false;
		public var identifyFinal:Boolean = false;
		
		public var modifyImage:Boolean = false;
		public var modifyFstExamin:Boolean = false;
		public var modifySndExamin:Boolean = false;
		public var modifyFinal:Boolean = false;
		
		public function AttachVO()
		{
			this.listImage = new ArrayCollection;
			
			this.listConsultImage = new ArrayCollection;
		}
	}
}