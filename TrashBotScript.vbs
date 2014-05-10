'TODO 
	'TAPER RAPIDITY OF MOVEMENT ARC DECREASE RATE IN OA 
	'ADD ROBOREALM SIDE LOGIC FOR STORING OBSTACLE DATA
	'ADD A FOR LOOP FOR MULTIPLE OBSTACLE AVOIDANCE (AROUND THE OA PROXIMITY CHECK)

	
'TO RUN PROPERLY YOU MUST
'1. RESET THE PROGRAM WITH THE GUI 
'2. ENABLE OTHER VBSCRIPT 
'3. DISABLE THIS VBSCRIPT
'4. DISABLE OTHER VBSCRIPT
'5. ENABLE THIS VBSCRIPT	

	
' define some constants to use for speed. Note that the ROBOMO
' moves forward with left and right being opposite numbers (due
' to the flipping of the servos as part of the robot construction)
left_speed = 220
right_speed = 218
claw_speed = 220
rev_claw_speed = 30
rev_left_speed = 60
rev_right_speed = 60
stopped = 128

if GetVariable("state") = "0" then
	SetVariable "state", 1
end if


' this is the orientation produced by the path_planning and the
' orientation we want the robot to be at
desiredOrientation = GetVariable("plan_orientation")

' but first check to see if we are running or have completed all waypoints.
' When all waypoints have been visited the plan_orientation becomes -1.
if GetVariable("interface_run") <> "1" or desiredOrientation = "-1" then

  SetVariable "left_motor", stopped
  SetVariable "right_motor", stopped
  
  'STATES: 1) Goto & Dispose Trash 2)Release Trash and turn around
elseif GetVariable("state") = "1" then


	' get the current robot orientation
	robotOrientation = GetVariable("robot_orientation")
	SetVariable "robotOrientation", robotOrientation

	trashX = GetVariable("trash_x")
	trashY = GetVariable("trash_y")
	robotX = GetVariable("robot_x")
	robotY = GetVariable("robot_y")
	destinationX = GetVariable("destination_x")
	destinationY = GetVariable("destination_y")
	'obstacleX = GetVariable("obstacle_x")
	'obstacleY = GetVariable("obstacle_y")
	SetVariable "obstacleX", GetVariable("obstacle_x")

	' reduce the precision of each of the orientations to
	' 20 degree increments otherwise the robot (not being 
	' perfect in its movements) will spend all its time aligning
	' to a degree that it cannot achieve.
	robotOrientation = CInt((robotOrientation / 10) ) * 10
	desiredOrientation = CInt((desiredOrientation / 10) ) * 10

	' calculate the different between the two angles
	diff = abs(desiredOrientation - robotOrientation )

	' if they are the same (within 20 degrees) just
	' move forward
	if desiredOrientation = robotOrientation then

	  SetVariable "left_motor", left_speed
	  SetVariable "right_motor", right_speed

	' otherwise turn in the appropriate direction. Note the use of
	' 180 testing to determine which turn direction would be fastest.
	' This allows the robot to turn in the most efficient direction
	elseif desiredOrientation > robotOrientation and diff < 180 or _
	  desiredOrientation < robotOrientation and diff >= 180 then

	  SetVariable "left_motor", rev_left_speed
	  SetVariable "right_motor", right_speed

	else

	  ' if we don't turn one way then default to the other
	  SetVariable "left_motor", left_speed
	  SetVariable "right_motor", rev_right_speed

	end if




	'SetVariable "has_trash",0
	has_trash = GetVariable("has_trash")



	nextWaypointX = GetVariable("WAYPOINT_X")
	SetVariable "nextWaypointX", nextWaypointX

	if GetVariable("currWaypointX") = 0 then
		currWaypointX = nextWaypointX
		SetVariable "claw_motor", stopped
	end if

	if currWaypointX <> nextWaypointX then 'if the waypoint changes then do claw stuff
		'do nothing until waypoint changes then move claw 
		'and change direction flag
		'if the current waypoint changes then that means
		'a piece of trash has been picked up or delivered
		SetVariable "claw_motor", claw_speed
		SetVariable "startClawMove", 1
		'SetVariable "has_trash", -1
		Write "claw Signal Generated!"

	else 	
		
	end if

	select case GetVariable("startClawMove")

		case 1:
			claw_time = 1000
			SetTimedVariable "startClawMove",0,claw_time
			SetVariable "startClawMove", 2
			
			
		case 2:	
			if VariableExists("has_trash") then'on 1st trash found initialize to -1 (has no trash)...
				SetVariable "has_trash", -1
			end if
			if  has_trash = -1 then 'if robot wants to move claw and has no trash in claw... 
				Write "I HAVE NO TRASH, CLOSE CLAW! \n"
				SetVariable "claw_motor", claw_speed
			elseif has_trash = 1 then
				interface_reset = 1
				Write "I HAVE TRASH, OPEN THE CLAW!\n"
				SetVariable "claw_motor", rev_claw_speed 
				'state = 2
				SetVariable "right_motor", rev_right_speed
				SetVariable "left_motor", rev_left_speed			
				SetTimedVariable "startClawMove", 0, claw_time	'will set sCM to zero in claw_time (ms)
				if startClawMove = 0 then 'last thing done in this part of code
					SetVariable "has_trash", 0
				end if		
			end if
		case 0:
			if has_trash = -1 then
				has_trash = 1
			else 
				has_trash = -1
			end if
			SetVariable "claw_motor", stopped

	end select  
		'SetVariable "claw_motor", stopped
end if


if GetVariable("state") = "2" then'elseif state = 2 then
	'SetVariable "state", 69999
	
	SetVariable "resetVar", GetVariable("resetVar")
	SetVariable "left_motor", 40
	SetVariable "right_motor", 40
	SetVariable "claw_motor", 40
	
end if

if GetVariable("resetVar") = "2" then
	Write "RESETVAR IS 2"
	SetVariable "state", 1	
end if

if robotX > (destinationX-25) and robotX < (destinationX+25) and robotY > (destinationY-25) and robotY < (destinationY+25)  then
  'if has_trash = 1 then
	'SetVariable "claw_motor", 40
	SetVariable "interface_reset", 1
	'SetVariable "resetVar", 0
	SetVariable "state", 2	
end if	

if GetVariable("state") = 2 then
	select case GetVariable("resetVar")

		case 0:
			turnaround_time = 2000
			SetTimedVariable "resetVar",2,turnaround_time
			SetVariable "resetVar", 1
		
		case 1: 
			SetVariable "left_motor", 40
			SetVariable "right_motor", 40
			SetVariable "claw_motor", 40
			'SetTimedVariable "has_trash", 0, claw_time
		case 2:
			SetVariable "state", 1	
			SetVariable "resetVar", 0
			
	end select
end if
	
currWaypointX = GetVariable("WAYPOINT_X")
SetVariable "currWaypointX", currWaypointX
' interface_pause

' variables left_motor right_motor and claw_motor now contain the motor
' movements.













