package gryffin.gss;

import gryffin.Stage;
import gryffin.Entity;
import gryffin.gss.Node;
import gryffin.Utils;

import openfl.Assets;

import gryffin.gscript.Parser;
import gryffin.gscript.Interp;

class Compiler {
	public var ast:Array<Node>;
	public var ruleSetters:Array<RuleSetter>;
	public var context:Dynamic;

	public function new() {
		this.ast = [];
		this.ruleSetters = [];
		this.context = {};
	}
	public function preprocessExpression(expr:String):String {
		var result:String = (expr + "");

		result = StringTools.replace(result, '@', 'this.');
		result = StringTools.replace(result, '$', 'context.');

		return result;
	}
	public function initInterp(interp:Interp):Void {
		interp.variables.set('int', Std.int.bind(_));
		interp.variables.set('round', Math.round.bind(_));

		interp.variables.set('url', Utils.memoize(function(path:String):Dynamic {
			return Assets.getBitmapData(path);
		}));
	}
	public function compileValue( value:Value ):ValueResolver {
		switch (value) {
			case Value.VString(str):
				return function (ent) {
					return str;
				};
			case Value.VNumber(num):
				return function (ent) {
					return num;
				};
			case Value.VPropRef(ref):
				return function(ent) {
					return Reflect.getProperty(ent, ref);
				};
			case Value.VExpr(expr):
				var program = (new Parser()).parseString(preprocessExpression(expr));
				var interp = new Interp();
				interp.variables.set('context', this.context);
				initInterp(interp);
				return function(ent:Entity) {
					interp.variables.set('this', ent);
					interp.variables.set('stage', ent.stage);
					return interp.execute(program);
				};
		}
	}
	public function compileRule(name:String, value:Value):RuleSetter {
		var val:ValueResolver = compileValue(value);
		return function (ent) {
			Reflect.setProperty(ent, name, val(ent));
		};
	}
	public function compileRuleSet(rules:Node):RuleSetter {
		var rulesetters:Array<RuleSetter> = new Array();
		switch (rules) {
			case Node.NRuleSet(set):
				for (rule in set) {
					switch (rule) {
						case Node.NRule(name, value):
							rulesetters.push(compileRule(name, value));
						default:
							throw 'Invalid rule $rule';
					}
				}
			default:
				throw 'Invalid rule-set $rules';
		}
		return function (ent) {
			for (setter in rulesetters) {
				setter(ent);
			}
		};
	}
	public function compileBlock(block:Node):StyleSheetRunner {
		switch (block) {
			case Node.NBlock(selector, rules):
				var setter:RuleSetter = compileRuleSet(rules);
				return function (stage:Stage) {
					var sel = stage.get(selector);
					sel.each(function(ent, i) {
						context.i = i;
						setter(ent);
					});
				};
			default:
				throw 'Invalid block $block';
		}
	}
	public function compile(ast:Array<Node>):StyleSheetRunner {
		this.ast = ast;
		this.ruleSetters = [];
		var runners:Array<StyleSheetRunner> = new Array();
		for (node in ast) {
			switch (node) {
				case Node.NBlock(sel, rules):
					runners.push(compileBlock(node));

				default:
					throw 'Invalid $node';
			}
		}

		return function(stage:Stage):Void {
			for (runner in runners) {
				runner(stage);
			}
		};
	}
}

private typedef ValueResolver = Entity->Dynamic;
private typedef RuleSetter = Entity->Void;
private typedef StyleSheetRunner = Stage->Void;