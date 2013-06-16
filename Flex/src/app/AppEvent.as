package app
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{		
		/**
		 * 上传文件
		 */		
		public static const UPLOAD:String = "upload";
		
		/**
		 * 下载文件
		 */		
		public static const DOWNLOAD:String = "download";
		
		/**
		 * 上传附件
		 */		
		public static const UPLOADATTACH:String = "uploadattach";
		
		/**
		 * 上传附件
		 */		
		public static const DOWNLOADATTACH:String = "downloadattach";
		
		/**
		 * 删除附件
		 */		
		public static const DELETEATTACH:String = "deleteattach";
		
		/**
		 * 查看附件
		 */		
		public static const NAVIATTACH:String = "naviattach";
		
		public var data:*;
		
		public function AppEvent(type:String,data:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
	}
}