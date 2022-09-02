;;;;;;;;;;;;;;;;;;;;;
;;	Map points
;;		carpet locs : CarpetX (point to take the carpet from)/ LandingX (point where the carpet lands)
;;			CarpetCaravan
;;			CarpetStingingIsle
;;			
;;			LandingStingingIsle		845.53,-150.51,-1343.64
;;			Landing
;;			Landing
;;			
;;			
;;		Zoning points : ZoningX
;;			ZoningShimmeringCitadel
;;			ZoningMesa
;;			>>>>>>>>>>>>>>>>>>>>>>TODO :ZoningClefts
;;			
;;			
;;			
;;		NPC : NPCx
;;			NPChunter		Hunter NPC
;;			NPCcoaa			NPC to hail for coaa access
;;
;;
;;		Others
;;			1022.89,-102.54,-399.91 			Jumping point from carpet for Cazel Mesa
;;			EvacPoint	73.79,-88.80,-807.02
;;			StingingJumpDownSetup				Jumping down from stinging to shimmering area, step1
;;			StingingJumpDownAutorunPoint		Jumping down from stinging to shimmering area, step2 > get there from 1 then autorun and jump
;;			StingingJumpDownLandingRally		Rally there after jump
;;;;;;;;;;;;;;;;;;;;;

function main(string POFnavRoutine)
{
	call load_OgreNav_Into_Memory
	call Load_OgreUtilities
	
	call ${POFnavRoutine}

	OgreBotAPI:Message[${Me.Name}, Arrived at destination <<<<<<<<, TRUE, default]
	OgreBotAPI:Message[${Me.Name}, ==================================, FALSE, default]
}

;;;;;;;;;;;;;;;;;;;;;
;;	
;;	Complete navigation routines
;;
;;;;;;;;;;;;;;;;;;;;;
function HunterFromCamp()
{
	call StingingIsleFromCamp
	wait 10
	call HunterFromStingingIsle
}
function ShimmeringCitadelFromCamp()
{
	call StingingIsleFromCamp
	wait 10
	call ShimmeringCitadelFromStingingIsle	
}
function CoaaFromCamp()
{
	call StingingIsleFromCamp
	wait 10
	call CoaaFromStingingIsle
	wait 10
	RunScript DOF_NavTool/DOF_HailRaidAccessNPC
}

function MesaFromCamp()
{
	;// Moving to camp carpet
	call OnFootZoneNav "CarpetCaravan"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to Stinging Isle
	OgreBotAPI:Travel["all","Giant's Field",TRUE]
	
	;// intercept jumping point
	while ${Math.Distance[${Actor[${Me.ID}].Loc},1022.89,-102.54,-399.91]} >50
	{	
		;echo " traveling to mesa, jump point distance : "${Math.Distance[${Actor[${Me.ID}].Loc},-858.05,-123.13,-299.37]}
		wait 5
	}
	
	OgreBotAPI:Jump
	wait 20
	
	call OnFootZoneNav "ZoningMesa" 
	wait 5
	
	OgreBotAPI:Zone["all"]
}



;;;;;;;;;;;;;;;;;;;;;
;;	
;;	Single segment movements & specific script bits
;;
;;;;;;;;;;;;;;;;;;;;;

function StingingIsleFromCamp()
{
	;// Moving to camp carpet
	call OnFootZoneNav "CarpetCaravan"
	
	;//Carpet keeper dialogue 
	call TravelCarpet_NPC
		wait 10
	
	;//Carpet to Stinging Isle
	OgreBotAPI:Travel["all","Stinging Isle",TRUE]
	
	;// Waiting until carpet travel is complete (check distance to landing loc)
	while ${Math.Distance[${Actor[${Me.ID}].Loc},845.53,-150.51,-1343.64]} >10
	{	
		wait 10
	}
	echo arrived at Stinging Isle
}
function HunterFromStingingIsle()
{
	call GetDownFromStinging
	wait 5
	;// Moving to npc
	call OnFootZoneNav "NPChunter"
	echo Moving to Hunter NPC returned: ${Return}
}

function CoaaFromStingingIsle()
{
	call GetDownFromStinging
	wait 5
	;// Moving to npc
	call OnFootZoneNav "NPCcoaa"
	echo Moving to Hunter NPC returned: ${Return}
}

function ShimmeringCitadelFromStingingIsle()
{
	call GetDownFromStinging
	wait 5
	;// Moving to shimmering citadel zoning
	call OnFootZoneNav "ZoningShimmeringCitadel"
	echo Moving to shimmering citadel returned: ${Return}
	wait 5
	OgreBotAPI:Zone["all"]
}

;// Script to get from the Stinging isle carpet landing down to the shimmering/ hunter area (jump & avoid wall)
function GetDownFromStinging()
{
	;// Assuming you're at the stinging isle carpet, or close enough to get back on a mapped surface.
	;Get to the setup point in front of the wall/bridge
	call OnFootZoneNav "StingingJumpDownSetup"
	
	wait 2
	
	;Go to the autorun point > everyone should be correctly aligned
	call OnFootZoneNav "StingingJumpDownAutorunPoint"

	wait 2
	OgreBotAPI:AutoRun
	wait 3
	OgreBotAPI:Jump
	OgreBotAPI:AutoRun
	
	wait 20
	
	call OnFootZoneNav "StingingJumpDownLandingRally"
	echo Jump down rally point returned: ${Return}
	
	;get back on mapped navigation from there
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

;// Talk to carpet NPC & open travel map
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
