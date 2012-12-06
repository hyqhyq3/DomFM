package com.domlib.domFM.action
{
	import com.domlib.domFM.utils.StringUtil;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.controls.HTML;
	import mx.utils.XMLUtil;
	
	
	/**
	 * QQ音乐API
	 * @author DOM
	 */
	public class QQMusic
	{
		/**
		 * 构造函数
		 */		
		public function QQMusic()
		{
			super();
		}
		
		private var url:String = "http://shopcgi.qqmusic.qq.com/fcgi-bin/shopsearch.fcg?value=";
		/**
		 * 回调函数字典
		 */		
		private var compFuncDic:Dictionary = new Dictionary();
		/**
		 * 搜索专辑封面
		 * @param artist 歌手名
		 * @param album 专辑名
		 * @param compFunc 搜索结果回调函数,示例：compFunc(url:String):void
		 */		
		public function searchCover(artist:String,album:String,compFunc:Function):void
		{
			if(compFunc==null)
				return;
			var key:String = "";
			if(artist)
				key += artist;
			if(album)
				key += " "+album;
			var loader:URLLoader = sendRequest(artist+" "+album);
			compFuncDic[loader] = compFunc;
		}
		/**
		 * 发送请求
		 */		
		private function sendRequest(key:String):URLLoader
		{
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,onComp);
			loader.load(new URLRequest(encodeURI(url+key)));
			return loader;
		}
		/**
		 * 数据请求返回
		 */		
		private function onComp(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var compFunc:Function = compFuncDic[loader];
			delete compFuncDic[loader];
			var bytes:ByteArray = loader.data;
			bytes.position = 0;
			var str:String = bytes.readMultiByte(bytes.bytesAvailable,"cn-gb");
			str = str.substring(15,str.length-2);
			var result:Object = parseObject(str);
			if(!result)
			{
				compFunc("");
				trace("JSON解析失败："+str);
				return;
			}
			var url:String = "";
			var song:Object = result.songlist[0];
			if(song)
			{
				url = getCoverUrl(song.album_id);
			}
			compFunc(url);
		}
		
		private static const coverUrl:String = "http://imgcache.qq.com/music/photo/album/";
		private function getCoverUrl(albumId:String):String
		{
			var id:Number = Number(albumId);
			if(isNaN(id))
				return "";
			return coverUrl+(id%100)+"/albumpic_"+albumId+"_0.jpg";
		}
		/**
		 * 解析字符串为Object
		 */		
		private function parseObject(result:String):Object
		{
			var list:Array = result.split(",");
			result = "";
			var itemIndex:int = 0;
			for each(var item:String in list)
			{
				var strs:Array = item.split(":");
				var index:int = 0;
				for each(var str:String in strs)
				{
					if(index==strs.length-1)
						result += str;
					else
						result += formatStr(str)+":";
					index++;
				}
				if(itemIndex<list.length-1)
					result += ",";
				itemIndex++;
			}
			
			result = escape(result);
			var obj:Object;
			try
			{
				obj = JSON.parse(result);
			}
			catch(e:Error){}
			return obj;
		}
		
		private var htmlContents:Object = {"&acute;":"'","&quot;":"\"",
			"&amp;":"&","&lt;":"<","&gt;":">","&nbsp;":" "};
		
		private function escape(str:String):String
		{
			for(var s:String in htmlContents)
			{
				str = StringUtil.replaceStr(str,s,htmlContents[s]);
			}
			return str;
		}
		/**
		 * 给key加上双引号
		 */		
		private function formatStr(str:String):String
		{
			var pos:int = 0;
			while(pos<str.length)
			{
				var char:String = str.charAt(pos);
				if(char!="{"&&char!="[")
					break;
				pos++;
			}
			return str.substring(0,pos)+"\""+str.substr(pos)+"\"";
		}
	}
}