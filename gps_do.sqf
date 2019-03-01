params ["_endPos"];

[_endPos] spawn {
    params ["_endPos"];

    while {!gps_core_init_done} do { sleep 1; };

    fn_mkr = {
        params ["_pos"];
        private _mrk = createMarker [str _pos, _pos];
        // define marker
        _mrk setMarkerShape "ICON";
        _mrk setMarkerType "hd_dot";
        _mrk setMarkerColor "ColorWhite";
    };

    {
        deleteMarker _x;
    } forEach allMapMarkers - danger_markers;

    private _normal = ["ColorBlue", { 
		params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
        _base_cost
    }];
    private _danger = ["ColorRed", { 
		params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
        private _danger_rating = 0;
        {
            private _rating_cost = 0 max (((markerSize _x) select 0) - ((markerPos _x) distance _next));
            _danger_rating = _danger_rating + _rating_cost * _rating_cost * _rating_cost;
        } forEach danger_markers;
        _base_cost + _danger_rating
    }];
    private _height = ["ColorGreen", { 
		params ["_base_cost", "_current", "_next", "_startRoute", "_goalRoute"];
        private _height = ((getPosASL _next) select 2);
        _base_cost + _height * _height * _height
    }];

    private _runs = [_normal, _danger, _height];
    
    private _startRoute = [getPosATL vehicle player, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
    private _endRoute = [_endPos, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;

    if (isNull _endRoute) exitWith {hintSilent "end invalid"};
    if (isNull _startRoute) exitWith {hintSilent "start invalid"};

    [_startRoute] call gps_core_fnc_insertFakeNode;
    [_endRoute] call gps_core_fnc_insertFakeNode;

    try {
        {
            _x params ["_color", "_weight_fn"];

            private _path = [_startRoute,_endRoute,_weight_fn] call gps_core_fnc_generateNodePath;
            private _fullPath = [_path] call gps_core_fnc_generatePathHelpers;

            private _last_junction = 0;
            for "_i" from 0 to count _fullPath - 1 do {
                private _current = _fullPath select _i;
                if(count ([gps_allCrossRoadsWithWeight, str _current] call misc_fnc_hashTable_find) > 1) then
                {
                    [getPos (_fullPath select floor((_i + _last_junction)/2))] call fn_mkr;
                    _last_junction = _i;
                };
            };

            private _path_pos = _fullPath apply { getPos _x };

            private _seg_positions = [_path_pos, 20] call gps_core_fnc_RDP;

            for "_i" from 0 to (count _seg_positions - 2) do
            {
                private _size = if((_i == 0) or (_i == count _seg_positions - 2)) then { 10 } else { 20 };
                [
                    ["start", (_seg_positions select _i)],
                    ["end", (_seg_positions select (_i + 1))],
                    ["color", _color],
                    ["size", _size]
                ] call fnc_mapDrawLine; 
            };
        } forEach _runs;
    } catch {
        hint "No path";
        diag_log str _exception;
    };
};