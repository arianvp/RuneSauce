bigint = require 'bigint'

BIT_MASK = [0, 0x1, 0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff, 0x1ff, 0x3ff, 0x7ff, 0xfff, 0x1fff, 0x3fff, 0x7fff, 0xffff, 0x1ffff, 0x3ffff, 0x7ffff, 0xfffff, 0x1fffff, 0x3fffff, 0x7fffff, 0xffffff, 0x1ffffff, 0x3ffffff, 0x7ffffff, 0xfffffff, 0x1fffffff, 0x3fffffff, 0x7fffffff, 0xFFFFFFFF]
class BitBuffer
	constructor: (@size) ->
		@buffer = new Buffer @size
		@buffer.fill 0
		@position = 0

	writeBits: (nbits, val) ->
		bytepos = (@position >> 3) 
		bitoff = 8 - (@position & 7)
		@bitPosition += nbits
		while nbits > bitoff
			@buffer[bytepos] &= ~ BIT_MASK[bitoff]
			@buffer[bytepos++] |= (val >> (nbits - bitoff)) & BIT_MASK[bitoff]
			nbits -= bitoff
			bitoff = 8
		if nbits is bitoff
			@buffer[bytepos] &= ~BIT_MASK[bitoff]
			@buffer[bytepos] |= val & BIT_MASK[bitoff]
		else
			@buffer[bytepos] &= ~ (BIT_MASK[nbits] << (bitoff - nbits))
			@buffer[bytepos] |= (val & BIT_MASK[nbits]) << (bitoff - nbits)

	writeBit: (val) ->
		if typeof val is 'boolean'
			@writeBits 1, val ? 1 : 0 
		else
			@writeBits 1, val
	
	size: ->
		(@position + 7) >> 3

	finish: ->
		buf = @buffer.slice 0, @size()
		@position = 0
		buf


class StreamBuffer
	constructor: (@size) ->
		@buffer        = new Buffer @size
		@writePosition = 0
		@readPosition  = 0

	readByte: (opt = signed:yes) ->
		val = @buffer[@readPosition]
		@rpos = (@size + readPosition + 1) % @size
		switch opt.type
			when 'A' then val = val - 128
			when 'C' then val = -val
			when 'S' then val = 128 - val
		if opt.signed then val else val & 0xFF
	

	readBytes: (size, type) ->
		buffer = new Buffer size
		if type is 'reverse'
			offset = size
			while offset > size
				buffer[offset--] = @readByte()
		else
			while offset < size
				buffer[offset++] = @readByte()
		buffer

	readShort: (opt = {signed:yes, order:'BIG'}) ->
		val = 0
		opt.signed ?= yes
		opt.order ?= 'BIG'
		switch opt.order
			when 'BIG'
				val |= @readByte(signed:no) << 8
				val |= @readByte(signed:no,type:opt.type)
			when 'LITTLE'
				val |= @readByte(signed:no, type:opt.type)
				val |= @readByte(signed:no) << 8
		val -= 0x10000 if val > 0x07FFF and opt.signed
		val

	readMiddle: ->
		val = 0
		val |= @readByte(signed:no) << 16
		val |= @readByte(signed:no) << 8
		val |= @readByte(signed:no)
	
	readInt: (opt = signed:yes, order:'BIG') ->
		val = 0
		opt.signed ?= yes
		opt.order ?= 'BIG'
		switch opt.order
			when 'BIG'
				val |= @readByte(signed:no) << 24
				val |= @readByte(signed:no) << 16
				val |= @readByte(signed:no) << 8
				val |= @readByte(signed:no, type:opt.type)
			when 'MIDDLE'
				val |= @readByte(signed:no) << 8
				val |= @readByte(signed:no, type:opt.type)
				val |= @readByte(signed:no) << 24
				val |= @readByte(signed:no) << 16
				break
			when 'INVERSED_MIDDLE'
				val |= @readByte(signed:no) << 16
				val |= @readByte(signed:no) << 24
				val |= @readByte(signed:no, type:opt.type)
				val |= @readByte(signed:no) << 8
			when 'LITTLE'
				val |= @readByte(signed:no, type:opt.type)
				val |= @readByte(signed:no) << 8
				val |= @readByte(signed:no) << 16
				val |= @readByte(signed:no) << 24
				break
		val -= 0x100000000 if val > 0x07FFFFFF and opt.signed
		val	

	readLong: ->
		bigint.fromBuffer @readBuffer 8

	readString: ->
		s = ''
		while (c = String.fromCharCode @readByte()) isnt '\n'
			s += c
		s

	writeByte: (value, opt) ->
		type =
			if typeof opt is 'object'
				opt.type
			else if typeof opt is 'string'
				opt
			else
				throw  'Invalid opt'
		switch type
			when 'A' then value += 128
			when 'C' then value = -value
			when 'S' then value = 128 - value
		@buffer[@writePosition] = value
		@writePosition = (@size + @writePosition + 1) % @size
		@header.size++ if @header?
			

	writeShort: (value, opt) ->
		opt.order ?= 'BIG'
		switch opt.order
			when 'BIG'
				@writeByte(value >> 8)
				@writeByte(value, type:opt.type)
			when 'LITTLE'
				@writeByte(value, type:opt.type)
				@writeByte(value >> 8)

	writeMiddle: (value, type) ->

	writeInt:(value, opt = order:'BIG') ->
		opt.order ?= 'BIG'
		switch opt.order
			when 'BIG'
				@writeByte(value >> 24)
				@writeByte(value >> 16)
				@writeByte(value >> 8)
				@writeByte(value, type:opt.type)
			when 'MIDDLE'
				@writeByte(value >> 8)
				@writeByte(value, type:opt.type)
				@writeByte(value >> 24)
				@writeByte(value >> 16)
			when 'INVERSED_MIDDLE'
				@writeByte(value >> 16)
				@writeByte(value >> 24)
				@writeByte(value, type:opt.type)
				@writeByte(value >> 8)
			when 'LITTLE'
				@writeByte(value, type:opt.type)
				@writeByte(value >> 8)
				@writeByte(value >> 16)
				@writeByte(value >> 24)

	writeLong: (value, type) ->

	writeBytes: (value, type) ->
		@writeByte b for b in value
	
	writeHeader: (header) ->
		@writeByte header if typeof header is 'number'
		if typeof header is 'object'
			@writeByte header.opcode
			header.writePosition = @writePosition
			switch header.type
				when 'byte'  then @writeByte  0
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

	available: -> @writePosition - @readPosition
	


