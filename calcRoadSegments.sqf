
[] spawn {
    private _roads = [worldSize / 2,worldSize / 2,0] nearRoads worldSize;

    //// Segment is [next, previous, pos, length, roads]
    // segments = set<Segment>
    // roadsToSegments = map<road, Segment>

    private _colors = [
        "Default", 
        "ColorBlack", 
        "ColorGrey", 
        "ColorRed", 
        "ColorBrown", 
        "ColorOrange", 
        "ColorYellow", 
        "ColorKhaki", 
        "ColorGreen", 
        "ColorBlue", 
        "ColorPink", 
        "ColorWhite"
        // [1, 0, 0, 1],
        // [1, 1, 0, 1],
        // [1, 1, 1, 1],
        // [0, 1, 0, 1],
        // [0, 1, 1, 1],
        // [0, 0, 1, 1],
        // [1, 0, 1, 1],
        // [0.5, 0, 0, 1],
        // [0.5, 0.5, 0, 1],
        // [0.5, 0.5, 0.5, 1],
        // [0, 0.5, 0, 1],
        // [0, 0.5, 0.5, 1],
        // [0, 0, 0.5, 1],
        // [0.5, 0, 0.5, 1]
    ];

    {
        deleteMarker _x;
    } forEach allMapMarkers;

    private _color_index = 0;
    while { count _roads > 0 } do {
        private _road = _roads select 0;
        // if not roadsToSegments.contains(id(road)):
        if true then {
            private _seg_roads = [_road];
            private _ends = roadsConnectedTo _road;
            if (count _ends >= 1 and count _ends <= 2) then {
                private _start = [];
                private _finish = [];
                _start = [_ends select 0];
                _finish = _start;
                while {count _start == 1} do {
                    _seg_roads = _start + _seg_roads;
                    _start = (roadsConnectedTo (_start select 0) - _seg_roads);
                };
                if (count _ends == 2) then {
                    _finish = [_ends select 1];
                    while {count _finish == 1} do {
                        _seg_roads = _seg_roads + _finish;
                        _finish = (roadsConnectedTo (_finish select 0) - _seg_roads);
                    };
                };
            };

            if(count _seg_roads > 1) then {
                private _color = _colors select _color_index;
                _color_index = _color_index + 1;
                if (_color_index == count _colors) then {
                    _color_index = 0;
                };

                private _seg_positions = [_seg_roads apply { getPos _x }, 10] call fnc_RDP;

                for "_i" from 0 to (count _seg_positions - 2) do
                {
                    private _size = if((_i == 0) or (_i == count _seg_positions - 2)) then { 5 } else { 10 };
                    [
                        ["start", (_seg_positions select _i)],
                        ["end", (_seg_positions select (_i + 1))],
                        ["color", _color],
                        ["size", _size]
                    ] call fnc_mapDrawLine; 
                };
            };
            _roads = _roads - _seg_roads;
        };
    };
};