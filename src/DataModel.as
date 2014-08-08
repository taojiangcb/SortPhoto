package
{
	import flash.filesystem.File;

	public class DataModel
	{
		//输入目录
		public static var IN_DIRECTORY:String = "";
		//输出目录
		public static var OUT_DIRECTORY:String = "";
		
		private static var mInstance:DataModel;
		public static function get instance():DataModel
		{
			if(!mInstance)
			{
				mInstance = new DataModel();
			}
			return mInstance;
		}
		
		public var analysizeFiles:Vector.<String>;
		
		public function DataModel()
		{
			analysizeFiles = new Vector.<String>();
		}
		
		/**
		 * 根据一个根目录筛选出所有的文件 
		 * @param rootpath
		 * @return 
		 * 
		 */		
		public function filterAllFile(rootFile:File,refSource:Vector.<String>):void
		{
			var noteFile:File = rootFile;
			var i:int = 0;
			var len:int = 0;
			if(noteFile.isDirectory)
			{
				var list:Array = noteFile.getDirectoryListing();
				len = list.length;
				for(i = 0; i!= len; i++)
				{
					filterAllFile(list[i],refSource);
				}
			}
			else
			{
				refSource.push(noteFile.url);
			}
		}
		
	}
}