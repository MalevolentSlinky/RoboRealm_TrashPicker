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
right_speed = 220
claw_speed = 220
rev_claw_speed = 60
rev_left_speed = 128
rev_right_speed = 128
stopped = 128



' this is the orientation produced by the path_planning and the
' orientation we want the robot to be at
desiredOrientation = GetVariable("plan_orientation")

' but first check to see if we are running or have completed all waypoints.
' When all waypoints have been visited the plan_orientation becomes -1.
if GetVariable("interface_run") <> "1" or desiredOrientation = "-1" then

  SetVariable "left_motor", stopped
  SetVariable "right_motor", stopped

else

' get the current robot orientation
robotOrientation = GetVariable("robot_orientation")


trashX = GetVariable("trash_x")
trashY = GetVariable("trash_y")
robotX = GetVariable("robot_x")
robotY = GetVariable("robot_y")
destinationX = GetVariable("destination_x")
destinationY = GetVariable("destination_y")
obstacleX = GetVariable("obstacle_x")
obstacleY = GetVariable("obstacle_y")
SetVariable "obstacleX", GetVariable("obstacle_x")

'if robot_x is near obstacle_x && robot_y is near obstacle_y
if robotX > (obstacleX-25) and robotX < (obstacleX+25) and _
  robotY > (obstacleY-25) and robotY < (obstacleY+25) then
	SetTimedVariable "objectAvoidMode", 0, 5000 'set to stop avoiding in 5 seconds
	if prevObjectAvoidMode <> ObjectAvoidMode then '<> means not equal to
		SetVariable "avoidAngleMod", 90 'to be amount that the bot will turn away from obstacle
	end if
end if

prevObjectAvoidMode = GetVariable("ObjectAvoidMode")
 
if objectAvoidMode = 0 then

	' reduce the precision of each of the orientations to
	' 20 degree increments otherwise the robot (not being 
	' perfect in its movements) will spend all its time aligning
	' to a degree that it cannot achieve.
	robotOrientation = CInt((robotOrientation / 40) ) * 40
	desiredOrientation = CInt((desiredOrientation / 40) ) * 40

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

	end if 
end if

if objectAvoidMode = 1 then
	'perform object avoid state behavior
	'some logic should be here to control the decrement rate of avoidAngleMod every ten frames or so..
	
	SetVariable "j", j + 1
	if  j Mod 50 = 0 then
		avoidAngleMod = avoidAngleMod - 1 'starts at 90 and decreases for round avoid movement pattern
	end if
	
	
	
	robotOrientation = CInt((robotOrientation / 40) ) * 40
	desiredOrientation = CInt(((desiredOrientation+avoidAngleMod) / 40) ) * 40

	' calculate the different between the two angles
	diff = abs((desiredOrientation) - robotOrientation )

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
	
end if


SetVariable "claw_time", 1000 'milliseconds
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
	SetVariable "has_trash", -1
	Write "claw Signal Generated!\n"
	
end if

if startClawMove = 1 then
	Write "claw ACTIVATE!\n"
	'if clawRotation <  270 then claw_motor = claw_speed could be a good way to do this
	if VariableExists("has_trash") then'on 1st trash found initialize to -1 (has no trash)...
		setVariable "has_trash", -1
	end if
	if  has_trash = -1 then 'if robot wants to move claw and has no trash in claw... 
		Write "I HAVE NO TRASH, CLOSE CLAW! \n"
		SetVariable "claw_motor", claw_speed
		SetTimedVariable "startClawMove", 0, claw_time	
		if startClawMove = 0 then 'last thing done in this part of code
			setVariable "has_trash", 1
		end if
	elseif has_trash = 1 then
		Write "I HAVE TRASH, OPEN THE CLAW!\n"
		SetVariable "claw_motor", -1 * claw_speed 
		SetTimedVariable "startClawMove", 0, claw_time	'will set sCM to zero in claw_time (ms)
		if startClawMove = 0 then 'last thing done in this part of code
			setVariable "has_trash", 0
		end if		
	end if
else 
	'SetVariable "claw_motor", stopped
end if

currWaypointX = GetVariable("WAYPOINT_X")
SetVariable "currWaypointX", currWaypointX
' interface_pause

' variables left_motor right_motor and claw_motor now contain the motor
' movements.













