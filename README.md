Partly Adequate Mapvote
===
# Description
This Garry's Mod addon for the terrortown gamemode adds a comfortable way to democratically vote on maps to play for the next round.

# Features
## Playcounts
Everytime a map is played a counter will increase and be saved server sided. When voting on maps the buttons will show the number of times the map has been played on this server before.

## Favorising
Maps can be added as Favorites. To add/remove them simply click on the heart icon in the lower right corner of the map button.
Favorites are stored client sided.
There is a button to only show favorised maps. Clicking it again will toggle between the favorised only and the regular state.

## Sorting
There is a combobox in the votescreen containing 4 different sort options:
1. Most Played

	The most played maps will be listed first
2. Least Played

	The least played maps will be listed first
3. Mapname [ASC]

	Sorting by mapname in ascending order ("a" before "b")
4. Mapname [DESC]

	Sorting by mapname in descending order ("b" before "a")

## Searching
There is a textfield in the votescreen where searchterms can be inserted.
Only maps containing all letters from the searchterm in the correct order in their name will be shown.
With searchterm "ac" and mapname "abc" the map will be shown even though the letters are not adjacent.

# Configuration
The Configuration file for this addon is located in the "pam" folder in the data folder and looks like this:
```json
{
	"MapPrefixes":["ttt_"],
	"MaxMapAmount":15.0,
	"VoteLength":30.0,
	"MapsBeforeRevote":3.0
}

```

| Variable | Description | Default Value | Constraints | Examples |
| --- | --- | --- | --- | --- |
| MapPrefixes | When at least one of the listed prefixes appears in the map name it will be able to be selectable. | ["ttt_"] | Must be a String Array | When empty no maps will be selectable |
| MaxMapAmount | The amount of selectable maps | 15.0 | Must be an integer | when set to 0 no maps will be selectable / when set to 5 there will be 5 maps selectable when at least 5 maps fit at least one prefix |
| VoteLength | The length of the voting time | 30.0 | Must be a number / mustn't be negative | When set to 30 players will have 30 seconds to vote on maps |
| MapsBeforeRevote | The amount of rounds needed before a map can be played again | 3.0 | must be an integer / mustn't be negative | When set to 0 no maps will be blacklisted / When set to 1 only the current map will be blacklisted / When set to 5 the last played maps will be blacklisted |

Every time it seems no map will be playable (e.g no map has a fitting prefix) it will add the current map to the selection. This way it is assured the game will not end in a "softlock"
