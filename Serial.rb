
require 'io/console'
require 'serialport'
require 'optparse'
require 'timeout'

class Serial

	VERSION = 8.0

	# TO LOG DEBUG OUTPUT FOR THIS LIBRARY SET DEBUG_LEVEL TO -5
	def initialize( *opt , tty: nil , baudrate: 115200 , read_timeout: 1000 )

		unless opt[0].nil? ; tty = opt[0] ; end
		unless opt[1].nil? ; baudrate = opt[1] ; end
		unless opt[2].nil? ; read_timeout = opt[2] ; end

		@tty = tty ; @baudrate = baudrate ; @read_timeout = read_timeout
	end

	# Opens serial port
	# @return nil if get_menu = false , output of check_prompt if get_menu = true , or @error on failure
	def open_port( *opt , get_menu: true )

		unless opt[0].nil? ; get_menu = opt[0] ; end

		@error = []

		begin
			@uart = SerialPort.new( '/dev/tty' + @tty , @baudrate , 8 , 1 , SerialPort::NONE )

			@uart.read_timeout=@read_timeout

			if get_menu == true ; return check_prompt() ; end

		rescue Exception => error

			@error.push( error.to_s )

			puts error.inspect

			return @error
		end
	end

	# Closes serial connection
	# @return nil
	def close()

		@uart.close
	end

	# Gets drive SN
	# @return drive_sn or error
	def get_sn()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) { write( 'mfginfo__dump' ).each do |line| ; if line.include?( 'DRIVE_SN' ) ; return line.split( "\s" )[-1] ; end ; end }

		rescue Exception => error

			puts error.inspect

			return
		end
	end

	# Gets customer drive SN
	# @return customer_drive_sn or error
	def get_customer_sn()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) { write( 'mfginfo__dump' ).each do |line| ; if line.include?( 'CSN' ) ; return line.split( "\s" )[-1] ; end ; end }

		rescue Exception => error

			puts error.inspect

			return
		end
	end

	def get_vpde_ctrl_reg()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) { write( 'memory bread 0x1A50FCA0' ).each do |line| ; if line.include?( '1A50FCA0' ) ; return line.split( "\s" )[-1] ; end ; end }

		rescue Exception => error

			puts error.inspect

			return
		end
	end

	# Checks to see if assert is present

	# Checks to see if assert is present
	# @return true / false
	def check_assert()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) {

				write( 'memory assert read 0' ).each do |line|

					if line.include?( 'Size' )

						if ( line.split( ':' )[2] ).split( ',' )[0].strip.to_i == 0

							return false
						else
							return true
						end
					end
				end
			}

		rescue Exception => error

			puts error.inspect

			return
		end
	end

	# Force a drive to assert
	# @return nil or error
	def force_assert()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) { write( 'memory assert force release' ) }

		rescue Exception => error

			puts error.inspect

			return error.to_s
		end

		sleep 1
	end

	# Clears a drive assert
	# @return nil or error
	def clear_assert()

		unless @menu == 'MAIN' ; return -1 ; end

		begin
			Timeout::timeout(600) { write( 'memory assert erase 0' ) }

		rescue Exception => error

			puts error.inspect

			return error.to_s
		end
	end

	# Checks to see if in BLRE or MAIN menu
	# @return BLRE , MAIN , or error
	def check_prompt( *opt , output: false )

		unless opt[0].nil? ; output = opt[0] ; end

		@menu = -1

		@uart.flush_input

		prompt = String.new

		begin
			Timeout::timeout(600) {

				@uart.write( "\n" )

				@uart.each_char { |char|

					char.strip!

					prompt += char.to_s

					if char == '>' ; break ; end
				}
			}

		rescue Exception => error

			puts error.inspect

			return error.to_s
		end

		if	prompt[ -2..-1 ] == '0>'

			@menu = 'MAIN'

		elsif	prompt[ -1 ] == '>'

			@menu = 'BLRE'
		end

		if output == true ; print @menu.to_s ; end

		return @menu.to_s
	end

	# Writes data to serial port
	# @return data or error
	def write( *opt , cmd: nil , eot: "\u0004" )

		unless opt[0].nil? ; cmd = opt[0] ; end
		unless opt[1].nil? ; eot = opt[1] ; end

		blre_prompt = 'Snowbird FE-LX BLRE Recovery Menu'

		init_complete = 'Init complete'

		@uart.flush

		@uart.write( cmd + "\r" )

		data = String.new

		@uart.each_char { |char|

			if char == eot ; break ; end

			data += char

			if data[ -( blre_prompt.length )..-1 ].to_s == blre_prompt.to_s ; break ; end

			if data[ -( init_complete.length )..-1 ].to_s == init_complete.to_s ; break ; end

			if data[ -( eot.length )..-1 ].to_s == eot ; break ; end
		}

		begin
			# Handles 'invalid byte sequence in UTF-8' error
			if ! data.valid_encoding? ; data = data.encode( 'UTF-16be' , :invalid=>:replace , :replace=>'?' ).encode( 'UTF-8' ) ; end

			data.gsub!( "\r" , '' )

			data = data.split( "\n" )

		rescue Exception => error

			return -1
		end

		@uart.flush

		return data
	end

	# Reads the serial port output
	# @return prints output to file or STDOUT
	def read( *opt , file: nil )

		unless opt[0].nil? ; file = opt[0] ; end

		@uart.flush

		while true do

			#data = @uart.readline
			data = @uart.read
		
			if ! data.valid_encoding? ; data = data.encode( 'UTF-16be' , :invalid=>:replace , :replace=>'?' ).encode( 'UTF-8' ) ; end

			if file == ''
				print data.to_s
			else
				File.write( file , data , mode:'a' )
			end
		end

		@uart.flush
	end

	# Attempts to enter BLRE menu after a power cycle
	# @return nil or error
	def enter_blre( *opt , timeout: 60 )

		unless opt[0].nil? ; timeout = opt[0] ; end

		begin
			Timeout::timeout( timeout ) { @uart.each_char { |char| ; if char == "\u0005" ; @uart.write( 'BLRE MENU' ) ; return ; end } }

		rescue Exception => error

			puts error.inspect

			return error.to_s
		end
	end

	# Attempts to get BLRE assert dump
	# @return nil or error
	def get_files( *opt , type: nil , dir: nil , sn: nil )

		unless opt[0].nil? ; type = opt[0] ; end
		unless opt[1].nil? ; dir = opt[1] ; end
		unless opt[2].nil? ; sn = opt[2] ; end

		prompt = check_prompt()

		unless prompt.to_s == 'BLRE' ; return -1 ; end

		unless dir[ -1 ] == '/' ; dir += '/' ; end

		0.upto( 2 ) do |index|

			cmd = 'debug dump ' + type.to_s

			unless type.to_s == 'nor' || type.to_s == 'stm' ; cmd = 'debug dump assert ' + type.to_s + ' ' + index.to_s ; end

			if type.to_s == 'stm' ; cmd += ' ' + index.to_s ; end

			timeStamp = Time.now.strftime( "-%Y%m%d-%H%M%S" )

			filename = type.to_s.upcase + index.to_s + '-' + sn.to_s + timeStamp.to_s + '.bin'

			print dir.to_s + filename.to_s + ' : '

			begin
				Timeout::timeout(600) { write( cmd.to_s , 'Starting Xmodem transfer' ) }

			rescue Exception => error

				puts error.to_s.strip! + ' : -1'

				return error.to_s
			end

			@uart.flush	

			@uart.close

			cmd = 'rx ' + dir.to_s + filename.to_s + ' < /dev/tty' + @tty.to_s + ' > /dev/tty' + @tty.to_s + ' 2>/dev/null'

			rc = %x( #{ cmd } )

			puts 'OK'

			open_port()

			unless type.to_s == 'blre' ; break ; end
		end

		puts
	end

	# Reboots the drive
	# @return nil
	def reset()

		prompt = check_prompt()

		# @note Only works if you are in the BLRE MENU
		if prompt.to_s == 'BLRE' ; write( 'reset now' , 'reset' ) ; end

		# @note Only works if you are in the MAIN MENU
		if prompt.to_s == 'MAIN' ; write( 'vca warm_reboot 10' , '|' ) ; end
	end
end
