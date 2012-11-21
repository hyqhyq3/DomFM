package 
{
	import avmplus.getQualifiedClassName;
	
	import com.hurlant.eval.ByteLoader;
	import com.hurlant.eval.CompiledESC;
	import com.hurlant.eval.Evaluator;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	public class SearchService extends EventDispatcher
	{
		var searchURL:String = "http://shopcgi.qqmusic.qq.com/fcgi-bin/shopsearch.fcg"; 
		var songinfoURL:String = "http://s.plcloud.music.qq.com/fcgi-bin/fcg_query_song_detail_info.fcg"

		private var l:URLLoader;

		private var esc:CompiledESC = new CompiledESC;
		private static var _instance:SearchService;
		
		public function SearchService()
		{
			if (_instance!=null) {
				throw new Error("cannot create singleton");
			}
		}
		
		public static function getInstance():SearchService
		{
			if (_instance == null) {
				_instance = new SearchService();
			}
			return _instance;
		}
			
		public function search(keyword:String):void
		{
			var r:URLRequest = new URLRequest;
			r.url = searchURL;
			var v:URLVariables = new URLVariables;
			v.utf8 = 1;
			v.type = "qry_song";
			v.value = keyword;
			r.data = v;
			l = new URLLoader(r);
			l.dataFormat = "binary";
			l.addEventListener(Event.COMPLETE, onSearchResult);
		}
		
		public function searchCallBack(obj:Object):void
		{
			var song_ids:Array = [];
			for each (var song:Object in obj.songlist) {
				song_ids.push(song.song_id);	
			}
			var v:URLVariables = new URLVariables;
			v.type = 3;
			v.num = song_ids.length;
			v.g_tk = 5381;
			v.song_id = song_ids.join(",");
			
			var r:URLRequest =new URLRequest;
			r.url = songinfoURL;
			r.data = v;
			var l:URLLoader = new URLLoader;
			l.dataFormat = "binary";
			l.addEventListener(Event.COMPLETE, onSongInfoResult);
			l.load(r);
		}
		
		public function songInfoCallBack(obj:Object):void
		{
			var songdatas:Array = [];
			var _arrSongAttr:Array = ["mid", "msong", "msingerid", "msinger", "malbumid", "malbum", "msize", "minterval", "mstream", "mdownload", "msingertype", "size320", "size128", "mrate", "gososo", "sizeape", "sizeflac", "sizeogg"];
			for each(var songdata:Object in obj.list) {
				var data:Object = (songdata.songdata as String).split("|");
				var obj:Object = {};
				_arrSongAttr.forEach(function(item:Object,index:int, arr:Array) {
					obj[item] = data[index];
				});
				obj.url = "http://stream" + (int(obj.mstream) + 10) + ".qqmusic.qq.com/" + (int(obj.mid) + 30000000) + ".mp3";
				songdatas.push(obj);
			}
			//songdatas包含了歌曲的信息
		}
		
		protected function onSongInfoResult(event:Event):void
		{
			var raw:ByteArray = (event.target.data as ByteArray);
			var jsonStr:String =  raw.readMultiByte(raw.bytesAvailable, "gb2312").substr(12);
			jsonStr = jsonStr.replace(/^,/mg,"");
			var bytes:* = esc.eval(getQualifiedClassName(this)+".getInstance().songInfoCallBack"+jsonStr);
			ByteLoader.loadBytes(bytes,true);
		}		
		
		protected function onSearchResult(event:Event):void
		{
			var raw:ByteArray = (event.target.data as ByteArray);
			var jsonStr:String =  raw.readMultiByte(raw.bytesAvailable, "gb2312").substr(14);
			var bytes:* = esc.eval(getQualifiedClassName(this)+".getInstance().searchCallBack"+jsonStr);
			ByteLoader.loadBytes(bytes,true);
		}
	}
}