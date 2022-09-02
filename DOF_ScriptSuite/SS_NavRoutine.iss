;;;;;;;;;;;;;;;;;;;;;
;;	Map points
;;		carpet locs : CarpetX (point to take the carpet from)/ LandingX (point where the carpet lands)
;;			CarpetDocks
;;			CarpetDSas
;;			
;;			LandingTwinTears	-437.17,-76.67,-982.49
;;			LandingSilentCity	-949.62,-228.76,-1059.38
;;			LandingPofCamp		-5.34,-93.12,-925.80
;;			LandingUndercity	-203.20,-111.21,-279.77
;;			LandingOnerockIsle	-2015.96,-232.92,602.11
;;			
;;			
;;		Zoning points : ZoningX
;;			ZoningSanctorium
;;			ZoningSilentCity
;;			ZoningLivingTombs 
;;			ZoningClefts
;;			ZoningHiddenCache
;;			
;;		NPC : NPCx
;;			NPCgoaa			NPC to hail for goaa access
;;
;;
;;		Others
;;			PofPressForwardPoint		From camp D'Sas, point to go then autorun to get into POF
;;			DruidRing
;;			DockRallyPoint				
;;			-858.05,-123.13,-299.37		jumping point (dock => undercity) to start running to clefts / cache
;;
;;;;;;;;;;;;;;;;;;;;;

function main(string SSnavRoutine)
{
	call load_OgreNav_Into_Memory
	call Load_OgreUtilities
	
	; If starting point is DruidRing, move to dock, then restart as if dock was the starting point
	if ${SSnavRoutine.Find["FromDruidRing"]}>0
	{
		OgreBotAPI:Message[${Me.Name}, >>>Starting at DR; Moving to dock first , FALSE, default]
		call DockFromDruidRing
		
		wait 5
		SSnavRoutine:Set[${String[${SSnavRoutine}].ReplaceSubstring[FromDruidRing,FromDock]}]
	}
	
	call ${SSnavRoutine}

	OgreBotAPI:Message[${Me.Name}, Arrived at destination <<<<<<<<, TRUE, default]
	OgreBotAPI:Message[${Me.Name}, ==================================, FALSE, default]
}

;;;;;;;;;;;;;;;;;;;;;
;;	
;;	Complete navigation routines
;;
;;;;;;;;;;;;;;;;;;;;;
function SanctoriumFromDock()
{
	call TwinTearsFromDock
	wait 5
	call SanctoriumFromTwinTears
}

function LivingTombsFromDock()
{
	call TwinTearsFromDock
	wait 5
	call LivingTombsFromTwinTears
}

function PillarOfFlamesFromDock()
{
	call PofCampFromDock
	wait 5
	call OnFootZoneNav "PofPressForwardPoint" 
	wait 5
	OgreBotAPI:AutoRun	
}

function CleftsFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to undercity
	OgreBotAPI:Travel["all","Undercity Arena",TRUE]
	
	;// intercept jumping point
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]} >50
	{	
		;echo " traveling to cleft, jump point distance : "${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]}
		wait 5
	}
	OgreBotAPI:Jump
	wait 20
	
	call OnFootZoneNav "ZoningClefts" 
	wait 5
	
	call ZoneRoostCleftsDoor "cleft"
}

function RoostFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to undercity
	OgreBotAPI:Travel["all","Undercity Arena",TRUE]
	
	;// intercept jumping point
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]} >50
	{	
		;echo " traveling to cleft, jump point distance : "${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]}
		wait 5
	}
	OgreBotAPI:Jump
	wait 20
	
	call OnFootZoneNav "ZoningClefts" 
	wait 5
	
	call ZoneRoostCleftsDoor "roost"
}

function HiddenCacheFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to undercity
	OgreBotAPI:Travel["all","Undercity Arena",TRUE]
	
	;// intercept jumping point
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]} >50
	{	
		;echo " traveling to cleft, jump point distance : "${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]}
		wait 5
	}
	OgreBotAPI:Jump
	wait 20
	
	call OnFootZoneNav "ZoningHiddenCache" 
	wait 5

	OgreBotAPI:Zone["all"]
}

function SilentCityFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	echo Moving to "Dock carpet" returned: ${Return}
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to twin tears
	OgreBotAPI:Travel["all","Silent City",TRUE]
	
	OgreBotAPI:Message[${Me.Name}, >>> Flying to Silent city cave. Enjoy the ocean breeze., TRUE, default]
	
	;// Waiting until carpet travel is complete (check distance to landing loc)
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-949.62,-228.76,-1059.38]} >10
	{	
		wait 10
	}
	wait 5
	
	call OnFootZoneNav "ZoningSilentCity" 
		wait 10
	
	OgreBotAPI:Zone["all"]				
}

;;;;;;;;;;;;;;;;;;;;;
;;	
;;	Single segment movements & specific script bits
;;
;;;;;;;;;;;;;;;;;;;;;			
function TwinTearsFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to twin tears
	OgreBotAPI:Travel["all","Twin Tears",TRUE]
 
	OgreBotAPI:Message[${Me.Name}, >>> Flying to Twin Tears oasis. Enjoy the view., TRUE, default]
	
	;// Waiting until carpet travel is complete (check distance to landing loc)
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-437.17,-76.67,-982.49]} >10
	{	
		wait 10
	}
}

;// Move to the POF camp via carpet from the docks
function PofCampFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	echo Moving to "Dock carpet" returned: ${Return}
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to twin tears
	OgreBotAPI:Travel["all","Camp D'Sas",TRUE]
	
	OgreBotAPI:Message[${Me.Name}, >>> Flying to Pillar of flame outside camp. Enjoy the view., TRUE, default]
	
	;// Waiting until carpet travel is complete (check distance to landing loc)
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-5.34,-93.12,-925.80]} >10
	{	
		wait 10
	}
}

;// Move to the Undercity via carpet from the docks
function UndercityFromDock()
{
	;// Moving to carpet
	call OnFootZoneNav "CarpetDock"
	echo Moving to "Dock carpet" returned: ${Return}
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to undercity
	OgreBotAPI:Travel["all","Undercity Arena",TRUE]
	
	OgreBotAPI:Message[${Me.Name}, >>> Flying to Undercity Arena. Be cwary of the orcs., TRUE, default]
	
	;// Waiting until carpet travel is complete (check distance to landing loc)
	while ${Math.Distance[${Actor[${Me.ID}].Loc},-203.20,-111.21,-279.77]} >10
	{	
		wait 10
	}
}

;// Move to sanctorium (incl zoning) from Twin tears
function SanctoriumFromTwinTears()
{
	;// Moving to carpet
	call OnFootZoneNav "ZoningSanctorium"
	echo Moving to "Sanctorium zoning" returned: ${Return}
		wait 10
	
	OgreBotAPI:Zone[${Me.Name}]
			
}

;// Move to Living tombs (incl zoning) from Twin tears
function LivingTombsFromTwinTears()
{
	;// Moving to carpet
	call OnFootZoneNav "ZoningLivingTombs"
		wait 10
	
	OgreBotAPI:Zone[${Me.Name}]			
}

function GoaaFromTwinTears()
{
	;// Moving to carpet
	call OnFootZoneNav "NPCgoaa"
		wait 10
	
	RunScript DOF_NavTool/DOF_HailRaidAccessNPC		
}

function DockFromDruidRing()
{
	;// Moving to carpet
	call OnFootZoneNav "DockRallyPoint"
		wait 10
}

function ZoneRoostCleftsDoor(string RoostOrCleft)
{
	OgreBotAPI:Zone["all"]
	wait 5
	switch ${RoostOrCleft}
	{
		case cleft
			OgreBotAPI:ZoneDoor["The Clefts of Rujark"]
		break
		case roost
			OgreBotAPI:ZoneDoor["Scornfeather Roost"]
		break
		default
			;Default will just use default param (1)
			OgreBotAPI:ZoneDoor
		break
	}
}

;// Talk to carpet NPC & open traval map
function TravelCarpet_NPC()
{
	Actor[exactname,"a nomadic carpet keeper"]:DoTarget
	wait 10
	EQ2Execute /hail
	wait 10
	EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[1]:LeftClick
}


;;;;;;;;;;;;;;;;;;;;;
;;	
;;	SCRIPT FUNCTIONS	
;;
;;;;;;;;;;;;;;;;;;;;;
function load_OgreNav_Into_Memory()
{
	;// You shouldn't touch these lines.
	;// Make sure the navlib object is loaded into memory
	ogre navlib
	wait 2
	;// Create the variables we will be using within our script.
	Obj_OgreCreateNavLibs:CreateNavLib[${Script.Filename}]
	Obj_OgreCreateNavLibs:CreateNavEntry[${Script.Filename}]
}
function Load_OgreUtilities()
{
    ogre utilities
    wait 5
    Obj_CreateOgreUtilities:CreateOgreUtilities[${Script.Filename}]
    ;// Returns variable: OgreUtilities
    Obj_CreateOgreUtilities:CreateOgreCharacterData[${Script.Filename}]
    ;// Returns variable: OgreCharacterData

} 
function Resetting_Defaults()
{
	OgreNavLib:SetEQ2Defaults
}

function:bool OnFootZoneNav(... Params)
{

	variable point3f Loc
	variable int iCounter
	if ${Params.Used} == 0
	{
		return FALSE
	}
	for ( iCounter:Set[1] ; ${iCounter} <= ${Params.Used} ; iCounter:Inc )
	{
		switch ${Params[${iCounter}]}
		{
			case loc
			case -loc
				Location:Set["Loc"]
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				Loc.X:Set[${Params[${iCounter}]}]
				
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				Loc.Y:Set[${Params[${iCounter}]}]
				
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				Loc.Z:Set[${Params[${iCounter}]}]
				
				OgreNavEntry:Set_XYZ[${Loc}]
			break
			case -p
			case -precision
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				OgreNavLib:Set_Precision[${Params[${iCounter}]}]
			break
			case -p2d
			case -ptd
			case -precisiontodestination
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				OgreNavLib:Set_PrecisionToDestination[${Params[${iCounter}]}]
			break
			case -tr
			case -targetrequired
				OgreNavLib:Set_TargetRequired[TRUE]
			break
			case -ntr
			case -notargetrequired
				OgreNavLib:Set_TargetRequired[FALSE]
			break
			case -forceland
			case -forcelandafternav
			case -flan
			case -flap
			case -fl
				OgreNavLib:Set_ForceLandAfterNav[TRUE]
			break
			case -noland
				OgreNavLib:Set_ForceLandAfterNav[FALSE]
			break
			case -forcelandonmap
			case -forcelandafternavonmap
			case -flanom
			case -flapom
			case -flom
				OgreNavLib:Set_ForceLandAfterNavOnMap[TRUE]
			break
			case -nolandonmap
				OgreNavLib:Set_ForceLandAfterNav[FALSE]
			break
			case -allowflyingoffmap
				OgreNavLib:Set_AllowFlyingOffMap[TRUE]
			break
			case -noflyoffmap
			case -nofom
				OgreNavLib:Set_AllowFlyingOffMap[FALSE]
			break
			case -nolos
				OgreNavLib:Set_IgnoreLOSCheck[TRUE]
			break
			case -los
				OgreNavLib:Set_IgnoreLOSCheck[FALSE]
			break
			case -ignorepathing
			case -ip
				OgreNavLib:Set_IgnorePathing[TRUE]
			break
			case -allowpathing
			case -ap
				OgreNavLib:Set_IgnorePathing[FALSE]
			break
			
			case -DistanceToMoveBackToPath
			case -DTMBTP
				iCounter:Inc
				if ${Params.Used} < ${iCounter}
					continue
				OgreNavLib:Set_DistanceToMoveBackToPath[${Params[${iCounter}]}]
			break
			case -l
			case -list
			case list
				OgreNavLib:ListCustomNamedLocations
				return
			break
			default
				OgreNavEntry:Set_Location["${Params[${iCounter}]}"]
			break
		}
	}
	
	call OgreNavLib.OgreNav OgreNavEntry
	return ${Return}
}
