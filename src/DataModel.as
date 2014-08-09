package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	

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
		
		/*分析的数据结构，其中包含对所有文件的分析结果*/
		public var analysisInfo:AnalysisVO;
		
		private var readFileByte:FileStream;
		private var writeFileByte:FileStream;
		
		public function DataModel()
		{
			analysisInfo = new AnalysisVO();
		}
		
		/**
		 * 根据一个根目录筛选出所有的文件 
		 * @param rootpath
		 * @return 
		 * 
		 */		
		private function filterAllFile(rootFile:File):void
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
					filterAllFile(list[i]);
				}
			}
			else
			{
				analysisInfo.analysizeFiles.push(noteFile);
			}
		}
		
		/**
		 * 合并所有相同名称的文件 
		 * @return 
		 */		
		private function combineSameFile():void
		{
			var combineList:Vector.<File> = new Vector.<File>();
			var i:int = 0;
			var len:int = analysisInfo.analysizeFiles.length;
			var existFlag:int = -1;
			for( i = 0; i != len; i++)
			{
				existFlag = combineList.indexOf(analysisInfo.analysizeFiles[i]);
				if(existFlag == -1)
				{
					combineList.push(analysisInfo.analysizeFiles[i]);
				}
				else
				{
					var crtFile:File = analysisInfo.analysizeFiles[i];
					var sameFileInfo:SameFileVO = analysisInfo.findSameFile(crtFile.name);
					if(!sameFileInfo)
					{
						sameFileInfo = new SameFileVO();
						sameFileInfo.sameNatives.push(crtFile.nativePath);
						sameFileInfo.fileName = crtFile.name;
						analysisInfo.sameFiles.push(sameFileInfo);
					}
					else
					{
						sameFileInfo.sameNatives.push(crtFile.nativePath);
					}
				}
				analysisInfo.combineFiels = combineList;
			}
		}
		
		/**
		 * 以根目录分析文件 
		 * @param rootFile
		 * 
		 */		
		public function analyziseRoot(rootFile:File):void
		{
			if(rootFile && rootFile.exists)
			{
				analysisInfo = new AnalysisVO();
				filterAllFile(rootFile);
				combineSameFile();
				sortByDate();
			}
			
		}
		
		/**
		 * 将所有文件按日期分类 按年月分类 
		 * @return 
		 * 
		 */		
		private function sortByDate():void
		{
			var combineFiles:Vector.<File> = analysisInfo.combineFiels;
			var crtFile:File;
			var i:int = 0;
			var len:int = combineFiles.length;
			for(i = 0; i != len; i++)
			{
				crtFile = combineFiles[i];
				var yearMonth:String = fileYearMonth(crtFile);
				analysisInfo.putFile(yearMonth,crtFile);
			}
		}
		
		/**
		 * 获取一个文件的创建年份和月分以字符的形式返回 
		 * @param file
		 * @return 
		 * 
		 */		
		private function fileYearMonth(file:File):String
		{
			var createDate:Date = file.creationDate;
			var year:String = createDate.getFullYear().toString();
			var month:String = String(createDate.getMonth() + 1);
			return year + "_" + month;
		}
		
		public function exportAllFile():void
		{
			var newDirector:File;
			var sortList:Vector.<File>;
			var key:String;
			var directoryUrl:String = "";
			var writeUrl:String = "";
			var writeFile:File;
			var i:int = 0;
			var len:int = 0;
			var crtFile:File;
			var readBytes:ByteArray = new ByteArray();
			for(key in analysisInfo.sortFileDict)
			{
				directoryUrl = OUT_DIRECTORY + "/" + key;
				newDirector = new File(directoryUrl);
				if(!newDirector.exists)
				{
					newDirector.createDirectory();
				}
				sortList = analysisInfo.getSortFielsByKey(key);
				if(sortList)
				{
					len = sortList.length;
					for(i = 0; i != len; i++)
					{
						crtFile = sortList[i];
						writeUrl = OUT_DIRECTORY + "/" + key + "/" + crtFile.name;
						
						if(!readFileByte)
						{
							readFileByte = new FileStream();
						}
						readFileByte.open(crtFile,FileMode.READ);
						readFileByte.readBytes(readBytes);
						readBytes.position = 0;
						
						if(!writeFile)
						{
							writeFile = new File();
						}
						writeFile.url = writeUrl;
						
						if(!writeFileByte)
						{
							writeFileByte = new FileStream();
						}
						writeFileByte.open(writeFile,FileMode.WRITE);
						writeFileByte.writeBytes(readBytes);
						
						readFileByte.close();
						writeFileByte.close();
						readBytes.clear();
					}
					
				}
				
			}
		}
	}
}

import flash.filesystem.File;
import flash.utils.Dictionary;

import gframeWork.utils.DateUtils;

/**
 * 文件分析的数据结构 
 * @author taojiang
 * 
 */
class AnalysisVO
{
	/*所有相同的文件列表*/
	public var sameFiles:Vector.<SameFileVO>;
	/*所有的文件*/
	public var analysizeFiles:Vector.<File>;
	/*已经合并的相同名称文件列表*/
	public var combineFiels:Vector.<File>;
	//文件按年月进行分类
	public var sortFileDict:Dictionary;
	
	public function AnalysisVO():void
	{
		sameFiles = new Vector.<SameFileVO>();
		analysizeFiles = new Vector.<File>();
		combineFiels = new Vector.<File>();
		sortFileDict = new Dictionary();
	}
	
	/**
	 * 按文件名称寻找相同名称的文件数据信息 
	 * @param fileName
	 * @return 
	 * 
	 */	
	public function findSameFile(fileName:String):SameFileVO
	{
		var i:int = 0;
		var len:int = sameFiles.length;
		for(i = 0; i != len; i++)
		{
			if(sameFiles[i].fileName == fileName)
			{
				return sameFiles[i];
			}
		}
		return null;
	}
	
	/**
	 * 按年月添加一个文件 
	 * @param yearMonth
	 * @param file
	 * 
	 */	
	public function putFile(yearMonth:String,file:File):void
	{
		if(!sortFileDict[yearMonth])
		{
			sortFileDict[yearMonth] = new Vector.<File>();
		}
		//trace(yearMonth,DateUtils.DateFormat(file.creationDate));
		sortFileDict[yearMonth].push(file);
	}
	
	/**
	 * 根据一个分类获取一组件文件信息 
	 * @param key
	 * @return 
	 * 
	 */	
	public function getSortFielsByKey(key:String):Vector.<File>
	{
		return sortFileDict[key];
	}
}

/**
 * 相同文件的数据信息 
 * @author taojiang
 * 
 */
class SameFileVO
{
	//文件路径地址
	public var sameNatives:Vector.<String>;
	//文件名称
	public var fileName:String;
	public function SameFileVO():void
	{
		sameNatives = new Vector.<String>();
	}
	
	/**
	 * 返回相同文件的数量 
	 * @return 
	 * 
	 */	
	public function get sameCount():int
	{
		return sameNatives.length;
	}
	
}
