package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import application.AppUI;
	
	import gframeWork.JT_IDisposable;
	import gframeWork.uiController.JT_UserInterfaceManager;
	import gframeWork.utils.LSOManager;
	
	/**
	 * 照片的导入导出目录控制处理。。。 
	 * @author taojiang
	 * 
	 */	
	public class ImportAndOutDirectorProxy implements JT_IDisposable
	{
		private var importFile:File;
		
		private const IN_DIRECOTRY:String = "inDirectory";
		private const OUT_DIRECTORY:String = "outDirectory";
		
		public function ImportAndOutDirectorProxy()
		{
			internalInit();
		}
		
		private function internalInit():void
		{
			ui.btnSelectIn.addEventListener(MouseEvent.CLICK,importClickHandler,false,0,true);
			ui.btnSelectout.addEventListener(MouseEvent.CLICK,outportClickHandler,false,0,true);
			ui.btnSavePath.addEventListener(MouseEvent.CLICK,savePathClickHandler,false,0,true);
			ui.btnAnalyzing.addEventListener(MouseEvent.CLICK,anasyslizeHandler,false,0,true);
			
			var oldOutDirectory:String = LSOManager.get(OUT_DIRECTORY);
			var tmpFile:File;
			if(oldOutDirectory)
			{
				DataModel.OUT_DIRECTORY = oldOutDirectory;
				tmpFile = new File(oldOutDirectory);
				ui.txtOutport.text = tmpFile.nativePath;
			}
			
			var oldInDirectory:String = LSOManager.get(IN_DIRECOTRY);
			if(oldInDirectory)
			{
				DataModel.IN_DIRECTORY = oldInDirectory;
				tmpFile = new File(oldInDirectory);
				ui.txtInport.text = tmpFile.nativePath;
			}
		}
		
		private function savePathClickHandler(event:MouseEvent):void
		{
			LSOManager.put(IN_DIRECOTRY,DataModel.IN_DIRECTORY);
			LSOManager.put(OUT_DIRECTORY,DataModel.OUT_DIRECTORY);
			Alert.show("路径保存成功");
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
		
		private function anasyslizeHandler(event:MouseEvent):void
		{
			var inDir:String = DataModel.IN_DIRECTORY;
			var outDir:String = DataModel.OUT_DIRECTORY;
			if(inDir && inDir.length > 0 && outDir && outDir.length > 0)
			{
				var rootFile:File = new File(inDir);
				DataModel.instance.filterAllFile(rootFile,DataModel.instance.analysizeFiles);
				var liststr:String = DataModel.instance.analysizeFiles.join("\n");
				trace(liststr);
			}
		}
		
		public function dispose():void
		{
			ui.btnSelectIn.removeEventListener(MouseEvent.CLICK,importClickHandler);
			ui.btnSelectout.removeEventListener(MouseEvent.CLICK,outportClickHandler);
			ui.btnSavePath.removeEventListener(MouseEvent.CLICK,savePathClickHandler);
		}
		
		private function get ui():MainPanel
		{
			return JT_UserInterfaceManager.getUIByID(AppUI.MAINUI_PANEL).getGui() as MainPanel
		}
	}
}