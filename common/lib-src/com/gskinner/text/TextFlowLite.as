/**
* TextFlowLite by Grant Skinner. Sep 9, 2007
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
*
* Copyright (c) 2007 Grant Skinner
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package com.gskinner.text {
	import flash.display.BitmapData;
	import flash.text.TextField;

	public class TextFlowLite {
		protected var flds:Array;
		protected var _text:String;
		
		/**
		 * Returns something like [ '<a href="#foo">', '<span>', '<em>' ] or null
		 * The tags are put in the result in the order they were open
		 */
		public static function getUnclosedTags(htmlText:String, searchTag:Array = null):* {
			var tag:Array, result:*;
			var regexp:RegExp = /<(\w+)[^>]*>/;
			if (searchTag != null) regexp = new RegExp("<(\\w+)[^>]*>|</"+searchTag[1]+">");
			
			while (tag = htmlText.match(regexp)) {
				htmlText = htmlText.substr(htmlText.search(tag[0]) + tag[0].length);
				if (searchTag != null && tag[0].match(/^<\//)) {
					return htmlText;
				}; 
				result = getUnclosedTags(htmlText, tag);
				if (result is String) htmlText = result;
				else if (result is Array) {
					if (searchTag) return [ searchTag[0] ].concat(result);
					else return result;
				}
			}
			if (searchTag) return [ searchTag[0] ];
			else return null;
		}
		
		private static var BROKEN_OPENING_TAG_0:RegExp = /<([^\/][^>]*(>\s*)?|)\Z/;
		private static var BROKEN_CLOSING_TAG_0:RegExp = /<\/[^>]*\Z/;
		private static var BROKEN_CLOSING_TAG_1:RegExp = /\A(\s*<)?[^<>]*>/;
		
		public static function splitHtmlText(htmlText:String, offset:Number):Array {
			// Checking for content forced split
			var forcedSplit:Number = htmlText.indexOf('<!--COLUMN/-->');
			if (forcedSplit > 0 && forcedSplit < offset) {
				offset = forcedSplit;
				htmlText = htmlText.replace('<!--COLUMN/-->', '');
			}

			// Calculate adujstedOffet by removing tags
			var adjustedOffset:int = offset;
			var ite:int = 0;
			while (htmlText.substr(0, adjustedOffset).replace(/<[^>]+>/g, '').replace(/&[^;]+;/, '•').length < offset) {
				for each (var a:String in htmlText.substr(0, adjustedOffset).match(/<[^>]+>/g)) adjustedOffset += a.length;
				
				if (++ite > 100) throw new Error('TOO MANY ITERATIONS');
			}
			adjustedOffset -= htmlText.substr(0, adjustedOffset).replace(/<[^>]+>/g, '').replace(/&[^;]+;/, '•').length - offset;
			
			// Raw split
			var splitText:Array = [ htmlText.substr(0, adjustedOffset), htmlText.substr(adjustedOffset) ];
			
			// Check for mid-word split
			if (splitText[0].match(/[\wîâășțÎÂĂȘȚ[:punct:]]\Z/)) {
				if (splitText[1].match(/\A[[:punct:]]/)) { // matches '…abc'+'! …'
					splitText[0] = splitText[0] + splitText[1].match(/\A[[:punct:]]+/)[0];
					splitText[1] = splitText[1].replace(/\A[[:punct:]]+/, '');
				} else if (splitText[0].match(/[\wîâășțÎÂĂȘȚ]\Z/) && splitText[1].match(/\A[\wîâășțÎÂĂȘȚ]/)) { // matches '…ab'+'cd…'
					splitText[1] = splitText[0].match(/[\wîâășțÎÂĂȘȚ]+\Z/)[0] + splitText[1];
					splitText[0] = splitText[0].replace(/[\wîâășțÎÂĂȘȚ]+\Z/, '');
				}
			}
			
			// Check for mid-tag split and adjust
			var match:Array = splitText[0].match(BROKEN_OPENING_TAG_0); // matches '…<x'+'yz …>…' but not '…</x'+'y…'
			if (match) {
				splitText[1] = match[0] + splitText[1];
				splitText[0] = splitText[0].replace(BROKEN_OPENING_TAG_0, '');
			} else 
			if (splitText[0].match(BROKEN_CLOSING_TAG_0) || splitText[1].match(BROKEN_CLOSING_TAG_1)) { // matches '…</x'+'yz>…'
				splitText[0] = splitText[0] + splitText[1].match(BROKEN_CLOSING_TAG_1)[0];
				splitText[1] = splitText[1].replace(BROKEN_CLOSING_TAG_1, '');
			}
			
			// Close tags
			var closingTags:Array = getUnclosedTags(splitText[0]);
			if (closingTags != null) {
				for each (var tag:String in closingTags.reverse()) {
					splitText[0] = splitText[0] + '</' + tag.match(/^<(\w+)/)[1] + '>';
					splitText[1] = tag + splitText[1];
				}
			}
			
			return splitText;
		}
		
		public function TextFlowLite(textFields:Array, text:String=null) {
			flds = textFields;
			_text = text == null ? flds[0].htmlText : text;
			reflow();
		}
		
		public function addTextField(textField:TextField):void {
			flds.push(textField);
			reflow();
		}
		
		public function addTextFields(textFields:Array):void {
			for each (var textField:TextField in textFields) {
				flds.push(textField);
			}
			reflow();
		}
		
		public function get text():String {
			return _text;
		}
		public function set text(value:String):void {
			_text = value;
			reflow();
		}
		
		public function reflow():void {
			flds[0].htmlText = _text;
			(new BitmapData(100, 100)).draw(flds[0], null); // forcing a draw of the textfield so that internal values like scroll are 
			for (var i:int = 0; i < flds.length-1; i++) {
				flowField(flds[i],flds[i+1]);
			}
		}
		
		protected function flowField(fld1:TextField,fld2:TextField):void {
			fld1.scrollV = 1;
			fld2.htmlText = "";
			if (fld1.maxScrollV <= 1) { return; }
			var nextCharIndex:Number = fld1.getLineOffset(fld1.bottomScrollV);
			var htmlText:Array = splitHtmlText(fld1.htmlText, nextCharIndex);
			fld1.htmlText = htmlText[0];
			fld2.htmlText = htmlText[1].replace(/\A\s+/, '');
			(new BitmapData(100, 100)).draw(fld2, null); // forcing a draw of the textfield so that internal values like scroll are update
		}
		
		
	}
}