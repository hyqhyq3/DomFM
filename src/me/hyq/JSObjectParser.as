package me.hyq {
	public class JSObjectParser {
		public var obj:Object;
		public function JSObjectParser() {

		}

		public function parse(str:String):void {
			var objStr:String = str.substring(str.indexOf('(') + 1, str.lastIndexOf(')'));
			obj = read(new Buffer(objStr)).value;
			objStr;
		}

		public function readIdent(buf:Buffer):String {
			if(buf.current() == '}') {
				return '';
			}
			var ch:String = buf.next();
			var str:String = ch;
			var reg:RegExp;
			if(! ch.match(/[a-zA-Z_$]/)) {
				throw new Error("expected identify but got " + ch);
			}
			for(;;){
				ch = buf.next();
				if(! ch.match( /[a-zA-Z0-9_$]/ )) {
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
					return new Result(Result.TYPE_END,null);
				}
				if(ch == '[') {
					//array
					var arr:Array = [];
					for(;;) {
						var item:Result = read(buf);
						if(item.type == Result.TYPE_END) {
							break;
						}
						arr.push(item.value);
						buf.next();
						if(buf.current() == ']') {
							break;
						}
					}
					return new Result(Result.TYPE_ARRAY, arr);
				} else if (ch == '{') {
					//object
					var obj:Object = {};
					for (;;){
						var ident:String = readIdent(buf);
						var ret:Result = read(buf); 
						obj[ident] = ret.value;
						buf.next();
						if(buf.current() == '}') {
							break;
						}
					}
					return new Result(Result.TYPE_OBJECT, obj);
				} else if (ch == '"' || ch == "'") {
					//string
					var iteral:String = ch;
					var str:String = "";
					var c:String = "";
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
					return new Result(Result.TYPE_OBJECT, null);
				} else if( buf.following(9) == 'undefined') {
					buf.forward(9);
					return new Result(Result.TYPE_UNDEFINED, undefined);
				} else {
					throw new Error("unknown token " + ch);
				}
			}
			return null;
		}	
	}



}