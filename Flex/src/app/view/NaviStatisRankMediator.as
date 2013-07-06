package app.view
{
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.ReportYearProxy;
	import app.model.dict.ReportStatusDict;
	import app.model.vo.ReportVO;
	import app.view.components.NaviStatisRank;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.gridClasses.GridColumn;
	
	public class NaviStatisRankMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "NaviStatisRankMediator";
		
		public function NaviStatisRankMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			naviStatisRank.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			naviStatisRank.addEventListener(NaviStatisRank.SUBMIT,onSubmit);
			naviStatisRank.addEventListener(NaviStatisRank.DOWNLOAD,onDownload);
		}
		
		protected function get naviStatisRank():NaviStatisRank
		{
			return viewComponent as NaviStatisRank;
		}
		
		private function onCreation(event:FlexEvent):void
		{					
			var reportYearProxy:ReportYearProxy = facade.retrieveProxy(ReportYearProxy.NAME) as ReportYearProxy;
			
			naviStatisRank.comboTime.selectedIndex = 0;
			
			naviStatisRank.comboYear.dataProvider = reportYearProxy.list;
			naviStatisRank.comboYear.selectedIndex = 1;
			
			var arr:ArrayCollection = new ArrayCollection;
			for(var i:Number = 1;i < reportYearProxy.list.length;i++)
				arr.addItem(reportYearProxy.list[i]);
			naviStatisRank.comboMonthYear.dataProvider = arr;
			naviStatisRank.comboMonthYear.selectedIndex = 0;
			naviStatisRank.comboMonth.selectedIndex = (new Date).month;
			
			naviStatisRank.comboType.selectedIndex = 0;
			
			naviStatisRank.columnChart.dataProvider = null;
			naviStatisRank.gridReport.dataProvider = null;
		}
		
		private function onDownload(event:Event):void
		{
			if(naviStatisRank.comboType.selectedIndex == 0)
			{			
				var data:String = "";
				for each(var item:Object in naviStatisRank.gridReport.dataProvider)
				{
					data += item.年度  + "/C/";
					data += naviStatisRank.labelGroup(item,null)  + "/C/";
					data += naviStatisRank.labelNo(item,null)  + "/C/";
					data += item.姓名  + "/C/";
					data += item.评分  + "/R/";
				}
				
				print(data,"评分统计_打印人");
			}
			else if(naviStatisRank.comboType.selectedIndex == 1)
			{
				data = "";
				for each(item in naviStatisRank.gridReport.dataProvider)
				{
					data += item.年度  + "/C/";
					data += naviStatisRank.labelGroup(item,null)  + "/C/";
					data += naviStatisRank.labelNo(item,null)  + "/C/";
					data += item.姓名  + "/C/";
					data += item.评分  + "/R/";
				}
				
				print(data,"评分统计_受理人C");
			}
			else
			{
				data = "";
				for each(item in naviStatisRank.gridReportAll.dataProvider)
				{
					data += item.年度  + "/C/";
					data += naviStatisRank.labelGroup(item,null)  + "/C/";
					data += naviStatisRank.labelNo(item,null)  + "/C/";
					data += item.打印人姓名  + "/C/";
					data += item.初稿评分  + "/C/";
					data += item.受理人C姓名  + "/C/";
					data += item.初审评分  + "/R/";
				}
				
				print(data,"评分统计_所有评分");
			}
		}
		
		private function print(data:String,name:String):void
		{
			var url:String =  WebServiceCommand.WSDL + "PrintTable.aspx";
			url += "?file=" + name;	
			
			if(data != "")
			{				
				var downloadURL:URLRequest = new URLRequest(encodeURI(url));				
				downloadURL.method = URLRequestMethod.POST;
				downloadURL.contentType = "text/plain";	
				downloadURL.data = encodeURIComponent(data);
				
				var fileRef:FileReference = new FileReference;
				fileRef.addEventListener(Event.SELECT,onFileSelect);		
				fileRef.addEventListener(Event.COMPLETE,onDownloadFile);
				fileRef.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
				
				fileRef.download(downloadURL,name + ".xls");	
			}
			else
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"请先统计评分结果。");
			}
						
			function onFileSelect(event:Event):void
			{						
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGSHOW,"正在下载《" + name + "》...");				
			}
			
			function onDownloadFile(event:Event):void 
			{							
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);	
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"《" + name + "》下载成功。");	
			}	
			
			function onIOError(event:IOErrorEvent):void
			{
				sendNotification(ApplicationFacade.NOTIFY_APP_LOADINGHIDE);		
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTERROR,"文件传输失败。");	
			}	
		}
		
		private function onSubmit(event:Event):void
		{
			var sql:String = "SELECT 年度,类别,编号,次级编号,";
			if(naviStatisRank.comboType.selectedIndex == 0)
			{			
				naviStatisRank.columnName.headerText = "打印人";
			
				sql += "打印人 AS 用户,打印人姓名 AS 姓名,(初审分数 + 1) AS 评分 FROM " + WebServiceCommand.VIEW_REPORT
				+ " WHERE 初审分数 <> -1 and 初审分数 < " + naviStatisRank.comboRank.labelDisplay.text;
			}
			else if(naviStatisRank.comboType.selectedIndex == 1)
			{
				naviStatisRank.columnName.headerText = "受理人C";
				
				sql += "受理人C AS 用户,受理人C姓名 AS 姓名,(复审分数 + 1) AS 评分 FROM " + WebServiceCommand.VIEW_REPORT
					+ " WHERE 复审分数 <> -1 and 复审分数 < " + naviStatisRank.comboRank.labelDisplay.text;
			}
			else
			{
				sql += "打印人姓名,(初审分数 + 1) AS 初稿评分,受理人C姓名,(复审分数 + 1) AS 初审评分 FROM " + WebServiceCommand.VIEW_REPORT
					+ " WHERE 初审分数 <> -1 AND 复审分数 <> -1";
			}
			
			if(naviStatisRank.comboTime.selectedIndex == 0)
			{
				if(naviStatisRank.comboYear.selectedIndex > 0)
				{
					sql += " AND 年度 = '" + naviStatisRank.comboYear.labelDisplay.text + "' ";
				}
			}
			else
			{
				sql += " AND Year(受理日期) = " + naviStatisRank.comboMonthYear.labelDisplay.text 
					+ " AND Month(受理日期) = " + (naviStatisRank.comboMonth.selectedIndex + 1);
			}
			sql += " ORDER BY ID"; 
			
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[sql]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{						
				if(naviStatisRank.comboType.selectedIndex < 2)
				{
					naviStatisRank.gridReport.dataProvider = result;
					
					var userDict:Dictionary = new Dictionary
					
					for each(var item:Object in result)
					{
						var user:Object = userDict[item.用户];
						if(user == null)
						{
							user = {};
							user.姓名 = item.姓名;
							user.评分 = item.评分;
							user.数量 = 1;
							
							userDict[item.用户] = user;
						}
						else
						{
							user.评分 += item.评分;
							user.数量 ++;
						}
					}
					
					var chartDatapro:ArrayCollection = new ArrayCollection;
					for each(user in userDict)
					{
						var chartItem:Object = {};
						chartItem.姓名 = user.姓名;
						chartItem.评分 = Number(Number(user.评分 / user.数量).toFixed(2));
						
						chartDatapro.addItem(chartItem);
					}
					
					naviStatisRank.columnChart.dataProvider = chartDatapro;	
				}
				else
				{
					naviStatisRank.gridReportAll.dataProvider = result;
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{								
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == (facade.retrieveMediator(PopupStatisMediator.NAME) as PopupStatisMediator).getViewComponent()
						&& naviStatisRank.initialized)
					{				
						onCreation(null);
					}
					break;
			}
		}
	}
}