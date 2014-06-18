package gryffin.geom;

class Matrix {
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	
	public function new(?a:Float, ?b:Float, ?c:Float, ?d:Float, ?tx:Float, ?ty:Float) {
		this.a = a == null ? 1 : a;
		this.b = b == null ? 0 : b;
		this.c = c == null ? 0 : c;
		this.d = d == null ? 1 : d;
		this.tx = tx == null ? 0 : tx;
		this.ty = ty == null ? 0 : ty;
	}
	public inline function clone():Matrix {
		return new Matrix( this.a, this.b, this.c, this.d, this.tx, this.ty );
	}
	/** Resets matrix state */
	public function identity():Void {
		this.a = this.d = 1;
		this.b = this.c = this.tx = this.ty = 0;
	}
	/** Returns whether matrix is in identity state */
	public function isIdentity():Bool {
		return (this.a == 1 && this.d == 1 && this.tx == 0 && this.ty == 0 && this.b == 0 && this.c == 0);
	}
	public function copy( s:Matrix ):Void {
		this.a = s.a;
		this.b = s.b;
		this.c = s.c;
		this.d = s.d;
		this.tx = s.tx;
		this.ty = s.ty;
	}
	public function invert() {
		var t, n = a * d - b * c;
		if (n == 0) {
			a = b = c = d = 0;
			tx = -tx;
			ty = -ty;
		} else {
			n = 1 / n;
			//
			t = d * n;
			d = a * n;
			a = t;
			//
			b *= -n;
			c *= -n;
			//
			t = -a * tx - c * ty;
			ty = -b * tx - d * ty;
			tx = t;
		}
	}
	public function translate( x:Float, y:Float ):Void {
		this.tx += x;
		this.ty += y;
	}
	public function rotate( o:Float ):Void {
		var ox = Math.cos(o), oy = Math.sin(o), t;
		//
		t = a * ox - b * oy;
		b = a * oy + b * ox;
		a = t;
		//
		t = c * ox - d * oy;
		d = c * oy + d * ox;
		c = t;
		//
		t = tx * ox - ty * oy;
		ty = tx * oy + ty * ox;
		tx = t;
	}
	public inline function toString() {
		return 'matrix('
		+ a + ', ' + b + ', '
		+ c + ', ' + d + ', '
		+ tx + ', ' + ty + ')';
	}
}