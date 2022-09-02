;;;;;;;;;;;;;;;;;;;;;
;;	DOF script suite by Arakis.
;;
;;
;;	>> Poet Palace - Statue puzzle handler.
;;	>>
;;	>> handle the statue puzzle. Start with chars in the statue table room. 
;;	>> 1 run of the script only handle a third of the whole puzzle(brass, steel, or plat). Do the fight in between however you see fit (manually / script / IC)
;;
;;
;;	;;Includes.
#include "${LavishScript.HomeDirectory}/Scripts/DOF_NavTool/dof_includes.iss"
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
;;	Map points
;;	
;;	Named point for navigation to pedestals (run there, script will face / put statue down) : 
;;		StatueBrass1
;;		StatueBrass2
;;		StatueBrass3
;;		StatueBrass4
;;		StatueBrass5
;;		StatueBrass6
;;		StatueBrass7
;;		StatueBrass8
;;		StatueBrass9
;;		StatueSteel1
;;		StatueSteel2
;;		StatueSteel3
;;		StatueSteel4
;;		StatueSteel5
;;		StatuePlat1
;;		StatuePlat2
;;		StatuePlat3
;;		StatuePlat4
;;  
;;	Second floor, doors 
;;		door 1:	Loc -> 7.216743,185.983765,7.813705
;;				Heading Closed  90.015633
;;				Heading Opened	0.015625
;;		door 2:	Loc -> -34.234344,185.983765,-7.231743
;;				Heading Closed	180.000000
;;				Heading Opened	90.015633
;;
;;		Rally point in front of the table
;;			StatueTableRallyPoint
;;
;;;;;;;;;;;;;;;;;;;;;
function main(int startingStatue, int endingStatue, bool useGroupToOpenDoor)	
{
	;; Parameters, in order : 
	;; Brass Steel Plat. (Also works with : b s p )
	;; min 1. Max 9 for brass, 5 for steel, 4 for plat.
	;; min 1. Max 9 for brass, 5 for steel, 4 for plat.
	;; Set to true to have 2 additional char of the group go to the door & keep them open.

	variable string StatueType

	call load_OgreNav_Into_Memory
	call Load_OgreUtilities

	OgreBotAPI:Message[${Me.Name}, ====================================, FALSE, default]
	OgreBotAPI:Message[${Me.Name}, ==== Poet Palace Puzzle handler ====, FALSE, default]
	OgreBotAPI:Message[${Me.Name}, ====================================, FALSE, default]
	
	;; Check some of the false inputs.
	if ${startingStatue} > ${endingStatue} 
	{
		OgreBotAPI:Message[${Me.Name}, "Wrong inputs: Start > End, FALSE, default]
		Return false
	}
	else
	{
		;; send char from group to stay at the doors & keep them opened.
		;; Char at position 2 & 3 from the group will be used. (relative to the char the script is called from, who's at position 0)
		if ${useGroupToOpenDoor}
		{
			oc !ci -HoldUp
			OgreBotAPI:Message[${Me.Name}, "=-= Sending "${Me.Group[1].Name}" To open the doors", FALSE, default]
			OgreBotAPI:Message[${Me.Name}, "=-= Sending "${Me.Group[2].Name}" To open the doors", FALSE, default]
			
			oc !ci -RunScriptRequiresOgreBot ${Me.Group[1].Name} DOF_NavTool/PoetPalaceDoorHandler 1 1
			oc !ci -RunScriptRequiresOgreBot ${Me.Group[2].Name} DOF_NavTool/PoetPalaceDoorHandler 1 2
		}
		
		;; cf chat even atom. Used to verify that statues clicked into place or not.
		Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]

		; Statue type input box. Need to do stuff to allow param on top of it.
		InputBox "Statue type : brass | steel | plat"
		StatueType:Set[${UserInput}]
		wait 1

		;; Run corresponding bit. Include some wrong inputs check.
		;; Note : Actual type cript can be factorized... ToDo i guess.
		switch ${StatueType}
		{
			case b
			case brass
				if (${startingStatue} > 9 || ${endingStatue} > 9)
				{
					OgreBotAPI:Message[${Me.Name}, "Wrong inputs: Only 9 brass statues", FALSE, default]
					Return false
				}
				call doBrassStatues ${startingStatue} ${endingStatue}
			break
			
			case s
			case steel
				if (${startingStatue} > 5 || ${endingStatue} >5)
				{
					OgreBotAPI:Message[${Me.Name}, "Wrong inputs: Only 5 steel statues", FALSE, default]
					Return false
				}
				else
					call doSteelStatues ${startingStatue} ${endingStatue}
			break
			
			case p
			case plat
			case platinium
				if (${startingStatue} > 4 || ${endingStatue} > 4)
				{
					OgreBotAPI:Message[${Me.Name}, "Wrong inputs: Only 4 platinium statues", FALSE, default]
					Return false
				}
				else
				call doPlatStatues ${startingStatue} ${endingStatue}
			break
			
			default
				OgreBotAPI:Message[${Me.Name}, "Wrong inputs: Unrecognised statue type (brass, plat, steel)", FALSE, default]
				Return false
			break
		}
	}
}

;Repeated function in each loops.
; Prerequisite : Be in range of the statue to grab.
; Grab statue, move to pedestal, and put statue down. Does not come back to table.
function doPlaceStatueFromTable(string NavTarget, int statueID, string PedestalName)
 {
	; Camera loodDown is done beforehand. With a statue in hand, commands will just rotate it or pu it higher instead of moving the camera. ya know, housing commands.
	call OgreUtilities.Set_LookDown 10	
		wait 2
	OgreBotAPI:SetMousePosition_Middle
		wait 2
	Actor[ID,${statueID}]:DoubleClick
		wait 2
	
	; Yes, that means for the run to the pedestal is done looking at the ground ¯\_(ツ)_/¯
	call OnFootZoneNav ${NavTarget}
		wait 5
	
	; Face pedestal & put statue down. Map points should be set such as this end up with the statue in range. Atom text input check will return a message on the state of the statue.
	Actor[Name,${PedestalName}]:DoFace
		wait 2
	Mouse:LeftClick
		wait 2
		
	;Reseting camera to a normal position for the run back, cause it's nicer.
	call OgreUtilities.ResetCameraAngle
			wait 2
 }
 
function doBrassStatues(int startingStatue, int endingStatue)
 {
	variable int statueCounter
	variable int currentID
	variable string currentNavTarget
	variable string currentPedestal
	
	;; All statue positions on the table
	declare statueBrassLocArray[9] point3f
	statueBrassLocArray[1]:Set[37.651642,186.174911,-48.051231]
	statueBrassLocArray[2]:Set[36.895267,186.174911,-41.327751]
	statueBrassLocArray[3]:Set[42.666252,186.174911,-51.087521]
	statueBrassLocArray[4]:Set[38.442432,185.914368,-43.589073]
	statueBrassLocArray[5]:Set[42.079494,185.912170,-48.587238]
	statueBrassLocArray[6]:Set[36.767281,186.174911,-46.529839]
	statueBrassLocArray[7]:Set[40.959568,186.174911,-50.919991]
	statueBrassLocArray[8]:Set[36.114048,186.174911,-43.278774]
	statueBrassLocArray[9]:Set[36.761242,184.764709,-48.673038]
	
	;echo ${statueCounter} - ${endingStatue} - ${statueCounter}
	
	OgreBotAPI:Message[${Me.Name}, "=-= Looping brass statues =-=", FALSE, default]
	
	;Main loop.
	;Handle setting the variables (target statue / run spot ), and getting into position before calling the underlying function to put the statue in place.
	;Loop will keep going even if the statue isn't placed correctly, gotta manually adjust those after the fact
	statueCounter:Set[${startingStatue}]
	for ( statueCounter:Set[${startingStatue}] ; ${statueCounter} <= ${endingStatue} ; statueCounter:Inc )
	{
		;Vars setup
		currentID:Set[${Actor[Query,Loc=- ${statueBrassLocArray[${statueCounter}]}].ID}]
		currentNavTarget:Set[StatueBrass${statueCounter}]
		currentPedestal:Set[f2_03_brass_stand_small_0${statueCounter}]
		
		;Go to the rally point near the table and get in range of the statue to grab.
		call OnFootZoneNav "statueTableRallyPoint"
			wait 1
		Actor[ID,${currentID}]:DoFace
		OgreBotAPI:AutoRun
		
		while ${Math.Distance[${Actor[${Me.ID}].Loc},${statueBrassLocArray[${statueCounter}]}]} > 6
			waitframe
			
		OgreBotAPI:AutoRun
			wait 2
		
		; Statue placing script.
		call doPlaceStatueFromTable ${currentNavTarget} ${currentID} ${currentPedestal}
		
		OgreBotAPI:Message[${Me.Name}, "=-= Statue "${statueCounter}" placement complete. =-=", FALSE, default]
	}
	
	wait 1
	OgreBotAPI:Message[${Me.Name}, "==-== Statue placement completed ==-==", FALSE, default]
 }
 
 function doSteelStatues(int startingStatue, int endingStatue)
 {
	variable int statueCounter
	variable int currentID
	variable string currentNavTarget
	variable string currentPedestal
	declare statueSteelLocArray[5] point3f
	
	
	;; All statue positions on the table
	statueSteelLocArray[1]:Set[36.779701,186.174911,-46.624153]
	statueSteelLocArray[2]:Set[40.929100,186.174911,-50.798012]
	statueSteelLocArray[3]:Set[36.775272,186.174911,-41.413624]
	statueSteelLocArray[4]:Set[42.647152,186.174911,-51.110645]
	statueSteelLocArray[5]:Set[36.775272,186.174911,-41.413624]
	Loc -> 
	statueCounter:Set[${startingStatue}]
	echo ${statueCounter} - ${endingStatue} - ${statueCounter}
	
	OgreBotAPI:Message[${Me.Name}, "=-= Looping Steel statues =-=", FALSE, default]
	
	for ( statueCounter:Set[${startingStatue}] ; ${statueCounter} <= ${endingStatue} ; statueCounter:Inc )
	{
		currentID:Set[${Actor[Query,Loc=- ${statueSteelLocArray[${statueCounter}]}].ID}]
		currentNavTarget:Set[StatueSteel${statueCounter}]
		currentPedestal:Set[f2_03_steel_stand_small_0${statueCounter}]
		
		call OnFootZoneNav "statueTableRallyPoint"
		wait 1
		Actor[ID,${currentID}]:DoFace
		
		OgreBotAPI:AutoRun
		
		while ${Math.Distance[${Actor[${Me.ID}].Loc},${statueSteelLocArray[${statueCounter}]}]} > 6
			waitframe
			
		OgreBotAPI:AutoRun
		
		wait 2
		call OgreUtilities.Set_LookDown 10	
		wait 2
		OgreBotAPI:SetMousePosition_Middle
		wait 2
		Actor[ID,${currentID}]:DoubleClick
		
		wait 2
		call OnFootZoneNav ${currentNavTarget}
		wait 5
		
		Actor[Name,${currentPedestal}]:DoFace
		;wait 5
		;call OgreUtilities.Set_LookDown 10	
		;wait 2
		;OgreBotAPI:SetMousePosition_Middle
		wait 2
		Mouse:LeftClick
		wait 2
		call OgreUtilities.ResetCameraAngle
		wait 2
		
		OgreBotAPI:Message[${Me.Name}, "=-= Statue "${statueCounter}" placement complete. =-=", FALSE, default]
		
		;call OgreUtilities.Set_LookUp
	}
	wait 1
	OgreBotAPI:Message[${Me.Name}, "==-== Statue placement completed ==-==", FALSE, default]
 }
 
 function doPlatStatues(int startingStatue, int endingStatue)
 {
	variable int statueCounter
	variable int currentID
	variable string currentNavTarget
	variable string currentPedestal
	declare statuePlatLocArray[4] point3f
	
	
	;; All statue positions on the table
	statuePlatLocArray[1]:Set[36.699329,186.174896,-41.347401]
	statuePlatLocArray[2]:Set[42.526318,186.174896,-51.140842]
	statuePlatLocArray[3]:Set[38.270962,186.174896,-48.907192]
	statuePlatLocArray[4]:Set[36.751091,186.174896,-46.652191]
	
	statueCounter:Set[${startingStatue}]
	echo ${statueCounter} - ${endingStatue} - ${statueCounter}
	
	OgreBotAPI:Message[${Me.Name}, "=-= Looping Platinium statues =-=", FALSE, default]
	
	for ( statueCounter:Set[${startingStatue}] ; ${statueCounter} <= ${endingStatue} ; statueCounter:Inc )
	{
		currentID:Set[${Actor[Query,Loc=- ${statuePlatLocArray[${statueCounter}]}].ID}]
		currentNavTarget:Set[StatuePlat${statueCounter}]
		currentPedestal:Set[f2_03_plat_stand_small_0${statueCounter}]
		
		call OnFootZoneNav "statueTableRallyPoint"
		wait 1
		Actor[ID,${currentID}]:DoFace
		
		OgreBotAPI:AutoRun
		
		while ${Math.Distance[${Actor[${Me.ID}].Loc},${statuePlatLocArray[${statueCounter}]}]} > 6
			waitframe
			
		OgreBotAPI:AutoRun
		
		wait 2
		call OgreUtilities.Set_LookDown 10	
		wait 2
		OgreBotAPI:SetMousePosition_Middle
		wait 2
		Actor[ID,${currentID}]:DoubleClick
		
		wait 2
		call OnFootZoneNav ${currentNavTarget}
		wait 5
		
		Actor[Name,${currentPedestal}]:DoFace
		;wait 5
		;call OgreUtilities.Set_LookDown 10	
		;wait 2
		;OgreBotAPI:SetMousePosition_Middle
		wait 2
		Mouse:LeftClick
		wait 2
		call OgreUtilities.ResetCameraAngle
		wait 2
		
		OgreBotAPI:Message[${Me.Name}, "=-= Loop for statue "${statueCounter}" completed.", FALSE, default]
	}
	wait 1
	OgreBotAPI:Message[${Me.Name}, "==-== Statue placement completed ==-==", FALSE, default]
 }
 
;;;;;;;;;;;;;;;;;;;;;
;;	Chat event detection statue placement 
;;;;;;;;;;;;;;;;;;;;;
atom EQ2_onIncomingText(string Text)
{
    if ${Text.Find["The statue clicks into place."](exists)}
        OgreBotAPI:Message[${Me.Name}, ">>>> Statue placed correctly", FALSE, default]  
	elseif ${Text.Find["Nothing happens."](exists)}
		OgreBotAPI:Message[${Me.Name}, "!!! statue NOT placed correctly, adjust manually.!!!", TRUE, default]  
}

