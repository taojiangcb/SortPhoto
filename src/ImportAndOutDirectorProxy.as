package
{
	import application.AppUI;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import gframeWork.JT_IDisposable;
	import gframeWork.uiController.JT_UserInterfaceManager;
	
	/**
	 * 照片的导入导出目录控制处理。。。 
	 * @author taojiang
	 * 
	 */	
	public class ImportAndOutDirectorProxy implements JT_IDisposable
	{
		private var importFile:File;
		public function ImportAndOutDirectorProxy()
		{
			internalInit();
		}
		
		private function internalInit():void
		{
			ui.btnSelectIn.addEventListener(MouseEvent.CLICK,importClickHandler,false,0,true);
			ui.btnSelectout.addEventListener(MouseEvent.CLICK,outportClickHandler,false,0,true);
		}
		
		private function importClickHandler(event:MouseEvent):void
		{
			if(!importFile) importFile = new File();
			
			var chrooseInDirectory:Function = function(event:Event):void
			{
				ui.txtInport.text = importFile.nativePath;
				DataModel.IN_DIRECTORY = importFile.url;
				importFile.removeEventListener(Event.SELECT,chrooseInDirectory);
			};
			
			importFile.addEventListener(Event.SELECT,chrooseInDirectory,false,0,true);
			importFile.browseForDirectory("请选择要导入的目标地址");
		}
		
		private function outportClickHandler(event:MouseEvent):void
		{
			if(!importFile) importFile = new File();
			
			var chrooseOutDirectory:Function = function(event:Event):void
			{
				ui.txtOutport.text = importFile.nativePath;
				DataModel.OUT_DIRECTORY = importFile.url;
				importFile.removeEventListener(Event.SELECT,chrooseOutDirectory);
			}
				
			importFile.addEventListener(Event.SELECT,chrooseOutDirectory,false,0,true);
			importFile.browseForDirectory("请选择导出的目录");
		}
		
		public function dispose():void
		{
			
		}
		
		private function get ui():MainPanel
		{
			return JT_UserInterfaceManager.getUIByID(AppUI.MAINUI_PANEL).getGui() as MainPanel
		}
	}
}