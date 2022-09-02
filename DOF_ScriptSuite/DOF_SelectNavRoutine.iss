variable string SelectedNavRoutine
variable string StartingPoint
variable string EndPoint
variable bool IsRelay
variable string DofZoneName
variable string StartInputWindowPrompt = "Enter Starting point: "
variable string EndInputWindowPrompt = "Enter target nav: "
variable string NavRoutineScriptPrefix

function main()
{
	OgreBotAPI:Message[${Me.Name}, ==================================, FALSE, default]
	OgreBotAPI:Message[${Me.Name}, ==== DOF navigation assistant ====, FALSE, default]
	OgreBotAPI:Message[${Me.Name}, ==================================, FALSE, default]
	
	;// Get zone name & corresponding prompt for movements options.
	DofZoneName:Set[${Zone.Name}]
	switch ${Zone.Name}
	{
		case The Sinking Sands
			StartInputWindowPrompt:Set[${StartInputWindowPrompt}dock | DR (druid ring)]
			EndInputWindowPrompt:Set[${EndInputWindowPrompt}sanct | cache | cleft | roost | pof | tomb | city]
			NavRoutineScriptPrefix:Set[SS]
		break
		case The Pillars of Flame
			StartInputWindowPrompt:Set[${StartInputWindowPrompt}Camp ; nothing else atm]
			EndInputWindowPrompt:Set[${EndInputWindowPrompt}hunter | citadel | mesa | coaa | si (Stinging isle)]
			NavRoutineScriptPrefix:Set[POF]
		break
		
		default
			OgreBotAPI:Message[${Me.Name}, No navigation routine available for ${Zone.Name}. Sorry :/, FALSE, default]
		break
	}

	;// Input window for starting & end point 
	InputBox "${StartInputWindowPrompt}"
	if ${UserInput.Length}
	{
		switch ${UserInput}
		{
			;// Sinking Sands inputs
			case DR
			case ring
			case druid
				StartingPoint:Set["DruidRing"]
			break
			
			case dock
			case docks
			case d
				StartingPoint:Set["Dock"]
			break
			
			case tt
				StartingPoint:Set["TwinTears"]
			break
			
			;//Pillars of Flame inputs
			case camp
			case caravan
			case swift
				StartingPoint:Set["Camp"]
			break
			
			;// missing / wrong param
			default 
				OgreBotAPI:Message[${Me.Name}, Unknown Starting point (${UserInput}), TRUE, default]
			break
			
		}
	}
	wait 1
	
	InputBox  "${EndInputWindowPrompt}"
	if ${UserInput.Length}
	{	
		switch ${UserInput}
		{
		;;;;;;;;;;;;;;;;;;;;;;;;;;
		;// Sinking Sands inputs
		;;;;;;;;;;;;;;;;;;;;;;;;;;
			case dock
			case docks
				EndPoint:Set["Dock"]
				IsRelay:Set[TRUE]
			break
			
			case sanc
			case sanct
			case sanctorium
				EndPoint:Set["Sanctorium"]
				IsRelay:Set[FALSE]
			break
			
			case cache
			case hidden cache
			case hc
				EndPoint:Set["HiddenCache"]
				IsRelay:Set[FALSE]
			break
			
			case cleft
			case clefts
			case rujark
				EndPoint:Set["Clefts"]
				IsRelay:Set[TRUE]
			break
			
			case roost
			case scornfeather
			case scorn
				EndPoint:Set["Roost"]
				IsRelay:Set[FALSE]
			break
			
			case pof
			case pillar
			case flame
				EndPoint:Set["PillarOfFlames"]
				IsRelay:Set[TRUE]
			break
			
			case TT
			case twin
			case tear
			case tears
			case twin tear
			case twin tears
				EndPoint:Set["TwinTears"]
				IsRelay:Set[TRUE]
			break
			
			case tomb
			case tombs
			case living tomb
			case living tombs
			case lt
				EndPoint:Set["LivingTombs"]
				IsRelay:Set[TRUE]
			break
			
			case goaa
			case gates
			case raid
				EndPoint:Set["Goaa"]
				IsRelay:Set[TRUE]
			break
			
			case city
			case silent
			case sc
			case silent city
				EndPoint:Set["SilentCity"]
				IsRelay:Set[TRUE]
			break
			
		;;;;;;;;;;;;;;;;;;;;;;;;;;
		;//Pillars of Flame inputs
		;;;;;;;;;;;;;;;;;;;;;;;;;;
			case hunter
			case hunternpc
				EndPoint:Set["Hunter"]
				IsRelay:Set[TRUE]
			break
			
			case stinging
			case sting
			case si
				EndPoint:Set["StingingIsle"]
				IsRelay:Set[TRUE]
			break
			
			case coaa
			case court
				EndPoint:Set["Coaa"]
				IsRelay:Set[TRUE]
			break
			
			case citadel
			case cit
			case shimmering
			case shim
				EndPoint:Set["ShimmeringCitadel"]
				IsRelay:Set[TRUE]
			break
			
			break
			case mesa
			case cazel
			case cm
				EndPoint:Set["Mesa"]
				IsRelay:Set[FALSE]
			break
			
			
			;// missing / wrong param / tests
			
			default 
				OgreBotAPI:Message[${Me.Name}, Unknown target point (${UserInput}), TRUE, default]
			break
			
		}
	}
	wait 5
	
	;// concat IW results for NavRoutine param, and then call actual nav routines, with or without relay (move single char vs move whole group/raid), for the correesponding zone
	SelectedNavRoutine:Set[${EndPoint}From${StartingPoint}]
	
	if ${IsRelay} 
	{
		OgreBotAPI:Message[${Me.Name}, >>>Moving whole group from ${StartingPoint} to ${EndPoint} in ${DofZoneName}, FALSE, default]
		echo Moving whole group
		relay all RunScript DOF_NavTool/${NavRoutineScriptPrefix}_NavRoutine ${SelectedNavRoutine}	
	}
	else
	{
		echo ===============   >>>>>>> ${NavRoutineScriptPrefix}
		echo ===============   >>>>>>> ${NavRoutineScriptPrefix}
		echo ===============   >>>>>>> ${NavRoutineScriptPrefix}
		OgreBotAPI:Message[${Me.Name}, >>>Moving ${Me.Name} from ${StartingPoint} to ${EndPoint} in ${DofZoneName}, FALSE, default]
		echo Moving active char only
		RunScript DOF_NavTool/${NavRoutineScriptPrefix}_NavRoutine ${SelectedNavRoutine}
	}
}
