package gryffin.loaders;

import gryffin.loaders.MapLoader;

class MapLoader {
	public static var tagClasses:Map<String, Registry>;
	public static function createInstance(tag:String):BaseClass {
	}
	public static function createEntity( temp:Xml ):Element {
		var tagName:String = temp.nodeName.toLowerCase();
		var el:Element = Dom.wrap(js.Browser.document.createElement( tagName ));
		for (name in temp.attributes()) {
			el.attr(name, temp.get(name));
		}
		var kids = temp.elements();
		var possibleContent:Xml = temp.firstChild();
		if (possibleContent.nodeType == Xml.PCData) {
			el.text(possibleContent.nodeValue);
		}
		if (kids != null) {
			for (kid in kids) {
				if (kid.nodeType == Xml.PCData) {
					el.text( kid.nodeValue );
				} else {
					el.el.appendChild(createElement(kid).el);
				}
			}
		}
		return el;
	}
	public static function parse( xmlCode:String ):Array<Element> {
		var ast = Xml.parse(xmlCode);
		var nodes:Array<Xml> = [for (x in ast.elements()) x];
		var elements:Array<Element> = [];
		if (nodes != null) {
			for (element in ast) {
				elements.push(createElement(element));
			}
		}
		return elements;
	}
	private static function  __init__():Void {
		tagClasses = new Map();
	}
}

private typedef BaseClass = Parent;
private typedef Registry = {
	klass:Class<BaseClass>,
	attribute:BaseClass->String->String->Void
};