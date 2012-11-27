package me.hyq {
	public class JSObjectParser {
		public var obj:Object;
		public function JSObjectParser() {

		}

		public function parse(str:String):void {
			var objStr:String = str.substring(str.indexOf('(') + 1, str.lastIndexOf(')') - 1);
			obj = read(new Buffer(str)).value;
		}

		public function readIdent(buf:Buffer):String {
			var ch:String = buf.next();
			var str:String = ch;
			if(! /[a-zA-Z_$]/.test(ch)) {
				throw new Error("expected identify but got " + ch);
			}
			for(;;){
				ch = buf.next();
				if(! /[a-zA-Z0-9_$]/.test(ch)) {
					break;
				}
				str += ch;
			}
			return str;
		}

		public function read(buf:Buffer):Result {
			for(;;) {
				var ch:String = buf.next();
				if(ch == '') {
					return Result.TYPE_END;
				}
				if(ch == '[') {
					//array
					var arr:Array = [];
					for(;;) {
						var item:Result = read(buf);
						if(item.type == Result.TYPE_END) {
							break;
						}
						arr.push(item);
					}
					return new Result(Result.TYPE_ARRAY, arr);
				} else if (ch == '{') {
					//object
					var obj:Object = {};
					for (;;){
						var ident:String = readIdent(buf);
						var ret:Result = read(buf);
						obj[ident] = ret.value;
					}
					return new Result(Result.TYPE_OBJECT, obj);
				} else if (ch == '"' || ch == "'") {
					//string
					var iteral:String = ch;
					var str:String = "";
					var c:String = "":
					for (;;) {
						c = buf.next(true);
						if(c == iteral) {
							break;
						}
						if(c == '\\') {
							c = buf.next();
						}
						str += c;
					}
					return new Result(Result.TYPE_STRING, str);
				} else if( ch.charCodeAt(0) >= 48 && ch.charCodeAt(0) < 58 || ch == '-') {
					//number
					var number:String = "";
					for (;;) {
						var c:String = buf.next();
						if(c.charCodeAt(0) >= 48 && c.charCodeAt(0) < 58 || c == ".") {
							number += c;
						}
					}
					return new Result(Result.TYPE_NUMBER, Number(number));
				} else if( buf.following(4) == 'null') {
					buf.forward(4);
					return new Result(TYPE_OBJECT, null);
				} else if( buf.following(9) == 'undefined') {
					buf.forward(9);
					return new Result(TYPE_UNDEFINED);
				} else {
					throw new Error("unknown token " + ch);
				}
			}
		}	
	}

	class Result {
		static const TYPE_NUMBER:int = 1;
		static const TYPE_STRING:int = 2;
		static const TYPE_OBJECT:int = 3;
		static const TYPE_ARRAY:int = 4;
		static const TYPE_UNDEFINED:int = 5;
		static const TYPE_END:int = 6;
		var type:int;
		var value:Object;
		function Result(type:int, value:Object) {
			this.type = type;
			this.value = value;
		}
	}

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
			ch = str[pos++];
			while(spaceOk && ch == '\n' || ch == '\t' || ch == '\t') {
				ch = str[pos++];
			}
			return ch;
		}

		function forward(n:int):void {
			pos += n;
			ch = str[pos];
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