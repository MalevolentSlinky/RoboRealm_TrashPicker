' define some constants to use for speed. Note that the boe-bot
' moves forward with left and right being opposite numbers (due
' to the flipping of the servos as part of the robot construction)
left_speed = 210
right_speed = 210
claw_speed = 180
rev_claw_speed = 60
rev_left_speed = 40
rev_right_speed = 40
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
robotY= GetVariable("robot_y")
destinationX = GetVariable("destination_x")
destinationY= GetVariable("destination_y")


' reduce the precision of each of the orientations to
' 20 degree increments otherwise the robot (not being 
' perfect in its movements) will spend all its time aligning
' to a degree that it cannot achieve.
robotOrientation = CInt((robotOrientation / 20) ) * 20
desiredOrientation = CInt((desiredOrientation / 20) ) * 20

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




claw_time = 1
'SetVariable "has_trash",0
has_trash = GetVariable("has_trash")



nextWaypointX = GetVariable("WAYPOINT_X")

if not currWaypointX = nextWaypointX then 'if the waypoint changes then do claw stuff
	'do nothing until waypoint changes then move claw 
	'and change direction flag
	'if the current waypoint changes then that means
	'a piece of trash has been picked up or delivered
	SetVariable "startClawMove", 1
end if

if startClawMove = 1 then
	'if clawRotation <  270 then claw_motor = claw_speed could be a good way to do this
	if has_trash = 0 then'on 1st trash found initialize to one...
		setVariable "has_trash", -1
	end if
	if  has_trash = -1 then 'if robot wants to move claw and has no trash in claw... 
		SetVariable "claw_motor", claw_speed
		SetTimedVariable "startClawMove", 0, claw_time	
		if startClawMove = 0 then 'last thing done in this part of code
			setVariable "has_trash", 1
		end if
	elseif has_trash = 1 then
		SetVariable "claw_motor", -1 * claw_speed 
		SetTimedVariable "startClawMove", 0, claw_time	
		if startClawMove = 0 then 'last thing done in this part of code
			setVariable "has_trash", 0
		end if		
	end if
else 
	SetVariable "claw_motor", stopped
end if

currWaypointX = GetVariable("WAYPOINT_X")
SetVariable "nextWaypointX", nextWaypointX

' interface_pause

' variables left_motor right_motor and claw_motor now contain the motor
' movements.













