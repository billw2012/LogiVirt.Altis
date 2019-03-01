
// How to generate road map:

// roads = get all roads

// // Segment is [next, previous, pos, length, roads]
// segments = set<Segment>
// roadsToSegments = map<road, Segment>

// while roads not empty:
//     road = road[0]
//     if not roadsToSegments.contains(id(road)):
//         seg_roads = [road]
//         ends = roadsConnectedTo road
//         if 0 < count ends < 3:
//             start = [ends[0]]
//             while count start == 1:
//                 seg_roads = start + seg_roads
//                 start = (roadsConnectedTo start[0] - seg_roads)[0]
//             if count ends > 1:
//                 end = [ends[1]]
//                 while count end == 1:
//                     seg_roads = seg_roads + end
//                     end = (roadsConnectedTo end[0] - seg_roads)[0]

//         start_seg = roadsToSegments.get(id(start[0])):
//         end_seg = if (count end > 0) then roadsToSegments.get(id(end[0])) else nil;
//         segments.add([start_seg, end_seg, pos start[0], len, seg_roads])
//         roads = roads - seg_roads

fnc_mapDrawLine = compile preprocessFileLineNumbers "mapDrawLine.sqf";
// fnc_pointLineDist = compile preprocessFileLineNumbers "pointLineDist.sqf";
// fnc_RDP = compile preprocessFileLineNumbers "RDP.sqf";
// fnc_calcRoadSegments = {
//     [] call compile preprocessFileLineNumbers "calcRoadSegments.sqf";
// };

[] execVM "gps_core\init.sqf";

fnc_gps_do = {
    // compile preprocessFileLineNumbers
    [] execVM "gps_do.sqf";
};
