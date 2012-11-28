package me.hyq
{
	
	class Buffer {
		var pos:int;
		var str:String;
		var ch:String;
		function Buffer(str:String, pos:int = 0) {
			this.pos = pos;
			this.str = str;
		}
		
		function next(spaceOk:Boolean = false):String {
			if(pos == str.length) {
				return '';
			}
			ch = str.charAt(pos++);
			while(spaceOk && ch == '\n' || ch == '\t' || ch == '\t') {
				ch = str.charAt(pos++);
			}
			return ch;
		}
		
		function forward(n:int):void {
			pos += n;
			ch = str.charAt(pos);
			return;
		}
		
		function current():String {
			return ch;
		}
		
		function following(n:int):String {
			return str.substr(pos-1, n);
		}	
	}
}