;;;;;;;;;;;;;;;;;;;;;
;;	DOF script suit
;;		Library stuff
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
