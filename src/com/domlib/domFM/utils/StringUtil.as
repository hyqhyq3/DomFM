package com.domlib.domFM.utils
{
	/**
	 * 字符串工具类
	 * @author DOM
	 */	
	public class StringUtil
	{
		/**
		 * 去掉字符串两端所有连续的Tab，空格，换行，回车这些不可见的字符。
		 * 注意：若目标字符串为null或不含有任何可见字符,将输出空字符串""。
		 * @param str 要格式化的字符串
		 */		
		public static  function trim(str:String):String
		{
			if(str==""||str==null)
				return "";
			var char:String = str.charAt(0);
			while(str.length>0&&
				(char==" "||char=="\t"||char=="\n"||char=="\r"))
			{
				str = str.substr(1);
				char = str.charAt(0);
			}
			char = str.charAt(str.length-1);
			while(str.length>0&&
				(char==" "||char=="\t"||char=="\n"||char=="\r"))
			{
				str = str.substr(0,str.length-1);
				char = str.charAt(str.length-1);
			}
			return str;
		}
		
		/**
		 * 替换指定的字符串里所有的p为rep
		 */		
		public static function replaceStr(targetStr:String,p:String,rep:String):String
		{
			var arr:Array = targetStr.split(p);
			return arr.join(rep);
		}
		/**
		 * 将颜色数字代码转换为字符串。
		 */		
		public static function toColorString(color:uint):String
		{
			var str:String = color.toString(16).toUpperCase();
			var num:int = 6-str.length;
			for(var i:int=0;i<num;i++)
			{
				str = "0"+str;
			}
			return "0x"+str;
		}
		/**
		 * 格式化文件长度为带单位的字符串
		 * @param length 文件长度,单位:字节。
		 * @param fractionDigits 要近似保留的小数位数,若为-1，则输出完整的大小。
		 */		
		public static function toSizeString(length:Number,fractionDigits:int=-1):String
		{
			var sizeStr:String = "";
			if(fractionDigits==-1)
			{
				if(length>1073741824)
				{
					sizeStr += int(length/1073741824).toString()+"GB";
					length = length%1073741824;
				}
				if(length>1048576)
				{
					sizeStr += int(length/1048576).toString()+"MB";
					length = length%1048576;
				}
				if(length>1204)
				{
					sizeStr += int(length/1204).toString()+"KB";
					length = length%1204;
				}
				if(length>0)
				{
					sizeStr += length.toString()+"B";
				}
			}
			else
			{
				if(length>1073741824)
				{
					sizeStr = Number(length/1073741824).toFixed(fractionDigits)+"GB";
				}
				else if(length>1048576)
				{
					sizeStr = Number(length/1048576).toFixed(fractionDigits)+"MB";
				}
				else if(length>1204)
				{
					sizeStr = Number(length/1204).toFixed(fractionDigits)+"KB";
				}
				else
				{
					sizeStr = length.toString()+"B";
				}
			}
			return sizeStr;
		}
		/**
		 * 把时间(毫秒)转换为字符串
		 */		
		public static function toTimeString(time:Number):String
		{
			time = Math.round(time/1000);
			var miniute:String = "00";
			var abs:Boolean = time<0;
			time = Math.abs(time);
			if(time>=60)
			{
				miniute = int(time/60).toString();
				if(time/60<10)
				{
					miniute = "0"+miniute;
				}
				time = time%60;
			}
			var second:String = "00";
			if(time>0)
			{
				second = int(time).toString();
				if(time<10)
				{
					second = "0"+second;
				}
			}
			var str:String = miniute+":"+second;
			if(abs)
				str = "-"+str;
			return str;
		}
		/**
		 * 根据时间字符串得到时间总数，单位秒。
		 */		
		public static function getTime(timeStr:String):Number
		{
			var lines:Array = trim(timeStr).split(":");
			var num:Number = 1;
			var time:Number = 0;
			while(lines.length>0)
			{
				time += Number(lines.pop())*num;
				num *= 60;
			}
			return time;
		}
	}
}