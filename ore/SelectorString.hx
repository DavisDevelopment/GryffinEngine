package gryffin.ore;

import gryffin.Stage;
import gryffin.Selection;
import gryffin.Entity;

abstract SelectorString(String) {
	public inline function new(s : String) {
		this = s;
	}
}