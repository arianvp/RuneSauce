class BitBuffer
	constructor: (@size) ->
		@buffer = new Buffer @size


class StreamBuffer
	constructor: (@size) ->
		@buffer = new Buffer @size

	writeByte: (value, type) ->

	writeShort: (value, type) ->

	writeMiddle: (value, type) ->

	writeInt: (value, type) ->

	writeLong: (value, type) ->

	writeBytes: (value, type) ->

	writeHeader: (header) ->
		@writeByte header if typeof header is 'number'
		if typeof header is 'object'
			@writeByte header.opcode
			header.writePosition = @writePosition
			switch header.type
				when 'byte' then @writeByte 0
				when 'short' then @writeShort 0
				else
					throw 'Invalid header type'
			header.length = 0
			@header = header

	finishHeader:  ->
		if header.type is 'byte'
			@buffer[@header.writePosition] = @header.length
		if header.type is 'short'
			@buffer[@header.writePosition] = @header.length << 8
			@buffer[@header.writePosition + 1] = @header.length
		@header = undefined

	
	readByte: (type) ->
		
	readShort: (type) ->

	readMiddle: (type) ->

	readInt: (type) ->

	readLong: (type) ->

	readBytes: (size, type) ->

	


