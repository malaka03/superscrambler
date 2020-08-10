-- SuperScrambler v1.0.0 - Event name scrambler for FiveM
-- by Malaka03

-- If this is set to true, it will print a warning when an unscrambled event is detected.
-- You should set this to false to improve performance once you have set everything up.
local DEBUG_WARN_UNSCRAMBLED = true

-- Add more events that you don't want scrambled here
local whitelistedEvents = {
	--system events
	playerConnecting = 1,
	playerJoining = 1,
	playerDropped = 1,
	entityCreated = 1,
	entityCreating = 1,
	entityRemoved = 1,
	onResourceListRefresh = 1,
	onServerResourceStart = 1,
	onServerResourceStop = 1,
	playerEnteredScope = 1,
	playerLeftScope = 1,
	onResourceStarting = 1,
	rconCommand = 1,
	onResourceStart = 1,
	onResourceStop = 1,
	onClientResourceStart = 1,
	onClientResourceStop = 1,
	playerSpawned = 1,
	populationPedCreating = 1,
	gameEventTriggered = 1,

	--Add more below
	--eventName = 1,
	--or
	--["eventName"] = 1,
}

-- We will also not scramble events starting with these prefixes
local whitelistedPrefixes = {
	"__cfx",
	"baseevents",
}



------------------ DON'T EDIT ANY FURTHER ------------------
local wordList = {
	"ack", "alabama", "alanine", "alaska", "alpha", "angel", "apart", "april",
	"arizona", "arkansas", "artist", "asparagus", "aspen", "august", "autumn",
	"avocado", "bacon", "bakerloo", "batman", "beer", "berlin", "beryllium",
	"black", "blossom", "blue", "bluebird", "bravo", "bulldog", "burger",
	"butter", "california", "carbon", "cardinal", "carolina", "carpet", "cat",
	"ceiling", "charlie", "chicken", "coffee", "cola", "cold", "colorado",
	"comet", "connecticut", "crazy", "cup", "dakota", "december", "delaware",
	"delta", "diet", "don", "double", "early", "earth", "east", "echo",
	"edward", "eight", "eighteen", "eleven", "emma", "enemy", "equal",
	"failed", "fanta", "fifteen", "fillet", "finch", "fish", "five", "fix",
	"floor", "florida", "football", "four", "fourteen", "foxtrot", "freddie",
	"friend", "fruit", "gee", "georgia", "glucose", "golf", "green", "grey",
	"hamper", "happy", "harry", "hawaii", "helium", "high", "hot", "hotel",
	"hydrogen", "idaho", "illinois", "india", "indigo", "ink", "iowa",
	"island", "item", "jersey", "jig", "johnny", "juliet", "july", "jupiter",
	"kansas", "kentucky", "kilo", "king", "kitten", "lactose", "lake", "lamp",
	"lemon", "leopard", "lima", "lion", "lithium", "london", "louisiana",
	"low", "magazine", "magnesium", "maine", "mango", "march", "mars",
	"maryland", "massachusetts", "may", "mexico", "michigan", "mike",
	"minnesota", "mirror", "mississippi", "missouri", "mobile", "mockingbird",
	"monkey", "montana", "moon", "mountain", "muppet", "music", "nebraska",
	"neptune", "network", "nevada", "nine", "nineteen", "nitrogen", "north",
	"november", "nuts", "october", "ohio", "oklahoma", "one", "orange",
	"oranges", "oregon", "oscar", "oven", "oxygen", "papa", "paris", "pasta",
	"pennsylvania", "pip", "pizza", "pluto", "potato", "princess", "purple",
	"quebec", "queen", "quiet", "red", "river", "robert", "robin", "romeo",
	"rugby", "sad", "salami", "saturn", "september", "seven", "seventeen",
	"shade", "sierra", "single", "sink", "six", "sixteen", "skylark", "snake",
	"social", "sodium", "solar", "south", "spaghetti", "speaker", "spring",
	"stairway", "steak", "stream", "summer", "sweet", "table", "tango", "ten",
	"tennessee", "tennis", "texas", "thirteen", "three", "timing", "triple",
	"twelve", "twenty", "two", "uncle", "undress", "uniform", "uranus", "utah",
	"vegan", "venus", "vermont", "victor", "video", "violet", "virginia",
	"washington", "west", "whiskey", "white", "william", "winner", "winter",
	"wisconsin", "wolfram", "wyoming", "xray", "yankee", "yellow", "zebra",
	"zulu"
}

local function uint32(int)
	return int & 0xFFFFFFFF
end

function Scramble(str)
	local hash = ScrambleInternal(string.lower(str))

	return
		wordList[((hash >> 16) & 0xFF) + 1].."-"..
		wordList[((hash >> 8) & 0xFF) + 1].."-"..
		wordList[((hash >> 0) & 0xFF) + 1]
end

function ScrambleInternal(str)
	local hash = 0

	for i=1,#str do
		local ascii = string.byte(str, i)
		hash = uint32(hash + ascii)
		hash = uint32(hash + (hash << 10))
		hash = uint32(hash ~ (hash >> 6))
	end

	hash = uint32(hash + (hash << 3))
	hash = uint32(hash ~ (hash >> 11))
	hash = uint32(hash + (hash << 15))
	return hash
end

-- These are all the functions which will be put through the scrambling process
local EventFunctions = {
	"AddEventHandler",
	"RegisterNetEvent",
	"RegisterServerEvent",
	"TriggerEvent",
	"TriggerServerEvent",
	"TriggerClientEvent",
}

for _, e in pairs(EventFunctions) do
	--Rename original method to _OriginalName
	_G["_"..e] = _G[e]

	_G[e] = function(name, ...)
		--Check if the prefix is whitelisted...
		local prefixExists = false
		for _, prefix in pairs(whitelistedPrefixes) do
			if string.sub(name, 1, #prefix) == prefix then
				prefixExists = true
				break
			end
		end

		--If no prefix matches and it's not a whitelisted event, we scramble it!
		local newname =
			(prefixExists or whitelistedEvents[name])
				and name
				or Scramble(name)

		--Call the original function with a either scrambled or unchanged name
		_G["_"..e](newname, ...)

		if DEBUG_WARN_UNSCRAMBLED and newname ~= name and e == "AddEventHandler" then
			local args = {...}
			_G["_"..e](name, function()
				print("^1[SuperScrambler]: ^3Unscrambled event '"..name.."' called. You should probably look into this.^7")
				-- Let it through unscrambled anyway
				_G["_"..e](name, table.unpack(args))
			end)
		end
	end
end