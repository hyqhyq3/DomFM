package com.domlib.domFM.events
{
	import com.domlib.domFM.data.ID3Tag;
	
	import flash.events.Event;
	
	
	/**
	 * ID3信息解析事件
	 * @author DOM
	 */
	public class ID3Event extends Event
	{
		/**
		 * 解析成功一首歌曲信息
		 */		
		public static const GET_ONE_INFO:String = "getOneInfo";
		/**
		 * 所有音乐解析完毕
		 */		
		public static const ALL_COMPLETE:String = "allComplete";
		
		public function ID3Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 音乐信息
		 */		
		public var tagInfo:ID3Tag;
		/**
		 * 音乐路径
		 */		
		public var url:String;
	}
}