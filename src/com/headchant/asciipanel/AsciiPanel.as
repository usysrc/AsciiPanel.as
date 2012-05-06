package com.headchant.asciipanel {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	/**
	 * @author Tilmann Hars
	 * heavly inspired by the java AsciiPanel by trystan: trystans.blogspot.com
	 */
	
	public class AsciiPanel extends Sprite {
		[Embed(source="cp437.png", mimeType="image/png")]
		private var fontImage:Class;
		
		private var glyphs : Array;
		private var fontBitmapData : BitmapData;
		private var widthInCharacters : int;
		private var heightInCharacters : int;
		private var screen : BitmapData;
		private var chars : Array;
		private var fontBitmap : Bitmap;
		private var charHeight : int;
		private var charWidth : int;
		private var screenBitmap : Bitmap;
		private var foregroundColor : Array;
		private var backgroundColor : Array;
		private var defaultForegroundColor : uint = AsciiPanel.DARKWHITE;
		private var defaultBackgroundColor : uint = AsciiPanel.BLACK;
		
		public static var WHITE : uint = rgbaColor(255,255,255);
		public static var BLACK : uint = rgbaColor(0,0,0);
		public static var RED : uint = rgbaColor(255,0,0);
		public static var BLUE : uint = rgbaColor(0,0,255);		
		public static var GREEN : uint = rgbaColor(0,255,0);
		public static var YELLOW : uint = rgbaColor(128, 128, 0);
		public static var GREY : uint = rgbaColor(128, 128, 128);
		public static var DARKWHITE : uint = rgbaColor(192, 192, 192);
		
		// more exotic colors
		public static var DODGERBLUE : uint = rgbaColor(30, 144, 255);
		private var oldchars : Array;
		private var oldbackgroundColor : Array;
		private var oldforegroundColor : Array;
		
		public function getWidthInCharacters() : int { return widthInCharacters; }
		public function getHeightInCharacters() : int { return heightInCharacters; }
		
		public function AsciiPanel(widthInCharacters:int = 80, heightInCharacters:int = 24){
			fontBitmap = new fontImage() as Bitmap;
			fontBitmapData = fontBitmap.bitmapData;
			//addChild(fontBitmap);
			
			charWidth = 9;
			charHeight = 16;
			
			glyphs = new Array();
			for (var i : int = 0; i < 256; i++) {
				var sx:int = (i % 32) * charWidth + 8;
				var sy:int = int(i / 32) * charHeight + 8;
				glyphs[i] = new BitmapData(charWidth, charHeight);
				(glyphs[i] as BitmapData).copyPixels(fontBitmapData, new Rectangle(sx,sy,charWidth, charHeight), new Point(0,0));
				
			}

			this.widthInCharacters = widthInCharacters;
			this.heightInCharacters = heightInCharacters;

			width = charWidth*widthInCharacters;
			height = charHeight*heightInCharacters;

			screen = new BitmapData(charWidth*widthInCharacters+10, charHeight*heightInCharacters+10,false,0x000000);
			chars = new Array();
			oldchars = new Array();
			foregroundColor = new Array();
			backgroundColor = new Array();
			oldforegroundColor = new Array();
			oldbackgroundColor = new Array();
			
			for ( i = 0; i < widthInCharacters; i++) {
				chars[i] = [];
				oldchars[i] = [];
				foregroundColor[i] = [];
				backgroundColor[i] = [];
				oldforegroundColor[i] = [];
				oldbackgroundColor[i] = [];
				for (var j : int = 0; j < heightInCharacters; j++) {
					chars[i][j] = 0;
					oldchars[i][j] = -1;
					foregroundColor[i][j] = defaultForegroundColor;
					backgroundColor[i][j] = defaultBackgroundColor;
					oldforegroundColor[i][j] = defaultForegroundColor;
					oldbackgroundColor[i][j] = defaultBackgroundColor;
					
					var bitmapdata : BitmapData = (glyphs[chars[i][j]] as BitmapData);
					bitmapdata.threshold(bitmapdata, bitmapdata.rect, new Point(0,0), ">", 0xFF000000, foregroundColor[i][j]);
					bitmapdata.threshold(bitmapdata, bitmapdata.rect, new Point(0,0), "==", 0xFF000000, backgroundColor[i][j]);
					
					screen.copyPixels(bitmapdata, new Rectangle(0,0,charWidth,charHeight), new Point(i*charWidth, j*charHeight));
					
				}
			}
			
			screenBitmap = new Bitmap(screen);
			screenBitmap.smoothing = false;
			addChild(screenBitmap);
			scaleX = 1;
			scaleY = 1;
		}
		
		public function paint():void{
			for (var i:int = 0; i < widthInCharacters; i++) {
				for (var j : int = 0; j < heightInCharacters; j++) {
					if (chars[i][j] == oldchars[i][j] 
						&& foregroundColor[i][j] == oldforegroundColor[i][j]
						&& backgroundColor[i][j] == oldbackgroundColor[i][j])
						continue;
					if (chars[i][j] == null)
						continue;
						
					var bitmapdata : BitmapData = (glyphs[chars[i][j]] as BitmapData);
					var dest:Point = new Point(i * charWidth, j * charHeight);
					var rect:Rectangle = new Rectangle(dest.x, dest.y, charWidth, charHeight);
					
					screen.copyPixels(bitmapdata, new Rectangle(0,0,charWidth,charHeight), dest);
					screen.threshold(screen, rect, dest, ">", 0xFF000000, foregroundColor[i][j]);
					screen.threshold(screen, rect, dest, "==", 0xFF000000, backgroundColor[i][j]);
				}
			}
			oldchars = copy(chars);
			oldbackgroundColor = copy(backgroundColor);
			oldforegroundColor = copy(foregroundColor);
		}
		
		private function copy(itemToCopy:Array):Array{
		    var newArray:Array = new Array();
		    for(var i:int = 0; i < (itemToCopy as Array).length; i++)
		        newArray[i] = (itemToCopy[i] as Array).slice();
		    return newArray;
		}
		
		public static function rgbaColor(r:int, g:int, b:int, a:int = 255):uint{
			return (a << 24) | (r << 16) | (g << 8) | b;
		}
		
		public function write(string:String, x:int, y:int, fgcolor:uint = 0xFFC0C0C0, bgcolor:uint = 0xFF000000):void {
			if (string == null)
				throw Error("string must not be null");
				
			for (var i : int = 0; i < string.length; i++) {
				foregroundColor[x+i][y] = fgcolor;
				backgroundColor[x+i][y] = bgcolor;	
				chars[x+i][y] = string.charCodeAt(i);
			}
		}
		
		public function writeCenter(string:String, y:int, fgcolor:uint = 0xFFC0C0C0, bgcolor:uint = 0xFF000000):void{
			var x:int = (widthInCharacters - string.length) / 2;
			write(string, x, y);
		}
		
		public function clear(char:String = " ", fgcolor:uint = 0xFFC0C0C0, bgcolor:uint = 0xFF000000):void{
			for (var i:int = 0; i < widthInCharacters; i++) {
				for (var j : int = 0; j < heightInCharacters; j++) {
					chars[i][j] = char.charCodeAt(0);
					foregroundColor[i][j] = fgcolor;
					backgroundColor[i][j] = bgcolor;	
				}
			}
		}
		
	}
}