package gryffin.utils;

@:forward(
	iterator,
	push,
	pop,
	shift,
	unshift,
	insert,
	reverse,
	call
)
abstract CallStack <T> (ICallStack<T>) {
	public inline function new():Void {
		this = new ICallStack();
	}
	public inline function slice(start:Int, ?end:Int):CallStack<T> {
		return cast this.slice(start, end);
	}
	public inline function map<K>(modifier:(T->T)->(K->K)):CallStack<K> {
		return cast this.map(modifier);
	}
	@:arrayAccess
	public inline function get(pos:Int):Null<T -> T> {
		return this.get(pos);
	}
	@:arrayAccess
	public inline function set(pos:Int, what:Null<T -> T>):Null<T -> T> {
		this.set(pos, what);
		return what;
	}
	@:to 
	public inline function toICallStack():ICallStack<T> {
		return cast this;
	}
	@:to
	public inline function toFunction():T -> T {
		return this.call.bind(_);
	}

	@:from
	public static inline function fromICallStack<T>(ics:ICallStack<T>):CallStack<T> {
		return cast ics;
	}
	@:from 
	public static inline function fromArray<T>(list:Array<T->T>):CallStack<T> {
		return cast ICallStack.fromArray(list);
	}
}

class ICallStack <T> {
	private var stack:Array<T -> T>;

	public function new():Void {
		this.stack = new Array();
	}
	public function iterator():Iterator<T -> T> {
		return this.stack.iterator();
	}
	public function push(f:T -> T):Void {
		this.stack.push(f);
	}
	public function pop():Null<T -> T> {
		return this.stack.pop();
	}
	public function shift():Null<T->T> {
		return this.stack.shift();
	}
	public function unshift(f:T->T):Void {
		this.stack.unshift(f);
	}
	public function slice(start:Int, ?end:Int):ICallStack<T> {
		return ICallStack.fromArray(this.stack.slice(start, end));
	}
	public function insert(pos:Int, what:T -> T):Void {
		this.stack.insert(pos, what);
	}
	public function reverse():Void {
		this.stack.reverse();
	}
	public function map<K>(modifier:(T->T)->(K->K)):ICallStack<K> {
		return ICallStack.fromArray(this.stack.map(modifier));
	}
	public function get(pos:Int):Null<T -> T> {
		return this.stack[pos];
	}
	public function set(pos:Int, func:T -> T):Void {
		this.stack[pos] = func;
	}

	public function call(input:T):T {
		var inp:T = input;

		for (func in this) {
			inp = func(inp);
		}

		return inp;
	}


	public static function fromArray<T>(funcs:Array<T -> T>):ICallStack<T> {
		var stack:ICallStack<T> = new ICallStack();
		for (func in funcs) stack.push(func);
		return stack;
	}
}