-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Lobby Example Using NoobHub (https://github.com/Overtorment/NoobHub)

widget = require "widget"
require("noobhub")

_G.widget.setTheme( "widget_theme_ios" )

local serverIP = "localhost"
local serverPORT = 1337
local pollTimeInSEC = 60

local t = {}
local timerSource

local userName = system.getInfo ( "name" )
local userID = userName .. math.random ( )


local membersData = {}


latencies = {}
	

------------------------------------------------------------------------
------------------------------------------------------------------------

function publishNoob ( container, msg )
	--We are going to publish a messsage to NoobHub
	--testCondition contains True or False if it was
	--successful or not.
	testCondition = container:publish ( {
		message = {
			message = msg,
			origionatingUser = userName,
			}
		});

end

------------------------------------------------------------------------

local function onRowRender( event )
    local phase = event.phase
    local row = event.row

	if membersData [ row.index] then
	    local rowTitle = display.newText( row, membersData[row.index ], 0, 0, nil, 14 )
		rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 )
		rowTitle.y = row.contentHeight * 0.5 - 2
		rowTitle:setTextColor( 0, 0, 0 )
	end
end

------------------------------------------------------------------------

local function onRowTouch( event )
    local phase = event.phase

    if "press" == phase then
        print(  membersData[event.target.index ] )
    end
end

------------------------------------------------------------------------

local function matchListener ( message )

	if message.message == "ping" and message.origionatingUser ~= userName then
		--We have been requested to send out our data...
		
		local tempTable = {}
		tempTable.pong = true
		tempTable.user = userName
		tempTable.userID = userID
		tempTable.destinationUSER = message.origionatingUser
		
		local function sendRequest ( )
			publishNoob	( lobbyMatches, tempTable )
		end
		timer.performWithDelay ( 1, sendRequest, 1 )
		
	elseif message.message.pong == true and message.origionatingUser ~= userName and message.message.destinationUSER == userName then
		--We found a user
		local testA = false
		if message.user ~= userName then
			lastUser = message.message.user
			table.insert ( membersData, message.message.user )
			lobbyMatchesTable:insertRow
			{
				isCategory = false,
				rowHeight = 20,
				rowColor = { 255, 255, 255 },
				lineColor = { 220, 220, 220 },
			}
		
		else
			--We have found ourself.
		end
	end
	
end

------------------------------------------------------------------------


function t:timer ( event )
	--We are periodically clearing the tables and checking for current users.
	
	--We are clearing the TableView
	lobbyMatchesTable:deleteAllRows()
	
	--We are clearing out the table that stores our users that we have found
	for i = 0, #membersData do
		table.remove( membersData )
	end

	--We store the timer source so that we can cancel it if we want to
	--play a game with someone.
	timerSource = event.source

	--We are now sending out a request that we want lobby users to
	--respond to us.
	publishNoob	( lobbyMatches, "ping" )
	
end



------------------------------------------------------------------------

--Setup the noobHub Client
lobbyMatches = noobhub.new ( { server = serverIP; port = serverPORT; } );

--We are subscribing to the channel "lobby"
--The subscription if it can will return true or false.
canMatchMake = lobbyMatches:subscribe( {
			channel = "lobby";
			callback = matchListener;
			});


--We are setting up the timer
timer.performWithDelay ( pollTimeInSEC * 1000, t, -1 )

--Lets get the initial responces so we don't have to wait for the polling.
publishNoob	( lobbyMatches, "ping" )



--Setting up the TableView control...
scrollBoxOptions = {
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
	top = 44 ,
	height = display.contentHeight - (44 ) ,  --((45) * multiplier2) - topA - 70 ,
	width = display.contentWidth - ( 0),
	bgColor = {255,255,255},
	scrollwidth = display.contentWidth,
	scrollHeight = 100
}
	

--More TableView Stuff
lobbyMatchesTable = widget.newTableView( scrollBoxOptions )
lobbyMatchesTable:setReferencePoint (display.CenterReferencePoint)
lobbyMatchesTable.x = display.contentWidth * 0.5
