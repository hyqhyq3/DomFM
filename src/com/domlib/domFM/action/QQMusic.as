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
		
		private var albumUrl:String = "http://soso.music.qq.com/fcgi-bin/music_json.fcg?json=1&utf8=1&t=8&w=";
		private var artistUrl:String = "http://soso.music.qq.com/fcgi-bin/music_json.fcg?json=1&utf8=1&t=0&w=";
		/**
		 * 回调函数字典  
		 */		
		private var compFuncDic:Dictionary = new Dictionary();
		
		private var keyWordDic:Dictionary = new Dictionary();
		/**
		 * 搜索专辑封面
		 * @param artist 歌手名
		 * @param album 专辑名
		 * @param compFunc 搜索结果回调函数,示例：compFunc(url:String):void
		 */		
		public function searchCover(artist:String,album:String,compFunc:Function):void
		{
			if((!artist&&!album)||compFunc==null)
				return;
			var key:String = "";
			if(artist)
				key += artist;
			if(album)
				key += " "+album;
			var loader:URLLoader = new URLLoader;
			compFuncDic[loader] = compFunc;
			keyWordDic[loader] = {artist:artist,album:album};
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,onAlbumComp);
			loader.load(new URLRequest(encodeURI(albumUrl+key)));
			
		}
		/**
		 * 数据请求返回
		 */		
		private function onAlbumComp(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var result:String = getResult(loader);
			var list:Array = getAlbumList(result);
			var compFunc:Function = compFuncDic[loader];
			var song:Object = keyWordDic[loader];
			delete keyWordDic[loader];
			delete compFuncDic[loader];
			var albumId:String = "";
			if(list.length==1)
				albumId = list[0].id;
			else if(list.length>1)
			{
				var found:Boolean = false;
				for each(var album:Object in list)
				{
					if(album.name == song.album)
					{
						albumId = album.id;
						found = true
						break;
					}
				}
				if(!found)
				{
					albumId = list[list.length-1].id;
				}
			}
			var url:String = getCoverUrl(albumId);
			compFunc(url);
		}
		/**
		 * 根据loader返回字符串结果
		 */		
		private function getResult(loader:URLLoader):String
		{
			var bytes:ByteArray = loader.data;
			bytes.position = 0;
			var result:String = bytes.readMultiByte(bytes.length,"cn-gb");
			return result;
		}
		
		/**
		 * 搜索歌手图片
		 * @param artist 歌手姓名
		 * @param compFunc 搜索结果回调函数,示例：compFunc(url:String):void
		 */		
		public function searchArtist(artist:String,compFunc:Function):void
		{
			if(!artist||compFunc==null)
				return;
			var loader:URLLoader = new URLLoader;
			compFuncDic[loader] = compFunc;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,onArtistComp);
			loader.load(new URLRequest(encodeURI(artistUrl+artist)));
		}
		/**
		 * 歌手信息返回
		 */		
		private function onArtistComp(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var result:String = getResult(loader);
			var compFunc:Function = compFuncDic[loader];
			delete compFuncDic[loader];
			var artistId:String = "";
			var index:int = result.indexOf("list:[{");
			if(index!=-1)
			{
				result = result.substring(index+7);
				index = result.indexOf("|");
				result = result.substring(index+1);
				index = result.indexOf("|");
				result = result.substring(index+1);
				index = result.indexOf("|");
				artistId = result.substring(0,index);
			}
			var url:String = getArtsitUrl(artistId);
			compFunc(url);
		}
		/**
		 * 解析字符串为专辑列表
		 */		
		private function getAlbumList(result:String):Array
		{
			var list:Array = [];
			var index:int = result.indexOf("list:[");
			if(index==-1)
				return list;
			result = result.substring(index+6);
			index = result.indexOf("],");
			if(index==-1)
				return list;
			result = result.substring(0,index);
			var strs:Array = result.split("},{");
			for each(var str:String in strs)
			{
				index = str.indexOf("albumID:");
				if(index==-1)
					continue;
				str = str.substring(index+8);
				index = str.indexOf(",");
				var album:Object = {};
				album.id = str.substring(0,index);
				str = str.substr(index+12);
				index = str.indexOf("\",");
				album.name = StringUtil.trim(str.substring(0,index));
				list.push(album);
			}
			return list;
		}
		
		private static const coverPicUrl:String = "http://imgcache.qq.com/music/photo/album/";
		/**
		 * 根据专辑ID获取专辑图片地址
		 */		
		private function getCoverUrl(albumId:String):String
		{
			var id:Number = Number(albumId);
			if(isNaN(id))
				return "";
			return coverPicUrl+(id%100)+"/albumpic_"+albumId+"_0.jpg";
		}
		
		private static const artistPicUrl:String = "http://imgcache.qq.com/music/photo/singer/";
		/**
		 * 根据专辑ID获取专辑图片地址
		 */		
		private function getArtsitUrl(artistId:String):String
		{
			var id:Number = Number(artistId);
			if(isNaN(id))
				return "";
			return artistPicUrl+(id%100)+"/singerpic_"+artistId+"_0.jpg";
		}
	}
}