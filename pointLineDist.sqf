/*
	@Author : https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
	@Created : --
	@Modified : --
	@Description : --
	@Return : SCALAR
*/

params ["_point", "_start", "_end"];

private _n = _end vectorDiff _start;
private _n_dot_n = (_n vectorDotProduct _n);
if(_n_dot_n <= 0.0001) exitWith {0};

private _pa = _start vectorDiff _point;
private _c = _n vectorMultiply ((_pa vectorDotProduct _n) / _n_dot_n);
private _d = _pa vectorDiff _c;

sqrt (_d vectorDotProduct _d);