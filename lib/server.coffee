_ = require 'underscore'
args = process.argv.splice 3

verbose = no
address =
	if args[0]?
		args[0]
	else
		'0.0.0.0'
port =
	if args[1]?
		parseInt args[1]
	else
		43594
cycleRate =
	if args[2]?
		parseInt args[2]
	else
		600

players = new Array 2048
accept = (c) ->
cycle = ->


if verbose
	cycle =_.wrap cycle, (_cycle) ->
		console.time 'cycle time'
		_cycle()
		console.timeEnd 'cycle time'
	accept = _.wrap accept, (_accept, c) ->
		_accept c
		console.log "Accepted #{c.address()}."

