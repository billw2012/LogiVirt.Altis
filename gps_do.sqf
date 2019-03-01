
[] spawn {
    while {!gps_core_init_done} do { sleep 1; };

    fn_mkr = {
        params ["_pos"];
        private _mrk = createMarker [str _pos, _pos];
        // define marker
        _mrk setMarkerShape "ICON";
        _mrk setMarkerType "hd_flag";
        _mrk setMarkerColor "ColorWhite";
    };

    {
        deleteMarker _x;
    } forEach allMapMarkers;

    danger_markers = [];
    for "_i" from 0 to 5 + random(10) do {
        private _pos = [] call BIS_fnc_randomPos;
        private _mrk = createMarker [str _pos, _pos];
        _mrk setMarkerShape "ELLIPSE";
        _mrk setMarkerBrush "Vertical";
        _mrk setMarkerColor "ColorRed";
        private _size = 1000 + random(1500);
        _mrk setMarkerSize [_size, _size];
        danger_markers pushBack _mrk;
    };

    private _normal = ["ColorBlue", { 
        params ["_next", "_startRoute", "_goalRoute", "_cost_so_far"];
        _goalRoute distance _next
    }];
    private _danger = ["ColorRed", { 
        params ["_next", "_startRoute", "_goalRoute", "_cost_so_far"];
        private _danger_rating = 0;
        {
            private _rating_cost = 0 max (((markerSize _x) select 0) - ((markerPos _x) distance _next));
            _danger_rating = _danger_rating + _rating_cost * _rating_cost * _rating_cost;
        } forEach danger_markers;
        (_goalRoute distance _next) + _danger_rating
    }];
    private _height = ["ColorGreen", { 
        params ["_next", "_startRoute", "_goalRoute", "_cost_so_far"];
        private _height = 100 * ((getPosASL _next) select 2);
        (_goalRoute distance _next) + _height
    }];

    //private _runs = [_normal, _danger, _height];
    private _runs = [_height];
    // private _startPos = [] call BIS_fnc_randomPos;
    // [_startPos] call fn_mkr;

    //[_endPos] call fn_mkr;

    private _startRoute = [getPosATL vehicle player, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
    private _endPos = [] call BIS_fnc_randomPos;
    private _endRoute = [_endPos, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
    //[getPos _startRoute] call fn_mkr;

    //[getPos _endRoute] call fn_mkr;

    // [] call gps_fnc_deletePathHelpers;
    
    //[_startRoute] call gps_core_fnc_insertFakeNode;
    if (isNull _endRoute) exitWith {hintSilent "end invalid"};
    if (isNull _startRoute) exitWith {hintSilent "start invalid"};

    [_startRoute] call gps_core_fnc_insertFakeNode;
    [_endRoute] call gps_core_fnc_insertFakeNode;

    try {
        //while { (getPosATL vehicle player) distance _endPos > 200 } do {
            //_startRoute = [getPosATL vehicle player, 1000, gps_blacklistRoads] call bis_fnc_nearestRoad;
            
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

            // {
            //     deleteMarker _x;
            // } forEach allMapMarkers - danger_markers;

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

        //    sleep 10;
        //};
        // {
        //     deleteMarker _x;
        // } forEach allMapMarkers;
    } catch {
        hint "No path";
        // switch _exception do { 
        //     case "PATH_NOT_FOUND" : {
        //         // [] call gps_fnc_deletePathHelpers;
        //         // [] call gps_menu_fnc_closeHud;
        //         hint "No path";
        //     }; 
        // };
        //[_exception] call gps_fnc_log;
        diag_log str _exception;
    };
};