package app.view
{
	import app.AppEvent;
	import app.ApplicationFacade;
	import app.controller.WebServiceCommand;
	import app.model.FeedbackProxy;
	import app.model.dict.GroupDict;
	import app.model.vo.FeedbackVO;
	import app.model.vo.ReportVO;
	import app.view.components.PopupFeedback;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PopupFeedbackMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "PopupFeedbackMediator";
		
		private var feedbackProxy:FeedbackProxy;
		
		public function PopupFeedbackMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			popupFeedback.addEventListener(FlexEvent.CREATION_COMPLETE,onCreation);
			
			popupFeedback.addEventListener(PopupFeedback.CLOSE,onClose);
			popupFeedback.addEventListener(PopupFeedback.SUBMIT,onSubmit);
			
			popupFeedback.addEventListener(AppEvent.UPLOADATTACH,onUploadAttach);
			
			feedbackProxy = facade.retrieveProxy(FeedbackProxy.NAME) as FeedbackProxy;		
		}
		
		protected function get popupFeedback():PopupFeedback
		{
			return viewComponent as PopupFeedback;
		}
		
		private function onCreation(event:FlexEvent):void
		{
			popupFeedback.maxHeight = popupFeedback.height;
			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_CREATE);
		}
		
		private function onClose(event:Event):void
		{			
			sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
		}
				
		private function onSubmit(event:Event):void
		{								
			sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
				["GetTable",onGetResult
					,[
						"SELECT * FROM " + WebServiceCommand.VIEW_REPORT
						+ " WHERE 年度  = '" + popupFeedback.numYear.value
						+ "' AND 类别 = " + popupFeedback.comboGroup.selectedIndex
						+ " AND 编号 = " + popupFeedback.numNo.value
						+ " AND 次级编号  = 0"
					]
				]);
			
			function onGetResult(result:ArrayCollection):void
			{						
				if(result.length == 0)
				{
					sendNotification(ApplicationFacade.NOTIFY_APP_ALERTALARM,"未找到对应编号案件信息。");
					return;
				}
				else
				{
					popupFeedback.feedback.report = new ReportVO(result[0]);
					sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
						["GetTable",onGetMaxID
							,[
								"SELECT MAX(编号) AS MAXID FROM 跟踪反馈"
								+ " WHERE 报告ID = " + popupFeedback.feedback.report.id
							]
						]);
				}
			}
			
			function onGetMaxID(result:ArrayCollection):void
			{					
				var maxID:Number = 0;
				if(result[0] != null)
					maxID = Number(result[0].MAXID) + 1;
				else
					maxID = 1;
				
				popupFeedback.feedback.no = maxID;
				
				feedbackProxy.save(popupFeedback.feedback);
														
				sendNotification(ApplicationFacade.NOTIFY_WEBSERVICE_SEND,
					["SetTable",onSetResult
						,[
							"INSERT INTO 跟踪反馈 (报告ID,编号,反馈日期,反馈意见,附件) " +
							"VALUES (" + popupFeedback.feedback.report.id +
							"," + popupFeedback.feedback.no +
							",#" + popupFeedback.dateFeedback.text + "#" +
							",'" + popupFeedback.textReson.text + "'" +
							",'" + popupFeedback.feedback.attach + "');"
						]
					]);
			}
			
			function onSetResult(result:Number):void
			{							
				sendNotification(ApplicationFacade.NOTIFY_POPUP_HIDE);
				
				sendNotification(ApplicationFacade.NOTIFY_APP_ALERTINFO,"成功提交反馈信息。");
			}
		}
		
		private function onUploadAttach(event:AppEvent):void
		{
			feedbackProxy.uploadAttach(popupFeedback.feedback);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				ApplicationFacade.NOTIFY_APP_INIT,
				ApplicationFacade.NOTIFY_POPUP_SHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.NOTIFY_APP_INIT:
					popupFeedback.listGroup = GroupDict.list;
					break;
				
				case ApplicationFacade.NOTIFY_POPUP_SHOW:
					if(notification.getBody()[0] == popupFeedback)
					{							
						popupFeedback.feedback = new FeedbackVO;
						popupFeedback.feedback.listAttach.addItem(null);
					}
			}
		}
	}
}