;;;;;;;;;;;;;;;;;;;;;
;;	DOF script suite by Arakis.
;;
;;
;;	>> Poet Palace - doors handler
;;	>>
;;	>> handle the door in the 1st or second floor.
;;	>> 
;;
;;
;;	;;Includes.
#include "${LavishScript.HomeDirectory}/Scripts/DOF_NavTool/dof_includes.iss"
;;;;;;;;;;;;;;;;;;;;;

function main(int floorN, int doorN)
{
	;call load_OgreNav_Into_Memory
	
	variable int minId
	variable int maxId
	minId[1]:Set[51920]
	maxId[1]:Set[51927]
	echo ${Actor[Query,Heading <= 181  ].ID}
	;call waitForDoor 1 East
	
	
;	wait 2
;	
;	if ${floorN}==1
;		call keepDoorOpen ${doorN}
;	elseif ${floorN}==2
;		call waitForDoor ${doorN}
;	else
;	{
;		OgreBotAPI:Message[${Me.Name}, "Unknown floor parameter:" ${floorN}, FALSE, default]
;		return FALSE
;	}
;	wait 2
}
;;;;;;;;;;;;;;;;;;;;;
;;	
;;		Script for keeping the doors opened on the 1st floor (statue puzzle)
;;	
;;	Map points
;;		door1KeepOpenSpot	11.54 185.97 9.49
;;		door2KeepOpenSpot	-39.19 186.01 -2.19
;;
;;	door 1:	Loc -> 7.216743,185.983765,7.813705
;;			Heading Closed  90.015633
;;			Heading Opened	0.015625
;;	door 2:	Loc -> -34.234344,185.983765,-7.231743
;;			Heading Closed	180.000000
;;			Heading Opened	90.015633
;;
function keepDoorOpen(int door)
{
	variable point3f selectedDoorLoc
	variable point3f doorCampSpot
	variable int selectedDoorID
	
	;;;;;;;;	
	;echo "id of the door 1 : " ${Actor[Query,Loc=- 7.216743, 185.983765, 7.813705].ID} " - Heading : " ${Actor[Query,Loc=- 7.216743, 185.983765, 7.813705].Heading} "
	;echo "id of the door 2 : " ${Actor[Query,Loc=- -34.234344,185.983765,-7.231743].ID} " - Heading : " ${Actor[Query,Loc=- -34.234344,185.983765,-7.231743].Heading} "
	;;;;;;;;
	
	;
	; NOTE : INFINITE LOOP TO BE MANUALLY ENDED SOMEWHOW. TBD
	;
	if ${door} == 1
	{
		selectedDoorLoc:Set[7.216743,185.983765,7.813705]
		selectedDoorID:Set[${Actor[Query,Loc=- ${selectedDoorLoc}].ID}]
		call OnFootZoneNav "door1KeepOpenSpot"
		
		while ${Math.Distance[${Actor[${Me.ID}].Loc},11.54,185.97,9.49]} < 2
		{ 
			while ${Actor[Query,ID=-${selectedDoorID}].Heading} < 1 
			{ 
				wait 2
			}
			
			Actor[ID,${selectedDoorID}]:DoubleClick
			wait 2
		}
	}
	elseif ${door} == 2
	{
		selectedDoorLoc:Set[34.234344,185.983765,-7.231743]
		selectedDoorID:Set[${Actor[Query,Loc=- ${selectedDoorLoc}].ID}]
		call OnFootZoneNav "door2KeepOpenSpot"
		
		while ${Math.Distance[${Actor[${Me.ID}].Loc},-39.19,186.01,-2.19]} < 2
		{
			while ${Actor[Query,ID=-${selectedDoorID}].Heading} < 100
			{ 
				wait 2
			}
			Actor[id,${selectedDoorID}]:DoubleClick
			wait 5
		}
	}	
}


;;;;;;;;;;;;;;;;;;;;;
;;	
;;		Script for monitoring the doors & going through as soon as one open.
;;	
;;	Note : East side = Entrance (where we get in from the mirror)
;;	
;;	Waiting spots
;;		WaitSpot_Set1_East	-145.15 227.05 -61.72
;;		WaitSpot_Set1_West 
;;
;;	door Set 1  (from left to right)
;;		Door1	-130.441895,228.749878,-20.692444
;;		Door2	-130.441772,228.749878,-31.478790
;;		Door3	-130.441772,228.749878,-42.265106
;;		Door4	-130.441772,228.749878,-53.051453
;;		Door5	-130.442017,228.749512,-74.510315
;;		Door6	-130.442017,228.749512,-85.296631
;;		Door7	-130.441895,228.749512,-96.082947
;;		Door8	-130.441772,228.749512,-106.869324
;;	
;;	Heading  Closed : 270.000000
;;			 Opened : 180.000000
;;
;;	Loc to aim : -140.00, 277.05, <door z coord>
;;	
;;;;;;
;;	door 2:	Loc -> -34.234344,185.983765,-7.231743
;;			Heading Closed	180.000000
;;			Heading Opened	90.015633
;;
function waitForDoor(int doorSet, string side)
{
	variable string WaitingSpot
	variable int minId
	variable int maxId
	variable float zTarget
	declare doorSet1IdArray[8] integer

	waitframe 
	;doorSet1IdArray[1]:Set[${Actor[Query,Loc=- -130.441895, 228.749878, -20.692444].ID}]
	;doorSet1IdArray[2]:Set[${Actor[Query,Loc=- -130.441772, 228.749878, -31.478790].ID}]
	;doorSet1IdArray[3]:Set[${Actor[Query,Loc=- -130.441772, 228.749878, -42.265106].ID}]
	;doorSet1IdArray[4]:Set[${Actor[Query,Loc=- -130.441772, 228.749878, -53.051453].ID}]
	;doorSet1IdArray[5]:Set[${Actor[Query,Loc=- -130.442017,228.749512,-74.510315].ID}]
	;doorSet1IdArray[6]:Set[${Actor[Query,Loc=- -130.442017,228.749512,-85.296631].ID}]
	;doorSet1IdArray[7]:Set[${Actor[Query,Loc=- -130.441895,228.749512,-96.082947].ID}]
	;doorSet1IdArray[8]:Set[${Actor[Query,Loc=- -130.441772,228.749512,-106.869324].ID}]
	
	doorSet1IdArray[1]:Set[${Actor[Query,Z=- -20.692444].ID}]
	minId[1]:Set[${Actor[Query,Z=- -20.692444].ID}]
	doorSet1IdArray[2]:Set[${Actor[Query,Z=- -31.478790].ID}]
	doorSet1IdArray[3]:Set[${Actor[Query,Z=- -42.265106].ID}]
	doorSet1IdArray[4]:Set[${Actor[Query,Z=- -53.051453].ID}]
	doorSet1IdArray[5]:Set[${Actor[Query,Z=- -74.510315].ID}]
	doorSet1IdArray[6]:Set[${Actor[Query,Z=- -85.296631].ID}]
	doorSet1IdArray[7]:Set[${Actor[Query,Z=- -96.082947].ID}]
	doorSet1IdArray[8]:Set[${Actor[Query,Z=- -106.869324].ID}]
	maxId[8]:Set[${Actor[Query,Z=- -106.869324].ID}]
	
	;Go to corresponding waiting spot
	WaitingSpot:Set[WaitSpot_Set${doorSet}_${side}]
	
	echo == ${WaitingSpot} ==
	echo >door 1 ${doorSet1IdArray[1]} 
	echo >door 2 ${doorSet1IdArray[2]}
	echo >door 3 ${doorSet1IdArray[3]} 
	echo >door 4 ${doorSet1IdArray[4]} 
	echo >door 5 ${doorSet1IdArray[5]}
	echo >door 6 ${doorSet1IdArray[6]}
	echo >door 7 ${doorSet1IdArray[7]}
	echo >door 8 ${doorSet1IdArray[8]}
	
	call OnFootZoneNav ${WaitingSpot}
	
	while ${Actor[Query,ID=- ${doorSet1IdArray[1]}].Heading} > 269 && ${Actor[Query,ID=- ${doorSet1IdArray[2]}].Heading} > 269 && ${Actor[Query,ID=- ${doorSet1IdArray[3]}].Heading} > 269 && ${Actor[Query,ID=- ${doorSet1IdArray[4]}].Heading} > 269 
	;&& ${Actor[Query,ID=- ${doorSet1IdArray[5]}].Heading} > 269 && ${Actor[Query,ID=- ${doorSet1IdArray[6]}].Heading} > 269 
	;&& ${Actor[Query,ID=- ${doorSet1IdArray[7]}].Heading} > 269 && ${Actor[Query,ID=- ${doorSet1IdArray[8]}].Heading} > 269
	{ 
		wait 2
		;echo all close
	}
	
	echo ==
	echo ${Actor[Query,Heading=- 180.000000].ID} OPEN
	
	zTarget:Set[${Actor[Query,Heading=- 180.000000 && ID >= ${minId} && ID <= ${maxId}].Z}]
	echo z : ${zTarget}
	
	OgreBotAPI:ChangeCampSpotWho[-140.00, 277.05, ${zTarget}]
	;while {Math.Distance[${Actor[${Me.ID}].Loc},"-140.00, 277.05, "${zTarget}]} > 2
	;	waitframe
	
	OgreBotAPI:ChangeCampSpotWho[-112.00,277.05, ${zTarget}]
}
