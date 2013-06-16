package app.model.vo
{
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class FeedbackVO
	{
		public var no:Number = 0;
		
		public var report:ReportVO;
		
		public var date:Date = new Date;
		public function get FeedbackDate():String
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd";
			
			return date == null?"":dateF.format(date);
		}
		
		public var remark:String = "";
		
		public var listAttach:ArrayCollection;
		
		public function get attach():String
		{
			var result:String = "";
			for each(var attach:FeedbackAttachVO in listAttach)
			{
				if(attach != null)
				{
					result += attach.fileName + ";";
				}
			}
			
			return result; 
		}
		
		public function FeedbackVO(item:Object = null)
		{
			this.listAttach = new ArrayCollection;		
			
			if(item != null)
			{
				this.no = item.编号;
				this.date = item.反馈日期;
				this.remark = item.反馈意见;
				for each(var fileName:String in String(item.附件).split(";"))
				{
					if(fileName != "")
					{
						var attach:FeedbackAttachVO = new FeedbackAttachVO;
						attach.fileName = fileName;
						this.listAttach.addItem(attach);
					}
				}
			}
			else
			{
				this.report = new ReportVO;				
			}
		}
	}
}