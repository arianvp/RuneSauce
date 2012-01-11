args = process.argv.splice 3
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

