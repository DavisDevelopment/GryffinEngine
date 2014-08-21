package gryffin.loaders;

import gryffin.loaders.MapParser;
import gryffin.loaders.MapElement;

class MapParser {
	public static function createEntity( temp:Xml ):MapElement {
		var tagName:String = temp.nodeName.toLowerCase();
		var el:MapElement = {
			'name' : tagName,
			'textContent' : "",
			'attributes' : new Map<String, String>(),
			'childNodes' : new Array()
		};
		for (name in temp.attributes()) {
			el.attributes.set(name, temp.get(name));
		}
		var kids = temp.elements();
		var possibleContent:Xml = temp.firstChild();
		if (possibleContent.nodeType == Xml.PCData) {
			el.textContent = (possibleContent.nodeValue);
		}
		if (kids != null) {
			for (kid in kids) {
				if (kid.nodeType == Xml.PCData) {
					el.textContent = (kid.nodeValue);
				} else {
					el.childNodes.push(createEntity(kid));
				}
			}
		}
		return el;
	}
	public static function parse( xmlCode:String ):Array<MapElement> {
		var ast = Xml.parse(xmlCode);
		var nodes:Array<Xml> = [for (x in ast.elements()) x];
		var elements:Array<MapElement> = [];
		if (nodes != null) {
			for (element in ast) {
				elements.push(createEntity(element));
			}
		}
		return elements;
	}
}