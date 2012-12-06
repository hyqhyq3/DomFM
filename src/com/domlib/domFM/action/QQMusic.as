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
		
		private var url:String = "http://shopcgi.qqmusic.qq.com/fcgi-bin/shopsearch.fcg?type=qry_song&out=json&value=";
		/**
		 * 回调函数字典  
		 */		
		private var compFuncDic:Dictionary = new Dictionary();
		/**
		 * 搜索专辑封面
		 * @param artist 歌手名
		 * @param title 歌曲名
		 * @param compFunc 搜索结果回调函数,示例：compFunc(url:String):void
		 */		
		public function searchCover(artist:String,title:String,compFunc:Function):void
		{
			if(compFunc==null)
				return;
			var key:String = "";
			if(artist)
				key += artist;
			if(title)
				key += " "+title;
			var loader:URLLoader = sendRequest("\""+artist+" "+title+"\"");
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
			trace(str);
			var index:int = str.indexOf("album_id");
			var url:String = "";
			if(index!=-1)
			{
				str = str.substring(index+10);
				index = str.indexOf("\"");
				url = getCoverUrl(str.substring(0,index));
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
	}
}