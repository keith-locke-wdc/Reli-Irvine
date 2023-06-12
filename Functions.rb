
class Functions

	VERSION = 8.41

	# TO LOG DEBUG OUTPUT FOR THIS LIBRARY SET DEBUG_LEVEL TO -1
	def initialize()

		text = 'INFO  : INITIALIZE LIBS      : '

		timeStamp = Time.now.strftime( "%Y-%m-%d %H:%M:%S : --- --- : " )

		$angel.log.write_file( $test_info.home_directory.to_s + 'script-trace.log' , timeStamp + text , 'a' )

		$LOAD_PATH.unshift( '/home/everest/angel_libs/' , '/home/everest/angel_libs/sbdi/' , '/file-server/libs/gems/' )

		require 'syslog/logger'
		require 'io/console'
		require 'file/tail'
		require 'xmlsimple'
		require 'net/scp'
		require 'net/ssh'
		require 'ps-ruby'
		require 'socket'
		require 'json'
		require 'find'
		require 'time'
		require 'csv'
		require 'zip'

		@test_info = {

			:periodic_temp_checking_interval => 60000 ,

			:plx_temp_limit		=> 80 ,

			:slot_id		=> $test_info.chamber_id + '-' + ( sprintf "%02d" , $test_info.client ) + '-' + ( sprintf "%02d" , $test_info.port ) ,
			:data_pattern		=> AngelCore::DataPattern_Random ,
			:script_name		=> $test_info.start_script.to_s.tr( '_' , '-' ).upcase ,
			:script_version		=> nil ,
			:launch_directory	=> Dir.pwd.to_s + '/' ,
			:start_time		=> Time.now ,
			:mpsmin			=> ( %x( #{ 'getconf PAGE_SIZE' } ) ).chomp.to_i , # MPSMIN = minimum memory page size (CAP.MPSMIN)
			:debug_level		=> 0 ,
			:drive_temp_limit	=> 80 ,
			:timeout_wait_time	=> 90000 ,
			:timeout_general	=> 90000 ,
			:timeout_por		=> 180000 ,
			:timeout_fwdl		=> 180000 ,
			:enable_power_control	=> true ,
			:enable_chamber_control	=> true ,
			:enable_sync_control	=> true ,
			:nand_limit		=> 100.00 ,
			:nand_limit_action	=> 'read-only' ,
			:test_mode		=> 'read-write' ,
			:clear_assert		=> false ,
			:test_phase		=> 'DEBUG' ,
			:enable_link_check	=> true ,
			:sync_counter		=> 1 ,
			:power_cycle_count	=> 0 ,
			:ungraceful_power_cycle_count => 0 ,
			:drive_log_counter	=> 0 ,
			:functions_buffer_id	=> 2 ,
			:write_buffer_id	=> 1 ,
			:read_buffer_id		=> 0 ,
			:precondition		=> false ,
			:baseline		=> false ,
			:warning_counter	=> 0 ,
			:warnings		=> {} ,
			:enable_compare		=> true ,
			:trace			=> 'NA' ,
			:port_configuration	=> nil ,
			:log_directory		=> nil ,
			:syslog			=> Syslog::Logger.new ,
			:chamber_set_temp_info	=> nil ,
			:enable_bad_fh_retries	=> true ,
			:device_open_retries	=> 3 ,
			:get_eye_diagram	=> true ,
			:selected_namespace	=> 1 ,
			:tmm			=> nil ,
			:tmm_check_error_action	=> 'fail' ,
			:queue_depth		=> 0 ,
			:enable_parametrics	=> true ,
			:enable_uart		=> true ,
			:uart_error_action	=> 'ignore' ,
			:enable_smart_checking	=> true ,
			:in_precheck		=> true ,
			:enable_queuing		=> true ,
			:status			=> 'testing',
			:device_handle_error	=> false ,
			:angel_trace_depth	=> 100 ,
			:write_drive_log	=> true ,
			:chamber_temp_update_interval => 60 ,
			:enable_inspector_uploads => false ,
			:io_tracker		=> {} ,
			:firmware_updated	=> false ,
			:invalid_eyecatcher	=> 0 ,
			:check_eyecatcher	=> false ,
			:enable_io_size_warnings => false ,
			:inspector_mount_dir	=> '/home/everest/angel_inspector_csv/' ,
			:enable_tdds		=> true ,
			:enable_database	=> true ,
			:local_fw_repo		=> '/home/everest/angel_fw_repo/' ,
		}

		@sql_info = {

			:sql_ip			=> '10.6.178.247' ,
			:sql_username		=> 'root' ,
			:sql_password		=> 'root-wdcfs01' ,
			:sql_status_database	=> 'DEBUG' ,
			:sql_status_table	=> 'STATUS' ,
			:record_id		=> nil ,
			:number_of_fields	=> nil ,
		}

		@drive_info = {

			:drive_responsive	=> true ,
			:customer		=> 'UNKNOWN' ,
			:assert_present		=> 'UNKNOWN' ,
			:data_current		=> true ,
			:last_power_on		=> Time.now ,
			:gbb_count		=> -1 ,
			:nand_usage		=> -1 ,
			:device_id		=> nil ,
			:bus_path		=> [] ,
			:bus_id			=> [] ,
			:ctrl_id		=> [] ,
			:tmm_version		=> 'NA' ,
			:nn			=> 0 ,
			:name_space_id_list	=> [] ,
			:current_link_speed	=> [] ,
			:current_link_width	=> [] ,
			:parametric_offsets	=> {} ,
			:ddr_single_bit_error_count => 0 ,
			:sram_single_bit_error_count => 0 ,
			:zoned_namespace	=> nil ,
			:conv_namespace		=> nil ,
			:eyecatcher		=> nil ,
			:feature_set		=> nil ,
			:drive_writes_per_day	=> [] ,
		}

		@test_logs = {

			:shack_builder_e6	=> nil ,
			:syslog			=> nil ,
			:inspector		=> nil ,
			:uart			=> [] ,
			:post			=> [] ,
		}

		@error_info = {

			:pending_failure_info	=> 'NA' ,
			:script_failure_info	=> 'NA' ,
			:power_failure_info	=> 'NA' ,
			:caller			=> 'NA' ,
		}

		@uart_info = {

			:tty			=> nil ,
			:open			=> false ,
		}

		@inspector_info = {

			:instance_counter	=> 0 ,
			:log_pages		=> { '0x02' => {} , '0x03' => {} , '0xD0' => {} , '0x3E' => {} , '0xC0_MSFT' => {} , '0xC1_MSFT' => {} , '0xC2_MSFT' => {} } ,
			:io_tracker		=> {}
		}

		@external_data_tables = {

			:customer_id_table => {} ,
			:fw_version_decoder => {} ,
		}

		@namespace_info = {}

		@zone_info = {}

		@tester_info = {}

		@angel_versions = {}

		# clear buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		$angel.log.write_file( $test_info.home_directory.to_s + 'script-trace.log' , 'FUNCTIONS ' , 'a' )

		unless @tester_info[ :test_site ] == 'IR'

			@test_info[ :enable_database ] = false

			@test_info[ :enable_uart ] = false
		end
	end

	# Performs Precheck setup for PTL libs
	# @return 1 or -1 on error
	def precheck( options = {} )

		minimum_precheck_version = 12.0

		@test_info[ :precheck_version ] = options[ :precheck_version ].to_s

		if @test_info[ :precheck_version ].to_f < minimum_precheck_version.to_f

			f_log( [ 'ERROR' , 'DOWN REV PRECHECK.RB DETECTED ( ' + @test_info[ :precheck_version ].to_s + ' )' , 'MINIMUM REQUIRED PRECHECK.RB VERSION IS ' + minimum_precheck_version.to_s + "\n" ] ) 

			return( -1 )
		else
			f_log( [ 'INFO' , 'PRECHECK VERSION' , @test_info[ :precheck_version ].to_s + "\n" ] )
		end

		# Angel defaults to 8 digit SN due to productions system limitations
		$angel.enable_long_serial_number

		# If set to false will get current link rate info without a power cycle
		# If set to true will not get current link rate info until a power cycle is performed
		$test_status.simple_por = false

		# Retrives Current Link Rate Data Without Needing A Power Cycle ( $test_status.simple_por must be set to false )
		$angel.get_link_rate_after_power_on

		# Creates $test_info.home_directory.to_s + 'error_condition_handler.yaml'
		create_error_condition_file()

		# Creates a ruby script in the launch directory named angel_error_handler.rb
		# This script is called when an error occurs and re-directs angel to the post_script_handler method
		$angel.log.write_file( $test_info.home_directory.to_s + 'angel_error_handler.rb' , '$ANGEL.post_script_handler( "failed" )' , 'w' )

		if File.size( $test_info.home_directory.to_s + 'angel_error_handler.rb' ) == 0 ; return(-1) ; end

		# Creates a ruby script in the launch directory named angel_abort_handler.rb
		# This script is called when the test is aborted and re-directs angel to the post_script_handler method
		$angel.log.write_file( $test_info.home_directory.to_s + 'angel_abort_handler.rb' , '$ANGEL.post_script_handler( "aborted" )' , 'w' )

		if File.size( $test_info.home_directory.to_s + 'angel_abort_handler.rb' ) == 0 ; return(-1) ; end

		# This tells Angel to call the user script angel_abort_handler.rb when the test is aborted
		$angel.user_abort_handling_script = $test_info.home_directory.to_s + 'angel_abort_handler.rb'

		launch_script = @test_info[ :launch_directory ] + $test_info.start_script.to_s + '.rb'

		FileUtils.copy( launch_script.to_s , $test_info.home_directory.to_s )

		rc = FileUtils.compare_file( launch_script.to_s , $test_info.home_directory.to_s + ( launch_script.to_s ).split( '/' )[-1].to_s )

		unless rc == true ; return(-1) ; end

		script_version = begin File.readlines( $test_info.home_directory.to_s + $test_info.start_script.to_s + '.rb' ).grep( /VERSION/ ) ; rescue ; end

		unless script_version.length == 0

			script_version = script_version[0].chomp

			script_version = script_version.chomp.split( / = / )[-1]
		else
			script_version = nil
		end

		display_tester_info() 

		@test_info[ :script_version ] = script_version

		if _get_test_options( options: options ) == -1 ; return( -1 ) ; end

		if @tester_info[ :tester_type ] == 'G10' || @tester_info[ :tester_type ] == 'D16' ; @test_info[ :enable_chamber_control ] = false ; end

		@test_info[ :angel_core ] = $test_info.core_version.to_s

		if @test_info[ :enable_tdds ] == true

			# SBDI LIB FOR TDDs
			if File.file?( '/home/everest/angel_libs/sbdi/' + @test_info[ :angel_core ] + '/sbdi_angel.so' )

				require '/home/everest/angel_libs/sbdi/' + @test_info[ :angel_core ] + '/sbdi_angel'
			else
				_warning_counter( category: 'sbdi_library_not_found' , data: 'SBDI LIBS NOT FOUND ( ' + @test_info[ :angel_core ].to_s + ' ) : TDDs ARE DISABLED' )

				@test_info[ :enable_tdds ] = false
			end
		end

		# Populates @drive_info[ :bus_path ] , @drive_info[ :bus_id ] , @drive_info[ :device_id ]
		_get_bus_path()

		_display_test_options()

		display_power_info()

		assert( func: 'clear' , log: true )

                @test_info[ :angel_package ] = ( read_file( file: '/home/everest/angel_host/bin/package_ver.txt' ) )[0].to_s

		get_drive_info( log: true , dump_logs: true , get_e6: true )

		get_eye_diagram()

		link_check()

		# Zeroize angel counters
		$test_status.operation_count = 0
		$test_status.write_bytes = 0
		$test_status.read_bytes = 0

		display_drive_info()

		if @test_info[ :enable_uart ] == true

			begin
				FileUtils.copy( '/home/everest/angel_rbin/serial.rb' , $test_info.home_directory )

				FileUtils.copy( '/home/everest/angel_rbin/serial-port-discovery.rb' , $test_info.home_directory )

			rescue StandardError => error

				@test_info[ :enable_uart ] = false

				if	@test_info[ :uart_error_action ].to_s == 'warn'

					_warning_counter( category: 'file_copy_failure' , data: error.inspect )
				else
					force_failure( category: 'file_copy_failure' , data: error.inspect )
				end
			end

			uart_get_port() ; uart_kill() ; uart_tail()
		end

		if @test_info[ :enable_database ] == true

			begin
				FileUtils.copy( '/home/everest/angel_rbin/write-to-sql.rb' , $test_info.home_directory )

			rescue StandardError => error

				@test_info[ :enable_database ] = false

				_warning_counter( category: 'file_copy_failure' , data: error.to_s )
			end

			if @test_info[ :test_phase ] == 'DEBUG'

				@sql_info[ :sql_status_database ] = 'DEBUG'
			else 
				@sql_info[ :sql_status_database ] = @drive_info[ :product_family ].upcase
			end

			database = @sql_info[ :sql_status_database ].to_s
		else
			database = 'NA'
		end

		text = @test_info[ :script_name ] ; unless @test_info[ :script_version ] == nil ; text += ' ' + @test_info[ :script_version ] ; end

		f_log( [ 'INFO' , 'TEST INFO' , @test_info[ :slot_id ].to_s , text , @test_info[ :test_phase ].to_s , database.to_s + "\n" ] )

		write_drive_log( data: text , log: true )

		_dump_test_variables()

		_sql_update_stale_database_records()

		_precheck_thread()

		_update_web_data_file()

		if @test_info[ :warning_counter ] > 0 ; f_log( [ 'INFO' , 'WARNINGS' , @test_info[ :warnings ].keys.join(',').to_s ] ) ; log ; end

		@test_info[ :in_precheck ] = false

		return( 1 )
	end

	# Debug log for checking various issues
	def d_log( *opt , data: nil , file: 'script-trace.log' , dir: $test_info.home_directory , option: 'a' )

		unless opt[0].nil? ; data = opt[0] ; end
		unless opt[1].nil? ; file = opt[2] ; end
		unless opt[2].nil? ; dir = opt[3] ; end
		unless opt[3].nil? ; option = opt[4] ; end

		unless dir[-1] == '/' ; dir += '/' ; end

		$angel.log.write_file( dir.to_s + file.to_s , 'DEBUG : ' + data.to_s + "\n" , 'a' )
	end

	# Writes 'data' to file
	# option : a = append , w = creates new file
	def log( *opt , data: nil , debug_level: 0 , file: 'script-trace.log' , dir: $test_info.home_directory , option: 'a' )

		unless opt[0].nil? ; data = opt[0] ; end
		unless opt[1].nil? ; debug_level = opt[1] ; end
		unless opt[2].nil? ; file = opt[2] ; end
		unless opt[3].nil? ; dir = opt[3] ; end
		unless opt[4].nil? ; option = opt[4] ; end

		if debug_level.to_i != 0 && debug_level.to_i != @test_info[ :debug_level ].to_i ; return ; end

		if data.nil?

			$angel.log.write_file( dir + file , "\n" , option )

			return
		end

		if data.start_with?( "\n" )

			$angel.log.write_file( dir + file , "\n" , option )

			data.tr!( "\n" , '' )
		end

		unless data.is_a? String ; data = data.to_s ; end

		timeStamp = Time.now.strftime( "%Y-%m-%d %H:%M:%S" )

		drive_temp = _get_core_log_temps()

		chamber_temp = _get_chamber_temp()

		$angel.log.write_file( dir + file , timeStamp + ' : ' + ( "%3s" % chamber_temp.to_s ) + ' ' + ( "%3s" % ( drive_temp.to_s ) ) + ' : ' + data + "\n" , option )
	end

	# Formats text then passes text to Functions::log
	def f_log( *opt , data: [] , debug_level: 0 )

		unless opt[0].nil? ; data = opt[0] ; end
		unless opt[1].nil? ; debug_level = opt[1] ; end

		if data[0].start_with?( "\n" ) ; log( nil , debug_level ) ; end

		data[0].tr!( "\n" , '' )

		formatted_message = ( data[0] ).ljust(5)

		1.upto( ( data.length - 1 ) ) do |x| ; formatted_message += ' : ' + data[x].ljust(20) ; end

		log( data: formatted_message , debug_level: debug_level )
	end

	# Sets the debug output level
	def debug_level( *opt , level: nil )

		unless opt[0].nil? ; level = opt[0] ; end

		if level != nil ; @test_info[ :debug_level ] = level ; end

		return @test_info[ :debug_level ]
	end

	def warn( category: nil , data: nil )

		_warning_counter( category: category , data: data )
	end

	# Handling function for forced errors
	def force_failure( category: nil , data: 'NA' )

		@error_info[ :caller ] = ( caller[0] ).split( ':' )[0..1].join( ' : ' ).to_s

		# Handling for failures in PostScriptHandler
		unless @test_info[ :status ] == 'testing'

			if @test_info[ :warning_counter ] == 0 && @test_info[ :status ] == 'passed' ; _warning_counter( category: category , data: caller[0].to_s ) ; end

			@drive_info[ :data_current ] = false

			raise 'post-script-error'
		end

		@error_info[ :script_failure_info ] = @error_info[ :pending_failure_info ]

		@error_info[ :script_failure_info ] = data.to_s

		@test_info[ :status ] = 'failed'

		$angel.force_error( category )

		_warning_counter( category: 'unhandled_failure_occured' , data: category.inspect + ' : ' + data.inspect )
	end

	# Sets or gets current write buffer data pattern
	def data_pattern( pattern: nil , log: false )

		queue_depth = -1

		unless pattern == nil

			if log == true

				case pattern
				when 0	; pattern_text = 'AngelCore::DataPattern_Random'
				when 1	; pattern_text = 'AngelCore::DataPattern_Increment'
				when 2	; pattern_text = 'AngelCore::DataPattern_Decrement'
				else	; pattern_text = pattern.to_s
				end

				f_log( [ 'INFO' , 'SET DATA PATTERN' , pattern_text.to_s + "\n" ] )
			end

			# Per Mike :  The best practice is to disable queuing when changing data patterns.
                	if @test_info[ :queue_depth ] > 0 ; queue_depth = @test_info[ :queue_depth ] ; disable_queuing( log: false ) ; end

			@test_info[ :data_pattern ] = pattern

			if pattern == AngelCore::DataPattern_Random || pattern == AngelCore::DataPattern_Increment || pattern == AngelCore::DataPattern_Decrement

				# set data pattern to write / read
				rc = $angel.buffer.set_pattern( @test_info[ :write_buffer_id ] , @test_info[ :data_pattern ] )

				# Spec says should return 0 or -1 , but appears to return nil
				unless rc == nil ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end

				# Needed to repeat the buffer contents on a sector boundary to prevent miscompares
				# Needs to be issued every time the data pattern changes
				$angel.buffer.set_repeated_buffer( @test_info[ :write_buffer_id ] , $drive_info.bytes_per_sector )
			else
				$angel.buffer.set_repeated_value( @test_info[ :write_buffer_id ] , pattern.hex , ( pattern.length / 2 ) )

				# Needed to repeat the buffer contents on a sector boundary to prevent miscompares
				# Needs to be issued every time the data pattern changes
				$angel.buffer.set_repeated_buffer( @test_info[ :write_buffer_id ] , $drive_info.bytes_per_sector )
			end

			if queue_depth > 0 ; enable_queuing( queue_depth: queue_depth , log: false ) ; end
		end

		return @test_info[ :data_pattern ]
	end

	# Turns on drive power with the user defined voltage
	# Calls Functions::get_drive_info
	# Calls Functions::link_check
	# ttr ( time to ready ) option is time to wait in seconds after the dev node has been detected by angel
	def power_on( pwr_5v: 3.3 , pwr_12v: 12.0 , ttr: 0 , ungraceful: false )

		unless @test_info[ :enable_power_control ] == true ; return ; end

		if $test_info.genesis_hd_config.to_s.upcase == 'M.2' ; pwr_12v = 0.0 ; end

		@test_info[ :power_cycle_count ] += 1

		if ungraceful == true ; @test_info[ :ungraceful_power_cycle_count ] += 1 ; end

		f_log( [ 'FUNC' , 'POWER ON (' + @test_info[ :power_cycle_count ].to_s + '-' + @test_info[ :ungraceful_power_cycle_count ].to_s + ')' , pwr_5v.to_s + ' , ' + pwr_12v.to_s + "\n" ] )

		# Sets the angel 'wait time' timeout > than the power cycle sleep time
		if ( ttr * 1000 ) >= @test_info[ :timeout_wait_time ] ; $angel.set_timeout( 'wait time' , ( ttr * 1000 * 1.5 ).to_i ) ; end

		rc = -1 ; no_wait = true

		# power_on(volt5, volt12, no_wait = false) ⇒ Integer
		# no_wait (Boolean) (defaults to: false) — if true, client doesn't report waiting for spin up status and continue
		rc = $angel.power_on( pwr_5v , pwr_12v , no_wait )

		unless rc == 0 ; force_failure( category: 'por_timeout' ) ; end

		$angel.wait( 'Seconds' , ttr.to_i )

		if $angel.get_timeout( 'wait time' ) != @test_info[ :timeout_wait_time ] ; $angel.set_timeout( 'wait time' , @test_info[ :timeout_wait_time ].to_i ) ; end

		@drive_info[ :last_power_on ] = Time.now

		if @test_info[ :port_configuration ] == '2x2'

			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s , $angel.get_device_name( 'port_b' ).to_s ]
		else
			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s ]
		end

		skip_error_handling = $test_status.skip_error_handling

		if $test_status.skip_error_handling == true && @test_info[ :status ] == 'testing' ; $test_status.skip_error_handling = false ; end

		# get_drive_info( log = false , dump_logs = false , get_e6 = false )
		get_drive_info( log: false , dump_logs: true , get_e6: false )

		f_log( [ 'INFO' , 'unsafe_shutdowns'.upcase , @drive_info[ :unsafe_shutdowns ].to_s + "\n" ] , -1 )

		write_drive_log( data: 'POWER ON' , log: false )

		link_check()

		select_namespace( nsid: @test_info[ :selected_namespace ] , log: false , force: true )

		$test_status.skip_error_handling = skip_error_handling
	end

	# Turns off drive power
	# Calls Functions::link_check() prior to power off
	# Calls Functions::assert('check') prior to power off
	# duration_off is only used when performing unsafe power off
	def power_off( unsafe: false , check_status: true , duration_off: 10 )

		unless @test_info[ :enable_power_control ] == true ; return ; end

		unless check_status == false

			skip_error_handling = $test_status.skip_error_handling

			if $test_status.skip_error_handling == true && @test_info[ :status ] == 'testing' ; $test_status.skip_error_handling = false ; end

			link_check()

			assert( func: 'check' , log: false )

			if @drive_info[ :assert_present ] == true ; force_failure( category: 'assert_detected' , data: 'ASSERT DETECTED' ) ; end

			$test_status.skip_error_handling = skip_error_handling

			if unsafe == true ; write_drive_log( data: 'POWER OFF ( UNSAFE )' ) ; else ; write_drive_log( data: 'POWER OFF' ) ; end
		end

		if @test_info[ :port_configuration ] == '1x4' || @test_info[ :port_configuration ] == '1x8'

			ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3]

			if unsafe == true

				f_log( [ 'FUNC' , 'POWER OFF ( UNSAFE )' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s , 'SSD LOG ID ' + @test_info[ :drive_log_counter ].to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'POWER OFF' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s , 'SSD LOG ID ' + @test_info[ :drive_log_counter ].to_s + "\n" ] )
			end

		elsif @test_info[ :port_configuration ] == '2x2'

			ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3 ]
			ctrl_id_b = ( $angel.get_device_name( 'port_b' ).to_s )[ 0..-3 ]

			if unsafe == true

				f_log( [ 'FUNC' , 'POWER OFF ( UNSAFE )' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s + ' & ' + ctrl_id_b.to_s + ' : ' + @drive_info[ :bus_id ][1].to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'POWER OFF' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s + ' & ' + ctrl_id_b.to_s + ' : ' + @drive_info[ :bus_id ][1].to_s + "\n" ] )
			end
		end

		rc = $angel.power_off( unsafe )

		unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end

		if unsafe == true

			rc = $angel.nvme_device_cleanup

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end

			@test_info[ :unsafe_pc_occurred ] == true
		end
	end

	# Performs a drive power cycle
	# 'sleep' option is the time in seconds to wait between power off & power on
	# the wait option is time to wait in seconds after the dev node has been detected by angel
	def power_cycle( pwr_5v: 3.3 , pwr_12v: 12.0 , sleep: 10 , ttr: 0 , sync: false , unsafe: false )

		unless @test_info[ :enable_power_control ] == true ; return ; end

		power_off( unsafe: unsafe , duration_off: sleep )

		# Sets the angel 'wait time' timeout > than the power cycle sleep time
		if ( sleep * 1000 ) >= @test_info[ :timeout_wait_time ] ; $angel.set_timeout( 'wait time' , ( sleep * 1000 * 1.5 ).to_i ) ; end

		$angel.wait( 'Seconds' , sleep.to_i )

		if $angel.get_timeout( 'wait time' ) != @test_info[ :timeout_wait_time ] ; $angel.set_timeout( 'wait time' , @test_info[ :timeout_wait_time ].to_i ) ; end

		if sync == true ; sync( type: 'drives' ) ; end

		power_on( pwr_5v: pwr_5v , pwr_12v: pwr_12v , ttr: ttr , ungraceful: unsafe )
	end

	def remove_device()

		if @test_info[ :port_configuration ] == '1x4' || @test_info[ :port_configuration ] == '1x8'

			ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3]

			f_log( [ 'FUNC' , 'REMOVE DEVICE' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s , 'SSD LOG ID ' + @test_info[ :drive_log_counter ].to_s + "\n" ] )

		elsif @test_info[ :port_configuration ] == '2x2'

			ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3 ]
			ctrl_id_b = ( $angel.get_device_name( 'port_b' ).to_s )[ 0..-3 ]

			f_log( [ 'FUNC' , 'REMOVE DEVICE' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s + ' & ' + ctrl_id_b.to_s + ' : ' + @drive_info[ :bus_id ][1].to_s + "\n" ] )
		end

		rc = $angel.nvme_device_cleanup()

		unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end
	end

	# Performs a check to ensure drive link rate and link width are properly detected
	# Issues an 'incorrect_link_rate' failure to angel if link check fails
	def link_check()

		if @drive_info[ :current_link_width ][0] != @drive_info[ :max_link_width ][0]

			if @test_info[ :enable_link_check ] == true

				force_failure( category: 'incorrect_link_width' , data: @drive_info[ :max_link_width ][0].to_s + ' : ' + @drive_info[ :current_link_width ][0].to_s )
			else
				_warning_counter( category: 'incorrect_link_width' , data: 'INCORRECT LINK WIDTH : PORT A : ' + @drive_info[ :max_link_width ][0].to_s + ' : ' + @drive_info[ :current_link_width ][0].to_s )
			end
		end

		if @drive_info[ :current_link_speed ][0] != @drive_info[ :max_link_speed ][0] && @tester_info[ :pci_gen ] != @drive_info[ :current_link_speed ][0]

			if @test_info[ :enable_link_check ] == true

				force_failure( category: 'incorrect_link_speed' , data: @drive_info[ :max_link_speed ][0].to_s + ' : ' + @drive_info[ :current_link_speed ][0].to_s )
			else
				_warning_counter( category: 'incorrect_link_speed' , data: 'INCORRECT LINK SPEED : PORT A : ' + @drive_info[ :max_link_speed ][0].to_s + ' : ' + @drive_info[ :current_link_speed ][0].to_s )
			end
		end

		if @test_info[ :port_configuration ] == '2x2' && @drive_info[ :current_link_width ][1] != @drive_info[ :max_link_width ][1]

			if @test_info[ :enable_link_check ] == true

				force_failure( category: 'incorrect_link_width' , data: @drive_info[ :max_link_width ][1].to_s + ' : ' + @drive_info[ :current_link_width ][1].to_s )
			else
				_warning_counter( category: 'incorrect_link_width' , data: 'INCORRECT LINK WIDTH : PORT B : ' + @drive_info[ :max_link_width ][1].to_s + ' : ' + @drive_info[ :current_link_width ][1].to_s )
			end
		end

		if @test_info[ :port_configuration ] == '2x2' && @drive_info[ :current_link_speed ][1] != @drive_info[ :max_link_speed ][1] && @tester_info[ :pci_gen ] != @drive_info[ :current_link_speed ][1]

			if @test_info[ :enable_link_check ] == true

				force_failure( category: 'incorrect_link_speed' , data: @drive_info[ :max_link_speed ][1].to_s + ' : ' + @drive_info[ :current_link_speed ][1].to_s )
			else
				_warning_counter( category: 'incorrect_link_speed' , data: 'INCORRECT LINK SPEED : PORT B : ' + @drive_info[ :max_link_speed ][1].to_s + ' : ' + @drive_info[ :current_link_speed ][1].to_s )
			end
		end
	end

	# checks or clears device assert
	# valid options are 'check' or 'clear'
	def assert( func: 'check' , log: true )

		if func == 'clear' && @test_info[ :clear_assert ] == false ; return ; end

		@drive_info[ :assert_present ] = 'UNKNOWN'

		@error_info[ :pending_failure_info ] = func.to_s + ' ' + __method__.to_s

		@drive_info[ :data_current ] = false

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		if func == 'check'

			get_log_page_C2h( log: false , dump_logs: false )

			if	@drive_info[ :assert_present ] == true

				text = 'ASSERT DETECTED'

			elsif	@drive_info[ :assert_present ] == false

				text = 'NO ASSERT DETECTED'
			end

			if log == true || @drive_info[ :assert_present ] == true ; f_log( [ 'FUNC' , 'CHECK ASSERT' , text.to_s.upcase + "\n" ] ) ; end

		elsif func == 'clear'

			unless log == false ; f_log( [ 'FUNC' , 'CLEAR ASSERT' + "\n" ] ) ; end

			rc = $angel.nvme_custom_command( 0xD8 , 0 , 0 , 0 , 0x0503 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 0 )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: func.to_s + ' assert : ' + rc.to_s ) ; end

			unless $test_status.current_status.to_s.downcase.include?( 'precheck' ) ; get_log_page_C2h( log: false , dump_logs: false ) ; end
		end

		@drive_info[ :data_current ] = true

		@error_info[ :pending_failure_info ] = 'NA'
	end

	# Retrives the drive event log using NVME custom command with embedded diagnostic commands
	def get_event_log( log: false )

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_EVENTLOG_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true ; f_log( [ 'FUNC' , 'GET DATA' , 'EVENTLOG' , filename.to_s ] ) ; log() ; end

		_sbdi( filename: filename , data_source: 'eventlog' )
	end

	# Retrives parametric data ( 3E ) using NVME custom command with embedded diagnostic commands
	# Populates @drive_info[ :gbb_count ] , @drive_info[ :nand_usage ]
	def get_parametric_data( log: false )

		unless @test_info[ :enable_parametrics ] == true ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		if @drive_info[ :product_architecture ] == 'VAIL'

			filename = get_e6( log: log , mode: '3E' )

			_decode_vail_3e( file: filename )
		else
			filename = _decode_snowbird_3e( log: log )
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true

		_inspector_csv()

		unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
	end

	# Will truncate the message to 32 bytes
	# Drive event log will be marked with 'DIAG MARK'
	def write_drive_log( data: nil , log: false )

		unless @test_info[ :write_drive_log ] == true ; return ; end

		@error_info[ :pending_failure_info ] = __method__.to_s

		# EPOCH in Hex
		@test_info[ :drive_log_counter ] = Time.now.to_i.to_s(16).upcase

		data = @test_info[ :drive_log_counter ].to_s + ' ' + data.to_s

		if data.bytesize > 32

			f_log( [ 'WARN' , 'DATA SIZE' , 'LIMIT EXCEEDED' , 'DATA TRUNCATED' ] )

			loop do ; data.chop! ; if data.bytesize <= 32 ; break ; end ; end
		end

		if log == true ; f_log( [ 'FUNC' , 'WRITE SSD LOG' , data.to_s + "\n" ] ) ; end

		# Fill TX buffer arrays with 512 bytes of 0x00
		tx_buffer_data = Array.new( 512 , 0x00 )

		if @drive_info[ :product_architecture ] == 'VAIL'

			tx_buffer_data[ 0x00 .. 0x03 ] = [ 0x1E , 0xAB , 0x5E , 0xBA ]

			tx_buffer_data[ 0x40 ] = 0x4
			tx_buffer_data[ 0x44 ] = 0x01
			tx_buffer_data[ 0x48 ] = 0xF2
			tx_buffer_data[ 0x50 ] = 0x20
			tx_buffer_data[ 0x54 ] = 0x20
			tx_buffer_data[ 0x60 ] = 0x01
		else
			tx_buffer_data[ 0x00 .. 0x03 ] = [ 0x1E , 0xAB , 0x1D , 0xF0 ]
			tx_buffer_data[ 0x20 .. 0x23 ] = [ 0x11 , 0xBA , 0x5E , 0xBA ]

			tx_buffer_data[ 0x40 ] = 0x02
			tx_buffer_data[ 0x44 ] = 0x01
			tx_buffer_data[ 0x48 ] = 0xF2

			tx_buffer_data[ 0x50 ] = 0x20
			tx_buffer_data[ 0x54 ] = 0x20
			tx_buffer_data[ 0x60 ] = 0x01
		end

		offset = 0x200

		# Convert user message string into byte array
		data.each_byte.map{ |byte| tx_buffer_data[ offset ] = byte ; offset += 0x01 }

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Fill buffer with data from TX data array
		rc = $angel.buffer.set_array( tx_buffer_data , @test_info[ :functions_buffer_id ] , 0 , tx_buffer_data.length )

		unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end

		if @drive_info[ :product_architecture ] == 'VAIL'

			rc = $angel.nvme_custom_command( 0xFD , 0 , 0x100 , 0 , 0x1 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end
		else
			# DIAGNOSTIC INTERFACE D1 ( little-endian )
			rc = $angel.nvme_custom_command( 0xD1 , 0 , 0x100 , 0 , 0x2 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end

			# Fill RX buffer arrays with 512 bytes of 0x00
			rx_buffer_data = Array.new( 512 , 0x00 )

			rx_buffer_data[ 0x00 .. 0x03 ] = [ 0x1E , 0xAB , 0x1D , 0xF0 ]
			rx_buffer_data[ 0x20 .. 0x23 ] = [ 0x11 , 0xBA , 0x5E , 0xBA ]

			rx_buffer_data[ 0x40 ] = 0x02
			rx_buffer_data[ 0x44 ] = 0x01
			rx_buffer_data[ 0x48 ] = 0xF2

			# Clear Buffer
			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			# Fill buffer with data from RX data array
			rc = $angel.buffer.set_array( rx_buffer_data , @test_info[ :functions_buffer_id ] , 0 , rx_buffer_data.length )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; end

			# DIAGNOSTIC INTERFACE D2 ( little-endian )
			rc = $angel.nvme_custom_command( 0xD2 , 0 , 0x80 , 0 , 0x2 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		if caller_locations.first.label == 'power_off' ; data += ' : ' + @drive_info[ :ctrl_id ].inspect + ' : ' + @drive_info[ :bus_id ].inspect ; end

		if caller_locations.first.label == 'power_on' ; data += ' : ' + @drive_info[ :ctrl_id ].inspect + ' : ' + @drive_info[ :bus_id ].inspect ; end

		@test_info[ :syslog ].info( 'Port ' + $test_info.port.to_s + ' : ' + data.to_s )

		return data
	end

	# Performs ctrl and namespace identify commands
	# Calls Functions::nvme_identify_namespace
	# Calls Functions::_get_max_block_tx_size
	# Populates @drive_info[ :name_space_id_list ] & @drive_info[ :number_of_active_namespaces ]
	# Populates @drive_info[ :sn ] , drive_info[ :fw ] , @drive_info[ :pn ]
	def nvme_identify()

		@drive_info[ :drive_responsive ] = false

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# 5.15.2.2 Identify Controller data structure CNS 01h
		# CNS = Controller or Namespace Structure ; Figure 244: Identify – CNS Values
		cns = 0x1 ; rc = $angel.nvme_custom_command( 0x06 , 0 , cns , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end

		if $test_status.current_status.to_s.downcase.include?( 'precheck' ) || @test_info[ :firmware_updated ] == true

			@drive_info[ :sn ] = ( $angel.buffer.get_ascii_string( @test_info[ :functions_buffer_id ] , 4 , 20 ) ).strip
			@drive_info[ :fw ] = ( $angel.buffer.get_ascii_string( @test_info[ :functions_buffer_id ] , 64 , 8 ) ).strip
			@drive_info[ :pn ] = ( $angel.buffer.get_ascii_string( @test_info[ :functions_buffer_id ] , 24 , 40 ) ).strip

			@test_info[ :firmware_updated ] = false
		end

		# Maximum Data Transfer Size reported by drive ( Maximum Data Transfer Size = CAP.MPSMIN * ( 2 ** MDTS )
		# If mdts is 0 , means no drive side limit
		@drive_info[ :MDTS ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 77 , 1 , 'little' , 'unsigned' )

		if @drive_info[ :MDTS ] == 0

			@drive_info[ :max_bytes_per_io ] = $test_status.buffer_size
		else
			# MPSMIN = minimum memory page size (CAP.MPSMIN)
			# This is the maximum data transfer size , use this for custom NVME command chunk size
			# This is not the maximum block transfer size used for IO
			@drive_info[ :max_bytes_per_io ] = ( @test_info[ :mpsmin ] * ( 2 ** @drive_info[ :MDTS ] ) )
		end

		# Number of Namespaces (NN): This field indicates the maximum value of a valid NSID for the NVM subsystem.
		# If the MNAN field is cleared to 0h, then this field also indicates the maximum number of namespaces supported by the NVM subsystem.
		@drive_info[ :nn ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 516 , 4 , 'little' , 'unsigned' )

		# LAP : Log Page Attributes
		@drive_info[ :lpa ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 261 , 1 , 'little' , 'unsigned' )

		if ( ( @drive_info[ :lpa ].to_s(2) )[-5] ).to_i == 1 ; @drive_info[ :persistent_event_log_supported ] = true ; else ; @drive_info[ :persistent_event_log_supported ] = false ; end

		# Updates Angel variables for serial number , pn , & firmware version
		$angel.decode_nvme_id_controller_data( @test_info[ :functions_buffer_id ] )

		$angel.report_drive_info( @test_info[ :functions_buffer_id ] , 4096 )

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# 5.15.2.3 Active Namespace ID list CNS 02h
		# CNS = Controller or Namespace Structure ; Figure 244: Identify – CNS Values
		cns = 0x2 ; rc = $angel.nvme_custom_command( 0x06 , 0 , cns , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end

		index = 0

		@drive_info[ :name_space_id_list ] = []

		1.upto( @drive_info[ :nn ].to_i ) do |count|

			nsid = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , index ,  4 , 'little' , 'unsigned' )

			if nsid == 0 ; break ; end

			@drive_info[ :name_space_id_list ].push( nsid )

			index += 4
		end

		@drive_info[ :number_of_active_namespaces ] = @drive_info[ :name_space_id_list ].length

		@drive_info[ :name_space_id_list ].each do |nsid|

			nvme_identify_namespace( nsid: nsid )
		end

		_get_max_block_tx_size()

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :drive_responsive ] = true

		@drive_info[ :data_current ] = true
	end

	def nvme_verify()

		rc = $angel.nvme_custom_command( 0x0C , 0 , 0 , 0x80000001 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end
	end

	# Performs namespace identify commands
	# Populates @drive_info[ :block_size ] , @drive_info[ :capacity ] , @drive_info[ :max_lba ]
	def nvme_identify_namespace( nsid: nil )

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		@namespace_info[ nsid ] = {}

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

	 	# Identify Namespace 9 5.15.2.1 Identify Namespace data structure CNS 00h )
		# CNS = Controller or Namespace Structure ; Figure 244: Identify – CNS Values
		cns = 0x0 ; rc = $angel.nvme_custom_command( 0x06 , nsid , cns , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end

		# Populates Angel variables $drive_info.max_lba & $drive_info.bytes_per_sector 
		$angel.decode_nvme_id_namespace_data( @test_info[ :functions_buffer_id ] )

		# Total size of the namespace in logical blocks ( after being formated )
		ncap = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 8 , 8 , 'little' , 'unsigned' )

		# Maximum number of logical blocks that may be allocated in the namespace
		nsze = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 8 , 'little' , 'unsigned' )

		# Namespace Multi-path I/O and Namespace Sharing Capabilities
		# If 1 ; drive is 2x2 capable
		nmic = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 30 , 1 , 'little' , 'unsigned' )

		# Get FLBAS ( Formatted LBA Size ) to determine which format is used
		flbas = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 26 , 1 , 'little' , 'unsigned' )

		flbas_bit = flbas[4]

		# Get blocksize from LBAF structure
		lbaf_location = 128 + ( 4 * ( flbas & 0x0f ) )

		# Metadata Size
		ms = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , lbaf_location , 2 , 'little' , 'unsigned' )

		# LBADS ( LBA Data Size )
		ds = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , lbaf_location + 2 , 1 , 'little' , 'unsigned' )

		current_block_size = 2**ds

		capacity = ( ( ncap.to_f * current_block_size.to_f ) / 1000 ** 4 ).round( 2 )

		# Number of LBA Formats
		nlbaf = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 25 , 1 , 'little' , 'unsigned' )

		extdatalba = ( flbas & 0x10 ) >> 4

		nvmcap = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 48 , 16 , 'little' , 'unsigned' )

		@drive_info[ :block_size ] = current_block_size
		@drive_info[ :capacity ] = capacity
		@drive_info[ :max_lba ] = ( ncap - 1 )
		@drive_info[ :nsze ] = nsze

		@namespace_info[ nsid ][ :ncap ] = ncap
		@namespace_info[ nsid ][ :nsze ] = nsze
		@namespace_info[ nsid ][ :flbas ] = flbas
		@namespace_info[ nsid ][ :ms ] = ms
		@namespace_info[ nsid ][ :ds ] = ds
		@namespace_info[ nsid ][ :bs ] = current_block_size
		@namespace_info[ nsid ][ :nlbaf ] = nlbaf
		@namespace_info[ nsid ][ :extdatalba ] = extdatalba
		@namespace_info[ nsid ][ :nvmcap ] = nvmcap
		@namespace_info[ nsid ][ :nmic ] = nmic

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# 5.15.2.4 Namespace Identification Descriptor list CNS 03h
		# CNS = Controller or Namespace Structure ; Figure 244: Identify – CNS Values
		cns = 3 ; rc = $angel.nvme_custom_command( 0x06 , nsid , cns , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end

		csi = 0 ; index = 0

		0.upto( 1023 ) do |counter|

			# Namespace Identifier Type
			nidt = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , index , 1 , 'little' , 'unsigned' )

			# Namespace Identifier Length
			nidl = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 1 ) , 1 , 'little' , 'unsigned' )

			if	nidl == 0

				break

			elsif	nidt == 4

				# Command Set Identifier
				csi = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 4 ) , nidl , 'little' , 'unsigned' )

				@namespace_info[ nsid ][ :csi ] = csi

				if	csi == 0

					$drive_info.max_lba = @namespace_info[ nsid ][ :ncap ] - 1

					$drive_info.bytes_per_sector = @namespace_info[ nsid ][ :bs ]

					@namespace_info[ nsid ][ :type ] = 'conv'

					if @drive_info[ :conv_namespace ] == nil ; @drive_info[ :conv_namespace ] = nsid ; end

				elsif	csi == 2

					if @drive_info[ :zoned_namespace ] == nil ; @drive_info[ :zoned_namespace ] = nsid ; end

					@namespace_info[ nsid ][ :type ] = 'zoned'

					@namespace_info[ nsid ][ :number_of_zones ] = get_number_of_zones( nsid: nsid )

					refresh_zone_info( nsid: nsid )
				end
			end

			index += nidl + 4
		end

		if @namespace_info[ nsid ].key?( :type ) == false ; @namespace_info[ nsid ][ :type ] = 'conv' ; end

		unless @drive_info[ :zoned_namespace ] == nil

			# Clear Buffer
			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			cns = 0x5 ; csi = 0x2000000 ; rc = $angel.nvme_custom_command( 0x06 , @drive_info[ :zoned_namespace ].to_i , cns , csi , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; return ; end

			@drive_info[ :max_open_zones ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 8 , 11 , 'little' , 'unsigned' ) + 1
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# Calls Functions::nvme_zone_receive
	# returns number_of_zones
	def get_number_of_zones( nsid: @drive_info[ :zoned_namespace ] )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		zid = -1 ; zras_features = 0 ; zras_field = 0 ; buffer_length = 8 ; zra = 0

		nvme_zone_receive( nsid: nsid , zid: zid , buffer_length: buffer_length , zras_features: zras_features , zras_field: zras_field , zra: zra )

		number_of_zones = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 ,  8 , 'little' , 'unsigned' )

		return number_of_zones
	end

	# Calls Functions::nvme_zone_receive
	# Populates @zone_info
	# NOTE - currently NSID 2 is the only namespace with zones , so I am setting the NSID default to 2
	def refresh_zone_info( nsid: 2 )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		zid = -1 ; zras_features = 0 ; zras_field = 0 ; zra = 0

		@zone_info[ nsid ] = {}

		number_of_zones = @namespace_info[ nsid ][ :number_of_zones ]

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		buffer_length = ( number_of_zones * 64 + 64 )

		nvme_zone_receive( nsid: nsid , zid: zid , buffer_length: buffer_length , zras_features: zras_features , zras_field: zras_field , zra: zra )

		index = 64

		for zone_id in 0 .. ( number_of_zones - 1 )

			@zone_info[ nsid ][ zone_id ] = {}

			# Spec TP-4053
			# 4.4.2.3 Zone Descriptor Data Structure ( see Figure 39 )

			# Zone Type
			# bits 3..0
			zone_type_value = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , index , 1 , 'little' , 'unsigned' ) ) & 0x0F

			case zone_type_value
				when 0x2 ; zone_type = 'sequential write required'
				else ; zone_type = 'unknown'
			end

			# Zone State
			# bits 7..4
			zone_state_value = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 1 ) , 1 , 'little' , 'unsigned' ) ) >> 4

			case zone_state_value
				when 0x1 ; zone_state = 'empty'
				when 0x2 ; zone_state = 'implicitly opened'
				when 0x3 ; zone_state = 'explicitly opened'
				when 0x4 ; zone_state = 'closed'
				when 0xd ; zone_state = 'read only'
				when 0xe ; zone_state = 'full'
				when 0xf ; zone_state = 'offline'
				else ; zone_state = 'unknown'
			end

			# Zone Attributes
			# bit 7 : zdev = zone descriptor extension valid
			# bit 2 : rzr = reset zone recommended
			# bit 1 : fzr = finish zone recommended
			# bit 0 : zfc = zone finished by controller

			# za : Zone Attributes
			za = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 2 ) , 1 , 'little' , 'unsigned' )

			# bit 3 : zrwaa : zone random write area allocation
			zrwaa = za & 0x08

			# zone_cap : ZCAP : Zone Capacity
			# bits 15:08
			zone_cap = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 8 ) , 8 , 'little' , 'unsigned' )

			# zone_start_lba : ZSLBA : Zone Start Logical Block Address
			# bits 23:16
			zone_start_lba = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 16 ) , 8 , 'little' , 'unsigned' )

			# write_pointer : WP : Write Pointer
			# bits 31:24
			write_pointer = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( index + 24 ) , 8 , 'little' , 'unsigned' )

			@zone_info[ nsid ][ zone_id ][ :zone_type ] = zone_type
			@zone_info[ nsid ][ zone_id ][ :zone_state ] = zone_state
			@zone_info[ nsid ][ zone_id ][ :write_pointer ] = write_pointer
			@zone_info[ nsid ][ zone_id ][ :zrwaa ] = zrwaa
			@zone_info[ nsid ][ zone_id ][ :zone_cap ] = zone_cap
			@zone_info[ nsid ][ zone_id ][ :zone_start_lba ] = zone_start_lba
			@zone_info[ nsid ][ zone_id ][ :zone_end_lba ] = zone_start_lba + zone_cap
			@zone_info[ nsid ][ zone_id ][ :zone_max_lba ] = zone_start_lba + zone_cap - 1

			index += 64
		end
	end

	# Displays the hash information for the selected zone(s) in the script-trace
	# Calls Functions::refresh_zone_info
	def display_zone_info( first_zone: 0 , last_zone: first_zone , namespace: nil )

		refresh_zone_info()

		@namespace_info.each do |nsid , attr|

			next unless @namespace_info[ nsid ][ :type ] == 'zoned'

			unless namespace == nil ; next unless nsid == namespace ; end

			@zone_info[nsid].each do |zid , data|

				next if zid < first_zone

				break if zid > last_zone

				f_log( [ 'INFO' , 'NSID-' + nsid.to_s + ' : ZID-' + zid.to_s , data.inspect ] )
			end
		end

		log()
	end

	# Displays the hash information for the selected namespace(s) in the script-trace
	def display_namespace_info( first_namespace: 1 , last_namespace: first_namespace )

		@namespace_info.each do |nsid , attr|

			next if nsid < first_namespace

			break if nsid > last_namespace

			f_log( [ 'INFO' , 'NSID-' + nsid.to_s , attr.to_s ] )
		end

		log()
	end

	# Sets the active namespace
	# Populates @test_info[ :selected_namespace ]
	# zoned functions automatically set the namespace
	def select_namespace( nsid: nil , log: true , force: false )

		f_log( [ 'DEBUG' , 'QUEUING ENABLED' , __method__.to_s , $test_status.queue_operation.to_s ] , -1 )

		if @test_info[ :selected_namespace ] == nsid && force != true ; return ; end

		rc = $angel.select_nvme_namespace( nsid.to_i )

		unless rc == nsid ; force_failure( category: 'select_namespace_failure' , data: rc.to_s ) ; end

		@test_info[ :selected_namespace ] = nsid

		if ( log == true ) ; f_log( [ 'INFO' , 'NEW NS SELECTED' , 'NSID-' + nsid.to_s.upcase + "\n" ] ) ; end

		f_log( [ 'DEBUG' , 'QUEUING ENABLED' , __method__.to_s , $test_status.queue_operation.to_s ] , -1 )
	end

	# Sets the default zoned namespace
	# Populates @drive_info[ :zoned_namespace ]
	# @drive_info[ :zoned_namespace ] is automatically set to the first zoned namespace in precheck
	def set_zoned_namespace( nsid: nil )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		@drive_info[ :zoned_namespace ] = nsid
	end

	# Zone Management Send
	# zslba : Zone Starting LBA :
	#	If the Zone Send Action is NOT Commit Zone , This field specifies the lowest LBA of the zone on which the Zone Send Action is performed
	#	If the Zone Send Action is Commit Zone , then this field specifies the LBA of the last logical block in the zone on which the Zone Send Action is performed
	# select all		[13 08:08] ; 1 = all zones , slba ignored
	# zone_state_action	[13 07:00]
	def nvme_zone_send( nsid: nil , zone_id: nil , select_all: nil , zone_state_action: nil , zrwaa: nil , zslba: nil )

		f_log( [ 'DEBUG' , 'nvme_zone_send' , nsid.to_s , zone_id.to_s , select_all.to_s , zone_state_action.to_s , zrwaa.to_s , zslba.to_s ] , -1 )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		queue_depth = @test_info[ :queue_depth ] ; if queue_depth > 0 ; disable_queuing( log: false ) ; end

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		dw10 = ( zslba & 0x00000000FFFFFFFF )
		dw11 = ( zslba & 0xFFFFFFFF00000000 ) << 32
		dw13 = ( zrwaa << 9 ) | ( select_all << 8 ) | zone_state_action

		f_log( [ 'DEBUG' , dw10.to_s , dw11.to_s , dw13.to_s ] )

		rc = $angel.nvme_custom_io_command( 0x79 , nsid , dw10 , dw11 , 0x00 , dw13 , 0x00 , 0x00 , @test_info[ :functions_buffer_id ] , 0x00 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; end

		if queue_depth > 0 ; enable_queuing( queue_depth: queue_depth , log: false ) ; end

		f_log( [ 'DEBUG' , 'QUEUING ENABLED' , __method__.to_s , $test_status.queue_operation.to_s ] , -1 )
	end

	# Zone Management Receive ( spec TP-4053 )
	# nsid                            namespace id
	# buffer_length  [12]             buffer length, dwords 0 based
	# zras_features [13 16:16]        zone receive action specific features (1=partial report)
	# zras_field    [13 15:08]        zone receive action specific field
	# 0=all, 1=empty, 2=impl opened, 3=expl opened , 4=closed, 5=full, 6=read only, 7 = offline
	# zra           [13 07:00]        zone receive action (0=report zone, 1=ext report zone)
	def nvme_zone_receive( nsid: nil , zid: nil , buffer_length: nil , zras_features: nil , zras_field: nil , zra: nil )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		queue_depth = @test_info[ :queue_depth ] ; if queue_depth > 0 ; disable_queuing( false ) ; end

		f_log( [ 'DEBUG' , 'QUEUING ENABLED' , __method__.to_s , $test_status.queue_operation.to_s ] , -1 )

		if zid == -1 ; zslba = 0 ; else ; zslba = @zone_info[ nsid ][ zid ][ :zone_start_lba ] ; end

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		dw0 = 0x7A
		dw10 = ( zslba & 0x00000000FFFFFFFF )
		dw11 = ( zslba & 0xFFFFFFFF00000000 ) << 32
		dw12 = ( buffer_length >> 2 ) - 1
		dw13 = ( zras_features << 16 ) | ( zras_field << 8 ) | zra
		dw14 = 0
		dw15 = 0

		#log( dw0.to_s + ' , ' + nsid.to_s + ' , ' + dw10.to_s + ' , ' + dw11.to_s + ' , ' + dw12.to_s + ' , ' + dw13.to_s + ' , ' + dw14.to_s + ' , ' + dw15.to_s + ' , ' + @test_info[ :functions_buffer_id ].to_s + ' , ' + buffer_length.to_s )

		rc = $angel.nvme_custom_io_command( dw0 , nsid , dw10 , dw11 , dw12 , dw13 , dw14 , dw15 , @test_info[ :functions_buffer_id ] , buffer_length )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' ) ; end

		if queue_depth > 0 ; enable_queuing( queue_depth: queue_depth , log: false ) ; end

		f_log( [ 'DEBUG' , 'QUEUING ENABLED' , __method__.to_s , $test_status.queue_operation.to_s ] , -1 )
	end

	# Performs various zone related functions
	# Supported functions : close , close-all , open , reset , reset-all , finish , finish-all , commit
	# Calls Functions::nvme_zone_send
	# Calls Functions::refresh_zone_info
	def zone_func( func: nil , zone_id: 0 , log: true , nsid: @drive_info[ :zoned_namespace ] , commit_lba: nil )

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		case func
			when 'close'		; zone_state_action = 0x01 ; zrwaa = 0 ; select_all = 0 ; zslba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
			when 'close-all'	; zone_state_action = 0x01 ; zrwaa = 0 ; select_all = 1 ; zslba = 0
			when 'finish'		; zone_state_action = 0x02 ; zrwaa = 0 ; select_all = 0 ; zslba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
			when 'finish-all'	; zone_state_action = 0x02 ; zrwaa = 0 ; select_all = 1 ; zslba = 0
			when 'open'		; zone_state_action = 0x03 ; zrwaa = 0 ; select_all = 0 ; zslba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
			when 'open-zrwaa'	; zone_state_action = 0x03 ; zrwaa = 1 ; select_all = 0 ; zslba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
			when 'reset'		; zone_state_action = 0x04 ; zrwaa = 0 ; select_all = 0 ; zslba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
			when 'reset-all'	; zone_state_action = 0x04 ; zrwaa = 0 ; select_all = 1 ; zslba = 0
			# commit is not working properly
			when 'commit'		; zone_state_action = 0x11 ; zrwaa = 0 ; select_all = 0 ; zslba = commit_lba
			else ; force_failure( category: 'zone_function_error' , data: func.to_s )
		end

		if zslba == nil ; force_failure( category: 'zone_function_error' , data: func.to_s + ' : Invalid ZSLBA' ) ; end

		if log == true

			if func.include?( 'all' )

				f_log( [ 'FUNC' , func.to_s.upcase + "\n" ] )
			else
				f_log( [ 'FUNC' , 'ZONE-' + zone_id.to_s , func.to_s.upcase + "\n" ] )
			end
		end

		# zrwaa : zone random write area allocation

		# zslba : Zone Starting LBA :
		#	If the Zone Send Action is NOT Commit Zone , This field specifies the lowest LBA of the zone on which the Zone Send Action is performed
		#	If the Zone Send Action is Commit Zone , then this field specifies the LBA of the last logical block in the zone on which the Zone Send Action is performed

		nvme_zone_send( nsid: nsid , zone_id: zone_id , select_all: select_all , zone_state_action: zone_state_action , zrwaa: zrwaa , zslba: zslba )

		refresh_zone_info()
	end

	def inspector_upload()

		_inspector_csv()

		inspector_csv_file = $test_info.home_directory + @test_logs[ :inspector ].to_s

		@inspector_info[ :instance_counter ] += 1

		if caller.to_s.include?( 'post_script_handler' )

			if	@drive_info[ :assert_present ] == true

				drive_status = 'ASSERTED'

				details = 'FAILED : ' + @error_info[ :category ].to_s

				error_code = @error_info[ :pfcode ].to_s

			elsif	@drive_info[ :drive_responsive ] == true

				drive_status = 'ONLINE'

				details = @test_info[ :status ].to_s.upcase

				if @error_info[ :pfcode ] == nil

					error_code = 'NA'
				else
					error_code = @error_info[ :pfcode ].to_s
				end
			else
				drive_status = 'UNRESPONSIVE'

				details = 'FAILED : ' + @error_info[ :category ].to_s

				error_code = @error_info[ :pfcode ].to_s
			end
		else
			drive_status = 'ONLINE' 

			details = 'RUNNING'

			error_code = 'NA'
		end

		header = "TABLE=TEST_RESULT\nINSTANCE,TEST_START_DATE,TEST_END_DATE,ERROR_CODE,DRIVE_STATUS,DETAILED_MESSAGE\n"

		$angel.log.write_file( inspector_csv_file.to_s , header.to_s , 'a' )

		data = @inspector_info[ :instance_counter ].to_s + ',' + @test_info[ :start_time ].to_s[0..-7] + ',' + Time.now.to_s[0..-7].to_s + ',' + error_code.to_s + ',' + drive_status.to_s + ',' + details.to_s + "\n"

		$angel.log.write_file( inspector_csv_file.to_s , data.to_s , 'a' )

		if File.exists?( inspector_csv_file )

			unless @test_info[ :enable_inspector_uploads ] == false

				f_log( [ 'FUNC' , 'COPY' , 'INSPECTOR CSV TO UPLOAD DIR' + "\n" ] )

				begin
					scp_upload( file: inspector_csv_file.to_s , destination: @test_info[ :inspector_mount_dir ].to_s )

				rescue StandardError => error

					_warning_counter( category: 'inspector_upload' , data: error.to_s )
				end
			end
		else
			force_failure( category: 'file_not_found' , data: inspector_csv_file.to_s )
		end
	end

	# MICROSOFT Specific : OCP - SMART Cloud Attributes Log Page (0xC0)
	def get_log_page_C0h_MSFT( log: false , dump_logs: false )

		unless @drive_info[ :customer ].include?( 'MICROSOFT' ) ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_C0-MSFT_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C0-MSFT' , filename.to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C0-MSFT' + "\n" ] )
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page FAh
		# 512 bytes / 4 = 128 ( 0x80 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x008000C0 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		inspector_info = {}

		# buffer_id, offset, length, endian, mode
		inspector_info[ 'physical_media_units_written' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 16 , 'little' , 'unsigned' )
		inspector_info[ 'physical_media_units_read' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 16 , 16 , 'little' , 'unsigned' )
		inspector_info[ 'bad_user_nand_block_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 32 , 8 , 'little' , 'unsigned' )
		# Raw & Normalized Per Spec
		inspector_info[ 'bad_user_nand_block_count_raw' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 32 , 6 , 'little' , 'unsigned' )
		inspector_info[ 'bad_user_nand_block_count_normalized' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 38 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'bad_system_nand_block_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 40 , 8 , 'little' , 'unsigned' )
		# Raw & Normalized Per Spec
		inspector_info[ 'bad_system_nand_block_count_raw' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 40 , 6 , 'little' , 'unsigned' )
		inspector_info[ 'bad_system_nand_block_count_normalized' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 46 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'xor_recovery_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 48 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'uncorrectable_read_error_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 56 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'soft_ecc_error_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 64 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'end_to_end_correction_counts' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 72 , 8 , 'little' , 'unsigned' )
		# end_to_end_correction_counts are split into end_to_end_correction_counts_detected & end_to_end_correction_counts_corrected
		inspector_info[ 'end_to_end_correction_counts_detected' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 72 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'end_to_end_correction_counts_corrected' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 76 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'system_data_percentage_used' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 80 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'refresh_counts' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 81 , 7 , 'little' , 'unsigned' )
		inspector_info[ 'maximum_user_data_erase_counts' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 88 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'minimum_user_data_erase_counts' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 92 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'thermal_throttling_status_and_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 96 , 2 , 'little' , 'unsigned' )
		# thermal_throttling_status_and_count are split into thermal_throttling_status & thermal_throttling_count
		inspector_info[ 'thermal_throttling_status' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 96 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'thermal_throttling_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 97 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'pcie_correctable_error_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 104 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'incomplete_shutdowns' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 112 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'percentage_free_blocks' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 120 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'capacitor_health' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 128 , 2 , 'little' , 'unsigned' )
		inspector_info[ 'unaligned_IO' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 136 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'security_version_number' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 144 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'NUSE' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 152 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'PLP_start_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 160 , 16 , 'little' , 'unsigned' )
		inspector_info[ 'endurance_estimate' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 176 , 16 , 'little' , 'unsigned' )
		inspector_info[ 'pcie_link_retraining_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 192 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'power_state_change_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 200 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'logpage_version' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 494 , 2 , 'little' , 'unsigned' )
		inspector_info[ 'logpage_guid' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 496 , 16 , 'little' , 'unsigned' )

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0xC0_MSFT' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0xC0_MSFT' ][ inspector_time_stamp ] = inspector_info

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 512 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# MICROSOFT Specific : OCP - Error Recovery Log Page (0xC1)
	def get_log_page_C1h_MSFT( log: false , dump_logs: false )

		unless @drive_info[ :customer ].include?( 'MICROSOFT' ) ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_C1-MSFT_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C1-MSFT' , filename.to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C1-MSFT' + "\n" ] )
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page C1h
		# 512 bytes / 4 = 128 ( 0x80 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x008000C1 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		inspector_info = {}

		# buffer_id, offset, length, endian, mode
		inspector_info[ 'panic_reset_wait_time' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 2 , 'little' , 'unsigned' )
		inspector_info[ 'panic_reset_action' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 2 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'device_recovery_action' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 3 , 1 , 'little' , 'unsigned' )
		inspector_info[ 'panic_id' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'device_capabilities' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 12 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'logpage_version' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 494 , 2 , 'little' , 'unsigned' )
		inspector_info[ 'logpage_guid' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 496 , 16 , 'little' , 'unsigned' )

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0xC1_MSFT' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0xC1_MSFT' ][ inspector_time_stamp ] = inspector_info

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 512 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	def get_log_page_C2h( log: false , dump_logs: false )

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page C2h
		# 4096 bytes / 4 = 1024 ( 0x400 ) DWORDS
		# DWORD 14 : 1 specifies standard ( non-customer ) log page
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x040000C2 , 0 , 0 , 0 , 1 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		page_length = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 4 , 'little' , 'unsigned' )

		data_type_cbs_ascii = %w( 2 3 7 10 11 13 14 16 17 24 25 26 27 )
		data_type_cbs_hex = %w( 8 9 )
		data_type_uint32 = %w( 1 a f 12 15 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 2a 2b 2c )
		data_type_uint64 = %w( 4 5 6 b c d e 28 29 )

		offset = 8

		until offset >= page_length

			field_length = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 4 , 'little' , 'unsigned' )

			field_id = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 4 ) , 4 , 'little' , 'unsigned' )

			if data_type_cbs_ascii.include?( field_id.to_s(16) )

				data_length = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 8 ) , 4 , 'little' , 'unsigned' )

				data = ( $angel.buffer.get_ascii_string( @test_info[ :functions_buffer_id ] , ( offset + 8 + 4 ) , data_length ) ).strip

				if field_id.to_s(16) == '10' ; @drive_info[ :model ] = data ; end

				if field_id.to_s(16) == '7' ; @drive_info[ :product_name ] = data ; end

				if field_id.to_s(16) == '17'

					@drive_info[ :tmm_version ] = data

					if @drive_info[ :tmm_version ].upcase == 'NO_TMM_FILE' || @drive_info[ :tmm_version ] == nil

						if @test_info[ :tmm_check_error_action ] == 'fail' || @test_info[ :tmm_check_error_action ] == 'abort'

							force_failure( category: 'tmm_check_failure' , data: @drive_info[ :tmm_version ].to_s )
						else
							_warning_counter( category: 'tmm_check_failure' , data: @drive_info[ :tmm_version ].to_s )
						end
					end
				end

			elsif data_type_cbs_hex.include?( field_id.to_s(16) )

				data_length = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 8 ) , 4 , 'little' , 'unsigned' )

				data = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 8 + 4 ) , data_length , 'little' , 'unsigned' )

				data = data.to_s(16)

			elsif data_type_uint32.include?( field_id.to_s(16) )

				data = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 8 ) , field_length , 'little' , 'unsigned' )

				data = data.to_s(16)[ -8..-1 ]

				# https://confluence.wdc.com/pages/viewpage.action?spaceKey=FWCCB7&title=Project+Identification
				# iiii iiii ssss ssss pppp pppp bbbb bbvv
				# Not used in HudsonBay
				if field_id.to_s(16) == '1'

					soc = "%02x" % ( ( data[ -4..-3 ].to_i(16).to_s(2).to_i.to_s )[ -6..-1 ].to_i(2).to_s )

					product_architecture_id = { '15' => 'SNOWBIRD' , '17' => 'THUNDERBIRD' }

					@drive_info[ :product_architecture ] = product_architecture_id[ soc ]

					branch = "%02x" % ( ( data[ -2..-1 ].to_i(16).to_s(2).to_i.to_s[ 0..-3 ] ).to_i(2).to_s )

					product_family_id = {

						'SNOWBIRD' => { '01' => 'omaha' , '02' => 'aspenplus' , '03' => 'malibux' , '04' => 'laguna' , '05' => 'borabora' , '06' => 'pismo' } ,

						'THUNDERBIRD' => { '01' => 'goldcoast' , '02' => 'victorharbor' , '03' => 'coffeebay' }
					}

					@drive_info[ :product_family ] = product_family_id[ @drive_info[ :product_architecture ].to_s ][ branch ].upcase

					if @drive_info[ :product_family ] == nil

						_warning_counter( category: 'product_family' , data: 'CHECK / UPDATE LOG PAGE C2H DATA TABLE' )
					end
				end

				# Used in HudsonBay
				if field_id.to_s(16) == '2c'

					if	data.to_i(16) >= 0x1 && 0xF >= data.to_i(16)

						@drive_info[ :product_architecture ] = 'SNOWBIRD'

					elsif	data.to_i(16) >= 0x10 && 0x1F >= data.to_i(16)

						@drive_info[ :product_architecture ] = 'THUNDERBIRD'

					elsif	data.to_i(16) >= 0x50 && 0x6F >= data.to_i(16)

						@drive_info[ :product_architecture ] = 'VAIL'

					elsif	data.to_i(16) >= 0x100 && 0x11F >= data.to_i(16)

						@drive_info[ :product_architecture ] = 'SIRIUS'
					else
						@drive_info[ :product_architecture ] = 'UNKNOWN'

						_warning_counter( category: 'product_architecture' , data: 'CHECK / UPDATE LOG PAGE C2H DATA TABLE' )
					end

					product_family_id = { '00000050' => 'hudsonbay' }

					@drive_info[ :product_family ] = product_family_id[ data.to_s ]

					if @drive_info[ :product_family ] == nil

						_warning_counter( category: 'product_family' , data: 'CHECK / UPDATE LOG PAGE C2H DATA TABLE' )
					end
				end

				# Populates @drive_info[ :customer ] & @test_info[ :jira_customer ]
				# Information Is From Security Roadmap and Requirements Summary.xlsx ( https://wdc.app.box.com/folder/87561046914?s=2fhn9pndl3knrge1red8ma5ejb1wa958 )
				if field_id.to_s(16) == '15' ; _decode_fw_customer_id( id: data ) ; end

				# Check if assert is present
				if field_id.to_s(16) == '19'

					if data.to_i == 0

						@drive_info[ :assert_present ] = false

					elsif	data.to_i == 1

						@drive_info[ :assert_present ] = true

#FIXME KAL - Current HB FW does not support clear assert
						force_failure( category: 'assert_detected' , data: 'ASSERT DETECTED' )
					end
				end

				# Populates @drive_info[ :form_factor ]
				# Information Is From https://confluence.wdc.com/pages/viewpage.action?pageId=609936123
				if field_id.to_s(16) == 'a'

					form_factor_id = {

						'00000000' => 'UNKNOWN' ,
						'00000001' => 'U.2' ,
						'00000002' => 'HHHL' ,
						'00000003' => 'U.3' , # NOTE MEZZANINE : VICTOR HARBOR U.3 REPORTS AS MEZZANINE
						'00000004' => 'M.2' ,
						'00000005' => 'E1.L' ,
						'00000006' => 'E1.S' ,
						'00000007' => 'U.3' ,
					}

					@drive_info[ :form_factor ] = form_factor_id[ data ]

					if @drive_info[ :form_factor ] == 'UNKNOWN'

						fh = File.open( '/home/everest/client' + $test_info.client.to_s + '/Settings-File.txt' )

						data = ( ( fh.grep( /Config/ ) )[0].split( ',' ) )[-1].split( ' ' )[0].to_s

						fh.close

						unless data == nil || data == '' ; @drive_info[ :form_factor ] = data ; end

						_warning_counter( category: 'form_factor' , data: 'CHECK / UPDATE LOG PAGE C2H DATA TABLE' )
					end
				end

			elsif data_type_uint64.include?( field_id.to_s(16) )

				data = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( offset + 8 ) , field_length , 'little' , 'unsigned' )

				data = data.to_s(16)[ -16..-1 ]
			end

			f_log( [ 'DEBUG' , 'LOG PAGE C2H' , field_id.to_s(16) , data.to_s + "\n" ] , -1 )

			offset += field_length
		end

		_decode_fw_info()

		filename = 'ANGEL_C2_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C2' , filename.to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C2' + "\n" ] )
			end
		end

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , page_length , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# MICROSOFT Specific : OCP - Firmware Activation History Log page (0xC2)
	def get_log_page_C2h_MSFT( log: false , dump_logs: false )

		unless @drive_info[ :customer ].include?( 'MICROSOFT' ) ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_C2-MSFT_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C2-MSFT' , filename.to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'C2-MSFT' + "\n" ] )
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page C2h
		# 4096 bytes / 4 = 1024 ( 0x400 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x040000C2 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		inspector_info = {}

		# buffer_id, offset, length, endian, mode
		inspector_info[ 'log_id' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 1 , 'little' , 'unsigned' )

		inspector_info[ 'valid_fw_activation_history_entries' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 4 , 'little' , 'unsigned' )

		offset = 8

		1.upto( 20 ) do |entry_number|

			# 1
			entry_version_number = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 1 , 'little' , 'unsigned' )

			inspector_info[ 'entry_version_number-' + entry_number.to_s ] = entry_version_number

			offset += 1

			# 2
			entry_version_length = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 1 , 'little' , 'unsigned' )

			inspector_info[ 'entry_version_length-' + entry_number.to_s ] = entry_version_length

			offset += 1

			# 3 Reserved
			offset += 2

			# 4
			valid_fw_activation_history_entries = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 2 , 'little' , 'unsigned' )

			# I believe this should be valid_fw_activation_history_entry instead of valid_fw_activation_history_entries
			inspector_info[ 'valid_fw_activation_history_entry-' + entry_number.to_s ] = valid_fw_activation_history_entries

			offset += 2

			# 5
			timestamp = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 8 , 'little' , 'unsigned' )

			inspector_info[ 'timestamp-' + entry_number.to_s ] = timestamp

			offset += 8

			# 6 Reserved
			offset += 8

			# 7
			powercycle_count = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 8 , 'little' , 'unsigned' )

			inspector_info[ 'powercycle_count-' + entry_number.to_s ] = powercycle_count

			offset += 8

			# 8 : this is pulled with big endian and converted to an ASCII string
			previous_Firmware = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 8 , 'big' , 'unsigned' )

			unless previous_Firmware == 0 ; previous_Firmware = [ previous_Firmware.to_s(16) ].pack('H*') ; end

			inspector_info[ 'previous_firmware-' + entry_number.to_s ] = previous_Firmware

			offset += 8

			# 9 : this is pulled with big endian and converted to an ASCII string
			current_Firmware = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 8 , 'big' , 'unsigned' )

			unless current_Firmware == 0 ; current_Firmware = [ current_Firmware.to_s(16) ].pack('H*') ; end

			inspector_info[ 'current_firmware-' + entry_number.to_s ] = current_Firmware

			offset += 8

			# 10
			slot_number = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 1 , 'little' , 'unsigned' )

			inspector_info[ 'slot_number-' + entry_number.to_s ] = slot_number

			offset += 1

			# 11
			commit_Action_type = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 1 , 'little' , 'unsigned' )

			inspector_info[ 'commit_action_type-' + entry_number.to_s ] = commit_Action_type

			offset += 1

			# 12
			result = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 2 , 'little' , 'unsigned' )

			inspector_info[ 'result-' + entry_number.to_s ] = result

			offset += 2

			# 13 Reserved
			offset += 14
		end

		inspector_info[ 'logpage_version' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4078 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'logpage_guid' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4080 , 16 , 'little' , 'unsigned' )

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0xC2_MSFT' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0xC2_MSFT' ][ inspector_time_stamp ] = inspector_info

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 4096 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# Confluence Page for log page FA https://confluence.wdc.com/pages/viewpage.action?spaceKey=SBESS&title=NVMe+Get+Log+Pages
	# Used to get customer ID
	# This log page is not archived
	def get_log_page_FAh( log: false , dump_logs: false )

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_FA_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page FAh
		# Log Page length is 36 bytes , 0 based
		#rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x000A00FA , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x000A00FA , 0 , 0 , 0 , 1 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0

			force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s )

			return
		end

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'FA' , filename.to_s + "\n" ] )
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'FA' + "\n" ] )
			end
		end

		fw_customer_id = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 8 , 4 , 'little' , 'unsigned' ) ).to_s(16)

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 36 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end
		end

		# Populates @drive_info[ :customer ] & @test_info[ :jira_customer ]
		# Information Is From Security Roadmap and Requirements Summary.xlsx ( https://wdc.app.box.com/folder/87561046914?s=2fhn9pndl3knrge1red8ma5ejb1wa958 )
		_decode_fw_customer_id( id: fw_customer_id )

		# This is used to display log pages retrieved in post-script-handler
		unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# Issues an NVME get log page 02h SMART command
	# Populates @drive_info[ :nand_usage ] from SMART if greater then current @drive_info[ :nand_usage ]
	# If option 'log' is true logs an entry in the script-trace
	# If option 'dump_logs' is true dumps data to file
	def get_log_page_02h( log: true , dump_logs: true )

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_02_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , '02' , filename.to_s ] ) ; log()
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , '02' ] ) ; log()
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page 02h SMART
		# 02h length data length is 512 bytes ; bytes 511:232 are reserved
		# 512 bytes / 4 = 128 ( 0x80 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x00800002 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		smart_warnings_data = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 1 , 'little' , 'unsigned' )

		inspector_info = {}

		inspector_info[ 'critical_warning' ] = smart_warnings_data

		inspector_info[ 'composite_temperature' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 1 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'available_spare' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 1 , 'little' , 'unsigned' )

		inspector_info[ 'available_spare_threshold' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 1 , 'little' , 'unsigned' )

		inspector_info[ 'percentage_used' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 5 , 1 , 'little' , 'unsigned' )

		@drive_info[ :nand_usage ] = inspector_info[ 'percentage_used' ]

		inspector_info[ 'endurance_group_critical_warning_summary' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 6 , 1 , 'little' , 'unsigned' )

		inspector_info[ 'data_units_read' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 32 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'data_units_written' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 48 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'host_read_commands' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 64 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'host_write_commands' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 80 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'controller_busy_time' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 96 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'power_cycles' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 112 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'power_on_hours' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 128 , 16 , 'little' , 'unsigned' )

		@drive_info[ :power_on_hours ] = inspector_info[ 'power_on_hours' ]

		inspector_info[ 'unsafe_shutdowns' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 144 , 16 , 'little' , 'unsigned' )

		@drive_info[ :unsafe_shutdowns ] = inspector_info[ 'unsafe_shutdowns' ]

		inspector_info[ 'media_data_integrity_errors' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 160 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'num_error_info_log_entries' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 176 , 16 , 'little' , 'unsigned' )

		inspector_info[ 'warning_composite_temperature_time' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 192 , 4 , 'little' , 'unsigned' )

		inspector_info[ 'critical_composite_temperature_time' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 196 , 4 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_1' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 200 , 2 , 'little' , 'signed' )

		inspector_info[ 'temperature_sensor_2' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 202 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_3' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 204 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_4' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 206 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_5' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 208 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_6' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 210 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_7' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 212 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'temperature_sensor_8' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 214 , 2 , 'little' , 'unsigned' )

		inspector_info[ 'thermal_mgmt_temp_1_transition_cnt' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 216 , 4 , 'little' , 'unsigned' )

		inspector_info[ 'thermal_mgmt_temp_2_transition_cnt' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 220 , 4 , 'little' , 'unsigned' )

		inspector_info[ 'total_time_thermal_mgmt_temp_1' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 224 , 4 , 'little' , 'unsigned' )

		inspector_info[ 'total_time_thermal_mgmt_temp_2' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 228 , 4 , 'little' , 'unsigned' )

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0x02' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0x02' ][ inspector_time_stamp ] = inspector_info

		unless smart_warnings_data == 0 || @test_info[ :enable_smart_checking ] == false

			smart_warnings = [] ; fatal = false

			# Figure 194: Get Log Page – SMART / Health Information Log : Critical Warning
			smart_warning_descriptions = [ 'available spares below thershold' , 'exceeded temperature threshold' , 'nvme subsystem degraded' , 'media set to read-only' , 'volatile memory backup failure' , 'persistent memory region degraded' ]

			bit_counter = -1

			smart_warnings_bit_array = ( ( "%08b" % smart_warnings_data ).split( '' ) ).reverse

			smart_warnings_bit_array.each do |bit|

				bit_counter += 1

				next if bit.to_i == 0

				# Ignores exceeded temperature threshold warning
				unless bit_counter == 1 ; force_failure( category: 'smart_warning' , data: smart_warning_descriptions[ bit_counter ].to_s ) ; end
			end
		end

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 512 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# Gets and displays Log Page 03h Firmware Slot Information
	# This log page is not archived
	def get_log_page_03h( log: false , dump_logs: false , display: true )

		unless @drive_info[ :data_current ] == true ; return ; end

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_03_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' +@drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , '03' , filename.to_s ] ) ; log()
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , '03' ] ) ; log()
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page 03h Firmware Slot Information
		# 03h length data length is 512 bytes ; bytes 511:232 are reserved
		# 512 bytes / 4 = 128 ( 0x80 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x00800003 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end

		inspector_info = {}

		inspector_info[ 'active_firmware_info_(afi)' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 0 , 1 , 'little' , 'unsigned' )

		# NVME spec allows for slot 1 - 7
		offsets = [ 8 , 16 , 24 , 32 , 40 , 48 , 56 ]

		# Current drives only have slots 1 - 4 populated
		#offsets = [ 8 , 16 , 24 , 32 ]

		slot = 1

		offsets.each do |offset|

			data = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , offset , 8 , 'big' , 'unsigned' )

			# Convert to ASCII string
			fw_string = data.to_s(16).gsub(/../) { |pair| pair.hex.chr }

			if display == true && fw_string.to_s != '0' ; f_log( [ 'INFO' , 'FW SLOT' , slot.to_s , fw_string ] ) ; end

			inspector_info[ 'firmware_revision_for_slot_' + slot.to_s + '_(frs' + slot.to_s + ')' ] = fw_string

			slot += 1
		end

		if display == true ; log() ; end

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 512 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0x03' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0x03' ][ inspector_time_stamp ] = inspector_info

		@error_info[ :pending_failure_info ] = 'NA'
	end

	# AMAZON Specific : AWS Customer Unique SMART Log Page (0xD0)
	def get_log_page_D0h_AWS( log: nil , dump_logs: nil )

		unless @drive_info[ :customer ].include?( 'AMAZON' ) ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_D0-AWS_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'D0-AWS' , filename.to_s ] ) ; log()
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , 'D0-AWS' ] ) ; log()
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get log_page D0h
		# 512 bytes / 4 = 128 ( 0x80 ) DWORDS
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x008000D0 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 512 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		inspector_info = {}

		inspector_info[ 'lifetime_reallocated_erase_block_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_power_on_hours' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 8 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_uecc_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 12 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_write_amplification_factor' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 16 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'trailing_hour_write_amplification_factor' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 20 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'reserve_erase_block_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 24 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_program_fail_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 28 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_block_erase_fail_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 32 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_die_failure_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 36 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_link_rate_downgrade_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 40 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_clean_shutdown_count_on_power_loss' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 44 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_unclean_shutdowns_on_power_loss' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 48 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'current_temperature' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 52 , 4 , 'little' , 'signed' )
		inspector_info[ 'max_recorded_temperature' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 56 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_retired_block_count' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 60 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_read_disturb_reallocation_events' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 64 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_nand_writes' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 68 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'capacitor_health' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 76 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_user_writes' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 80 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_user_reads' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 88 , 8 , 'little' , 'unsigned' )
		inspector_info[ 'lifetime_thermal_throttle_activations' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 96 , 4 , 'little' , 'unsigned' )
		inspector_info[ 'percentage_of_pe_cycles_remaining' ] = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 100 , 4 , 'little' , 'unsigned' )

		inspector_time_stamp = Time.now.strftime( "%Y/%m/%d %H:%M:%S" ).to_s

		@inspector_info[ :log_pages ][ '0xD0' ][ inspector_time_stamp ] = {}

		@inspector_info[ :log_pages ][ '0xD0' ][ inspector_time_stamp ] = inspector_info

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , 512 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# This log page is not currently used
	def get_log_page_0Dh( log: nil , dump_logs: nil )

		unless @drive_info[ :persistent_event_log_supported ] == true ; return ; end

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		filename = 'ANGEL_0D_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true

			if dump_logs == true

				f_log( [ 'FUNC' , 'GET LOG PAGE' , '0D' , filename.to_s ] ) ; log()
			else
				f_log( [ 'FUNC' , 'GET LOG PAGE' , '0D' ] ) ; log()
			end
		end

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		# Get Log Page 0Dh Persistent Event Log Page

		# Clear current context
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x00020D , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 0 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		# Create context and get log page size
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0x10010D , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 16 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		log_page_size_bytes = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 8 , 8 , 'little' , 'unsigned' )

		# Get log page 0Dh
		rc = $angel.nvme_custom_command( 0x02 , 0xFFFFFFFF , 0xFF000D , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , log_page_size_bytes.to_i )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

		if dump_logs == true

			# Dump the data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , log_page_size_bytes.to_i , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# This is used to display log pages retrieved in post-script-handler
			unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	# Gets the drive's high temp thershold
	def  get_drive_temp_thershold()

		# Clear Buffer
		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		sel = 2 ; fid = 0x4 ; dw10 = ( sel << 8 ) | fid

		# Get Features
		rc = $angel.nvme_custom_command( 0xA , 1 , dw10, 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

		temp_thershold = ( ( $angel.get_last_nvme_admin_command_result ).to_f - 273.15 ).to_i

		return temp_thershold
	end

	# Gets & creates an HTML file illustrating the drive eye diagram
	# Calls eye_surf
	def get_eye_diagram( log: true )

		unless @test_info[ :get_eye_diagram ] == true ; return ; end

		@error_info[ :pending_failure_info ] = __method__.to_s

		if @test_info[ :port_configuration ].to_s == '2x2' ; ports = [ 'PORTA' , 'PORTB' ] ; else ; ports = [ 'PORTA' ] ; end

		eye_data_8gts = [ 0xed , 0x06 , 0x1c , 0x00 , 0x01 , 0x00 , 0x03 , 0x00 , 0xec , 0xff , 0x14 , 0x00 , 0x01 , 0x00 , 0xe1 , 0xff , 0x1f , 0x00 , 0x01 , 0x00 , 0x80 , 0x96 , 0x98 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 ]

		port_id = 'PORTA'

		@drive_info[ :ctrl_id ].each do |ctrl_id|

			if	ctrl_id == @drive_info[ :ctrl_id ][0]

				$angel.set_sas_port_mode( AngelCore::Port_A_Only )

			elsif	ctrl_id == @drive_info[ :ctrl_id ][1]

				$angel.set_sas_port_mode( AngelCore::Port_B_Only )
			end

			# Clear Buffer
			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			$angel.buffer.set_array( eye_data_8gts , @test_info[ :functions_buffer_id ] , 0 , 28 )

			rc = $angel.nvme_custom_command( 0xD9 , 0x0 , 0x7 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 28 )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

			0.upto( 3 ) do |phy|
		
				filename = 'ANGEL_EYE-DIAGRAM-' + port_id + '-PHY' + phy.to_s + '_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s

				unless log == false ; f_log( [ 'FUNC' , 'GET EYE DIAGRAM' , port_id + ' - PHY' + phy.to_s , filename.to_s + '.html' ] ) ; end

				# Clear Buffer
				$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

				rc = $angel.nvme_custom_command( 0xDA , 0x0 , 0x148C , 0 , 0 , phy , 0 , 0 , @test_info[ :functions_buffer_id ] , 21040 )

				unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

				# Dump the data buffer to file
				rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename.to_s + '.bin' , 21040 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

				unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

				cmd = $test_info.home_directory + 'eye_surf --no-browser -f ' + $test_info.home_directory + filename.to_s + '.bin --output-filename ' + $test_info.home_directory + filename.to_s + '.html'

				rc = %x( #{ cmd } )

				unless rc.include?( 'data written to ' + $test_info.home_directory + filename.to_s + '.html' ) ; _warning_counter( category: 'get_eye_diagram_error' , data: 'unable to decode eye diagram data' ) ; end

				begin
					File.delete( $test_info.home_directory + filename.to_s + '.bin' ) if File.exists?( $test_info.home_directory + filename.to_s + '.bin' )

				rescue StandardError => error

					_warning_counter( category: 'get_eye_diagram_error' , data: error.to_s )
				end
			end

			port_id = 'PORTB'
		end

		if $test_info.genesis_hd_config.to_s == 'U.2 Dual' ; $angel.set_sas_port_mode( AngelCore::Port_Toggle ) ; end

		unless log == false ; log() ; end

		@error_info[ :pending_failure_info ] = 'NA'
	end

	# Sets queue depth to queue_depth
	# Calls Functions::_get_max_block_tx_size
	def enable_queuing( queue_depth: nil , log: false )

		return if @test_info[ :enable_queuing ] == false || queue_depth <= 0

		if @test_info[ :queue_depth ].to_i > 0 ; disable_queuing( log: false ) ; end

		$angel.enable_queue_operation( queue_depth )

		@test_info[ :queue_depth ] = queue_depth

		_get_max_block_tx_size()

		unless log == false ; f_log( [ 'FUNC' , 'ENABLED' , 'QUEUE DEPTH' , queue_depth.to_s , 'MAX BLOCK TX SIZE' , @test_info[ :max_blocks_per_io ].to_s + ' BLOCKS' + "\n" ] ) ; end
	end

	# Disables queuing
	# Calls Functions::_get_max_block_tx_size
	def disable_queuing( log: false )

		return if @test_info[ :enable_queuing ] == false

		$angel.disable_queue_operation()

		@test_info[ :queue_depth ] = 0

		_get_max_block_tx_size()

		unless log == false ; f_log( [ 'INFO' , 'QUEUING' , 'DISABLED' , 'MAX BLOCK TX SIZE' , @test_info[ :max_blocks_per_io ].to_s + "\n" ] ) ; end
	end

	# Gets the drives E6 log
	# if option 'log' is true a message is written to the script-trace
	# @return filename
	def get_e6( log: true , mode: 'E6' )

		@error_info[ :pending_failure_info ] = __method__.to_s

		if	mode == 'E6'

			dword_12 = 0x0

			filename = 'ANGEL_E6_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

			text = 'E6'

			data_transfer_size = [ @drive_info[ :max_bytes_per_io ] , 25000000 ].min

			data_size = 0

		elsif	mode == '3E'

			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			dword_12 = 0x3E

			filename = 'ANGEL_3E_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

			text = '3E'

			data_transfer_size = 512

			rc = $angel.nvme_custom_command( 0xE6 , 0 , ( data_transfer_size / 4 ) , 0x0 , dword_12 , 0 , 0x0 , 0x0 , @test_info[ :functions_buffer_id ] , data_transfer_size )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

			data_size = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 4 , 'big' , 'unsigned' )

			data_transfer_size = data_size
		end

		if log == true ; f_log( [ 'FUNC' , 'GET LOG PAGE' , text , filename + "\n" ] ) ; end

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		offset = 0

		until ( offset == data_size && offset != 0 )

			# Get E6 Data
			# Command DWORD-10 is length of data to get in DWORDS ( bytes / 4 )
			# Command DWORD-13 is the starting offset in DWORDS ( bytes / 4 )
			rc = $angel.nvme_custom_command( 0xE6 , 0 , ( data_transfer_size / 4 ) , 0x0 , dword_12 , ( offset / 4 ) , 0x0 , 0x0 , @test_info[ :functions_buffer_id ] , data_transfer_size )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

			# Dump the E6 data buffer to file
			rc = $angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , filename , data_transfer_size , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# Get E6 size in bytes
			if mode == 'E6' && offset == 0 ; data_size = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 4 , 4 , 'big' , 'unsigned' ) ; end

			offset += data_transfer_size

			if ( data_size - offset ) < data_transfer_size ; data_transfer_size = ( data_size - offset ) ; end
		end

		if @test_info[ :status ] == 'failed' && mode == nil ; @test_logs[ :shack_builder_e6 ] = 'FILE:' + filename ; end

		@error_info[ :pending_failure_info ] = 'NA'

		unless @test_info[ :status ] == 'testing' ; @test_logs[ :post ].push( filename ) ; end

		return filename.to_s
	end

	def format_nvme_cli( options: nil , power_cycle: true )

		#4096 + 64B : -n 0xffffffff -l 4 -f -m 1

		@error_info[ :pending_failure_info ] = __method__.to_s

		cmd = '/home/everest/angel_bin/nvme-cli format ' + @drive_info[ :ctrl_id ][0].to_s + ' ' + options.to_s

		f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

		rc = ( %x( #{ cmd } ) ).chomp

		unless rc.to_s.downcase.include?( 'success' ) ; force_failure( category: 'nvme_cli_command_failure' , data: cmd.to_s + ' : ' + rc.to_s ) ; end

		@error_info[ :pending_failure_info ] = 'NA'

		if power_cycle == true 

			power_cycle()
		else
			# get_drive_info( log = false , dump_logs = false , get_e6 = false )
			get_drive_info( log: false , dump_logs: true , get_e6: false )
		end
	end

	# NVMe Format modified from from nvme_utility
	def nvme_format( block_size: nil , power_cycle: true )

		unless @drive_info[ :data_current ] == true ; return ; end

		@error_info[ :pending_failure_info ] = __method__.to_s

		namespace = 0xFFFFFFFF ; lbaf = -1 ; ses = -1 ; pil = -1 ; pi = -1 ; mset = -1

		current_block_size = 0 ; current_mset = 0 ; current_lbaf = 0 ; current_ses = 0 ; current_pil = 0 ; current_pi = 0

		$angel.add_core_log_entry( 'nvme_format: Input BS=' + block_size.to_s + ' NS=' + namespace.to_s + ' LBAF=' + lbaf.to_s + ' SES=' + ses.to_s + ' PIL=' + pil.to_s + ' PI=' + pi.to_s + ' MSET=' + mset.to_s )

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		rc = $angel.nvme_custom_command( 0x06 , namespace , 0 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end

		# Get FLBAS ( Formatted LBA Size ) to determine which format is used
		flbas = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 26 , 1 , 'little' , 'unsigned' )

		# Get blocksize from LBAF structure
		lbaf_location = 128 + ( 4 * ( flbas & 0x0f ) )

		ms = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , lbaf_location , 2 , 'little' , 'unsigned' )

		ds = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , lbaf_location + 2 , 1 , 'little' , 'unsigned' )

		current_block_size = 2**ds

		if block_size == nil ; block_size = @drive_info[ :block_size ].to_i ; end

		f_log( [ 'FUNC' , 'FORMAT DRIVE' , block_size.to_s + "\n" ] )

		if ( ( flbas & 0x10 ) > 0 ) ; current_block_size = current_block_size + ms ; end

		current_lbaf = flbas & 0x0f

		current_mset = ( flbas & 0x10 ) >> 4

		dps = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 29 , 1 , 'little' , 'unsigned' )

		current_pi = dps & 0x07

		current_pil = ( dps & 0x08 ) >> 3

		# Fill in format parameters
		if mset == -1 ; mset = current_mset ; end
		if ses == -1  ; ses = current_ses   ; end
		if pil == -1  ; pil = current_pil   ; end
		if pi == -1   ; pi = current_pi     ; end

		if block_size > 0

			new_ms = block_size % 512
			new_bs = block_size / 512
			new_bs = new_bs * 512
			new_ds = 0

			case new_bs

				when 512  ; new_ds = 9
				when 1024 ; new_ds = 10
				when 2048 ; new_ds = 11
				when 4096 ; new_ds = 12
				when 8192 ; new_ds = 13
				else	  ; new_ds = 0

				$angel.add_core_log_entry( 'nvme_format: Invalid data size - Blocksize=' + block_size.to_s )
			end

			if new_ds > 0

				nlbas = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 25 , 1 , 'little' , 'unsigned' )

				found_format = -1

				format_number = 0

				while format_number <= nlbas

					format_ds = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 128 + ( format_number * 4 ) + 2 , 1 , 'little' , 'unsigned' )

					format_ms = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 128 + ( format_number * 4 ) , 2 , 'little' , 'unsigned' )

					$angel.add_core_log_entry( 'nvme_format: LBAF table I=' + format_number.to_s + ' DS=' + format_ds.to_s + ' MS=' + format_ms.to_s )

					if new_ds == format_ds && new_ms == format_ms ; found_format = format_number ; end

					format_number = format_number + 1
				end

				if found_format >= 0

					$angel.add_core_log_entry( 'nvme_format: LBA Format Selected ' + found_format.to_s )

					lbaf = found_format
				else
					$angel.add_core_log_entry( 'nvme_format: Unable to find LBA Format for Blocksize ' + block_size.to_s )
				end
			end
		end

		if lbaf == -1 ; lbaf = current_lbaf ; end

		$angel.add_core_log_entry( 'nvme_format: Parameters BS=' + block_size.to_s + ' NS=' + namespace.to_s + ' LBAF=' + lbaf.to_s + ' SES=' + ses.to_s + ' PIL=' + pil.to_s + ' PI=' + pi.to_s + ' MSET=' + mset.to_s )

		# Put all values into DW10
		cw10 = 0
		cw10 |= ( ses & 0x03 ) << 9
		cw10 |= ( pil & 0x01 ) << 8
		cw10 |= ( pi & 0x03 ) << 5
		cw10 |= ( mset & 0x01 ) << 4
		cw10 |= ( lbaf & 0x0F )

		rc = $angel.nvme_custom_command( 0x80 , namespace , cw10 , 0 , 0 , 0 , 0 , 0 , 0 , 0 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end

		@drive_info[ :block_size ] = block_size

		$angel.wait( 'Seconds' , 10 )

		$angel.log.report_summary

		@error_info[ :pending_failure_info ] = 'NA'

		if power_cycle == true 

			power_cycle()
		else
			# get_drive_info( log = false , dump_logs = false , get_e6 = false )
			get_drive_info( log: false , dump_logs: true , get_e6: false )
		end
	end

	# Issues TDD
	# TDD file must be in the launch directory
	# @return filename
	def tdd( tdd: nil , log: true )

		unless @test_info[ :enable_tdds ] == true ; return ; end

		unless tdd.include?( '.bin' ) ; tdd += '.bin' ; end

		tdd_name = tdd.split( '.' )[0]

		_get_tdd_files( tdd: tdd )

		FileUtils.copy( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tdds/' + tdd.to_s , $test_info.home_directory )

		filename = 'ANGEL_' + ( tdd_name.to_s.tr( '_' , '-' ).upcase ) + '_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.txt'

		if log == true ; f_log( [ 'FUNC' , 'TDD' , tdd_name.to_s.upcase , filename + "\n" ] ) ; end

		$angel.check_instruction

		rc = Sbdi_angel.run_tdd( ( $angel.core.get_drive_command() ) , $test_info.home_directory + tdd.to_s , $test_info.home_directory + filename.to_s )

		unless rc == 0 ; force_failure( category: 'get_tdd_failed' , data: tdd_name.to_s ) ; end

		$angel.check_instruction

		if File.size( $test_info.home_directory + filename.to_s ) == 0

			force_failure( category: 'get_tdd_failed' , data: tdd_name.to_s )
		end

		return filename.to_s
	end

	# Requires the TMM file & TDD tmm_lut.bin to be in the launch directory
	# unless overwrite_trim_file_value == 0 , requires TDD create_default_trim_reg_file.bin
	# Calls python script tdd_param.py, which modifies the tmm_lut TDD to use the tmm_file provide by the user
	# Loads the user defined tmm_file
	# A power cycle is required to enable the new TMM
	# overwrite_trim_file_value 2 is safe , overwrite_trim_file_value 1 may be necessary for some drives but will alter drive trim settings , overwrite_trim_file_value 0 skips this function
	def load_tmm( tmm: nil , power_cycle: true , overwrite_trim_file_value: 0 )

		unless @test_info[ :enable_tdds ] == true ; force_failure( category: 'load_tmm_failure' , data: 'TDDs ARE DISABLED & REQUIRED TO LOAD TMM' ) ; end

		unless tmm.include?( '.json' ) ; tmm += '.json' ; end

		_get_tmm_files( tmm: tmm.to_s )

		_get_tdd_files( tdd: 'tmm_lut.bin' )

		_get_tdd_files( tdd: 'create_default_trim_reg_file.bin' )

		FileUtils.copy( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tmms/' + tmm.to_s , $test_info.home_directory )

		FileUtils.copy( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tdds/tmm_lut.bin' , $test_info.home_directory )

		unless overwrite_trim_file_value == 0

			FileUtils.copy( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tdds/create_default_trim_reg_file.bin' , $test_info.home_directory )
		end

		f_log( [ 'FUNC' , 'LOAD TMM' , tmm.to_s + "\n" ] )

		# Read file to find version
		tmm_version = IO.binread( $test_info.home_directory + tmm.to_s , 9 , 0x41 )

		# Power cycle required when using overwrite_trim_file_value of 1 to ensure trim register values are the actual NAND defaults
		unless overwrite_trim_file_value == 0

			f_log( [ 'FUNC' , 'POWER CYCLE' , 'TO ENSURE TRIM VALUES ARE NAND DEFAULTS' + "\n" ] )

			# Do NOT use power_cycle() function as it will perform additional functions that will invalidate the trim register values
			$angel.check_instruction

			remove_device()

			f_log( [ 'FUNC' , 'POWER OFF' + "\n" ] )

			$power.off

			sync( type: 'drives' )

			f_log( [ 'FUNC' , 'POWER ON' + "\n" ] )

			$angel.power_on( 3.3 , 12.0 , true )

			@test_info[ :power_cycle_count ] += 1

			# Josh Ginter's example shows overwrite_file=2
			# WIKI for TDD create_default_trim_reg_file ( https://esswiki.wdc.com/display/ESSP/VH+create_default_trim_reg_file ) allows for overwrite_file=1
			# however you must guarantee that the trim register values are actual NAND defaults
			cmd = '/usr/bin/python /home/everest/angel_libs/sbdi/' + @test_info[ :angel_core ] + '/tdd_param.py ' + $test_info.home_directory + 'create_default_trim_reg_file.bin -a enable_uart_prints=1 overwrite_file=' + overwrite_trim_file_value.to_s

			f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

			begin
				rc = ssh( cmd: cmd ).chomp

			rescue StandardError => error

				_warning_counter( category: 'load_tmm_failure' , data: error.inspect )
			end

			unless rc == '' ; force_failure( category: 'load_tmm_failure' , data: rc.to_s ) ; end

			$angel.check_instruction

			filename = 'ANGEL_' + ( 'create_default_trim_reg_file_local'.to_s.tr( '_' , '-' ).upcase ) + '_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.txt'

			begin
				rc = Sbdi_angel.run_tdd( ( $angel.core.get_drive_command() ) , $test_info.home_directory.to_s + 'create_default_trim_reg_file.bin' , $test_info.home_directory + filename.to_s )

			rescue StandardError => error

				_warning_counter( category: 'load_tmm_failure' , data: error.inspect )
			end

			unless rc == 0 ; force_failure( category: 'load_tmm_failure' , data: rc.to_s ) ; end

			$angel.check_instruction
		end

		cmd = '/usr/bin/python /home/everest/angel_libs/sbdi/' + @test_info[ :angel_core ] + '/tdd_param.py ' + $test_info.home_directory.to_s + 'tmm_lut.bin -a enable_uart_prints=1 option=set filename=' + $test_info.home_directory + tmm.to_s

		f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

		rc = ssh( cmd: cmd ).chomp

		unless rc == '' ; force_failure( category: 'load_tmm_failure' , data: rc.to_s ) ; end

		$angel.check_instruction

		filename = 'ANGEL_' + ( 'tmm_lut_local'.to_s.tr( '_' , '-' ).upcase ) + '_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.txt'

		rc = Sbdi_angel.run_tdd( ( $angel.core.get_drive_command() ) , $test_info.home_directory + tmm.to_s , $test_info.home_directory + filename.to_s )

		unless rc == 0 ; force_failure( category: 'get_tdd_failed' , data: tmm_lut_tdd.to_s ) ; end

		$angel.check_instruction

		unless power_cycle == false ; power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting ) ; end

		$angel.check_instruction

		filename = 'ANGEL_' + ( 'tmm_lut'.to_s.tr( '_' , '-' ).upcase ) + '_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.txt'

		get_log_page_C2h( log: false , dump_logs: false )

		if tmm_version.to_s == @drive_info[ :tmm_version ].to_s

			f_log( [ 'INFO' , 'TMM UPDATED' , @drive_info[ :tmm_version ].to_s + "\n" ] )
		else
			force_failure( category: 'load_tmm_failure' , data: 'TMM FAILED TO UPDATE : ' + tmm_version.to_s + ' : ' + @drive_info[ :tmm_version ].to_s )
		end
	end

	# sends custom VUC to put drive into devprep mode
	# fw_customer_id is only required when changing FW types i.e. MS to MT
	# Calls Functions::firmware-download , loads new FW to slot 1 with commit 1 , skips remaining slots
	# Calls Functions::firmware-download , loads FW to all FW slots & activates slot 1 with commit 3 , no power cycle
	# Calls Functions::nvme_format with power cycle
	def dev_prep_p( firmware: nil , fw_customer_id: nil , format: nil , wait: 240 )

		if @test_info[ :port_configuration ].to_s == '2x2' ; _warning_counter( category: 'dev_prep_error' , data: 'DEVPREP IS ONLY SUPPORTED IN 1x4 MODE' ) ; return ; end

		f_log( [ 'INFO' , 'DEV-PREP-P' , 'STARTED' + "\n" ] )

		if fw_customer_id == nil ; fw_customer_id = @drive_info[ :fw_customer_id ] ; end

		f_log( [ 'FUNC' , 'ENABLE DEV-PREP-P' + "\n" ] )

		rc = $angel.nvme_custom_command( 0xF0 , 0x0 , 0 , 0 , 0x21A , 0 , 0 , 0 , 0 , 0 )

		unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; end

		skip = [ 2 , 3 , 4 ]

		firmware_download( firmware: firmware , fw_customer_id: fw_customer_id , firmware_slot: 1 , power_cycle: 'return' , commit_action: 1 , skip_slot: skip , disable_error_handler: true )

		f_log( [ 'INFO' , 'ERROR HANDLING' , 'DISABLED' , __method__.to_s.upcase + "\n" ] )

		$test_status.skip_error_handling = true

		power_off( check_status: false )

		$angel.wait( 'Seconds' , 10 )

		f_log( [ 'FUNC' , 'POWER ON' + "\n" ] )

		rc = $power.set_voltage( 3.3 , 12.0 )

		rc = $power.on_both

		f_log( [ 'INFO' , 'WAIT FOR DEV-PREP-P PROCESS TO COMPLETE' , wait.to_s + "\n" ] )

		$angel.wait( 'Seconds' , wait.to_i )

		f_log( [ 'FUNC' , 'POWER OFF' + "\n" ] )

		rc = $power.off

		$angel.wait( 'Seconds' , 10 )

		f_log( [ 'FUNC' , 'POWER ON' + "\n" ] )

		$angel.power_on_default

		$angel.wait( 'Seconds' , 10 )

		power_off( check_status: false )

		$angel.wait( 'Seconds' , 10 )

		f_log( [ 'INFO' , 'ERROR HANDLING' , 'ENABLED' , __method__.to_s.upcase + "\n" ] )

		$test_status.skip_error_handling = false

		power_on()

		firmware_download( firmware: firmware , fw_customer_id: fw_customer_id , firmware_slot: 1 , power_cycle: true , commit_action: 3 )

		unless format == nil ; nvme_format( block_size: format , power_cycle: true ) ; end

		f_log( [ 'INFO' , 'DEV-PREP-P' , 'COMPLETED' + "\n" ] )
	end

	# fw_customer_id is only required when changing FW types i.e. MS to MT
	# Extends the POR and General timeout values to 120000 msecs during this function, then sets them back to original settings
	# Performs a FW download to slots 1 - 4
	# Activates FW in the user defined FW slot
	# Calls Functions::power_cycle
	# Sets POR and General timeouts back to their original values
	# skip allows user to skip a FW slot ( L2C drives can not load to slot 1 )
	def firmware_download( firmware: nil , fw_customer_id: nil , firmware_slot: 1 , power_cycle: true , commit_action: 3 , skip_slot: -1 , disable_error_handler: false )

		@error_info[ :pending_failure_info ] = __method__.to_s

		if fw_customer_id == nil ; fw_customer_id = @drive_info[ :fw_customer_id ] ; end

		get_firmware_files( fw_version: firmware.to_s , fw_customer_id: fw_customer_id.to_s.upcase )

		firmware_file = Dir[ '/home/everest/angel_fw_repo/' + firmware.to_s.upcase + '/' + @drive_info[ :product_family ].to_s.downcase + '*' + fw_customer_id.to_s.upcase + '*.vpkg' ][0]

		unless File.exists?( firmware_file.to_s ) ; force_failure( category: 'file_not_found' , data: firmware_file.to_s ) ; end

		firmware_file_size = File.size( firmware_file ).to_i

		skip = [] ; if skip_slot.class.to_s == 'Array' ; skip = skip_slot ; else ; skip.push( skip_slot ) ; end

		# Commit Actions
		# 0 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is not activated.
		# 1 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is activated at the next Controller Level Reset.
		# 2 The existing image in the specified Firmware Slot is activated at the next Controller Level Reset.
		# 3 Downloaded image replaces the existing image in the specified Firmware Slot and is then activated immediately.
		# - If there is not a newly downloaded image, then the existing image in the specified firmware slot is activated immediately.

		$angel.set_timeout( 'por' , @test_info[ :timeout_fwdl ] )

		$angel.set_timeout( 'general' , @test_info[ :timeout_fwdl ] )

		$angel.buffer.clear( @test_info[ :read_buffer_id ] )

		rc = $angel.core.load_file( @test_info[ :read_buffer_id ] , firmware_file.to_s )

		unless rc == 0 ; force_failure( category: 'open_file_error' , data: rc.to_s ) ; end

		temp_file = $test_info.home_directory.to_s + 'temp_file.bin'

		if disable_error_handler == true

			f_log( [ 'INFO' , 'ERROR HANDLING' , 'DISABLED' , __method__.to_s.upcase + "\n" ] )

			$test_status.skip_error_handling = true
		end

		# FW Slots
		( 1 ).upto( 4 ) do |slot| 

			next if skip.include?( slot )

			if slot == firmware_slot ; commit = commit_action ; else ; commit = 0 ; end

			if commit == 0 ; text = 'FW DOWNLOAD' ; else ; text = 'FW-DL & COMMIT-' + commit.to_s ; end

			f_log( [ 'FUNC' , 'SLOT ' + slot.to_s , text , firmware.to_s ] )

			data_transfer_size = [ @drive_info[ :max_bytes_per_io ] , 25000000 ].min

			offset = 0

			until ( offset == firmware_file_size && offset != 0 )

				$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

				rc = $angel.buffer.dump_buffer_with_offset( @test_info[ :read_buffer_id ] , offset , 'temp_file.bin' , data_transfer_size , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

				unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

				rc = $angel.core.load_file( @test_info[ :functions_buffer_id ] , temp_file.to_s )

				unless rc == 0 ; force_failure( category: 'open_file_error' , data: rc.to_s ) ; end

				# Firmware image download
				rc = $angel.nvme_custom_command( 0x11 , 0 , ( data_transfer_size >> 2 ) - 1 , offset >> 2 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , data_transfer_size )

				unless rc == 0 ; force_failure( category: 'firmware_download_failure' , data: rc.to_s ) ; end

				offset += data_transfer_size

				if ( firmware_file_size - offset ) < data_transfer_size ; data_transfer_size = ( firmware_file_size - offset ) ; end
			end

			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			# Firmware commit
			dw10 = ( commit << 3 ) | slot ; rc = $angel.nvme_custom_command( 0x10 , 0 , dw10 , 0 , 0 , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 0 )

			if rc != 0 && disable_error_handler != true ; force_failure( category: 'firmware_download_failure' , data: rc.to_s ) ; end
		end

		if $test_status.skip_error_handling == true

			f_log( [ "\n" + 'INFO' , 'ERROR HANDLING' , 'ENABLED' , __method__.to_s.upcase ] )

			$test_status.skip_error_handling = false
		end

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )
		$angel.buffer.clear( @test_info[ :read_buffer_id ] )

		File.delete( temp_file.to_s )

		@error_info[ :pending_failure_info ] = 'NA'

		@test_info[ :firmware_updated ] = true

		$angel.set_timeout( 'por' , @test_info[ :timeout_por ] )

		$angel.set_timeout( 'general' , @test_info[ :timeout_general ] )

		@test_info[ :parametric_offsets ] = nil

		log()

		@test_info[ :parametric_offsets ] = nil

		if	power_cycle == 'return'

			return

		elsif 	power_cycle == true

			power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting )

		elsif	power_cycle.is_a? Integer

			1.upto( power_cycle.to_i - 1 ) do

				if @test_info[ :enable_power_control ] == true

					pwr_5v = $power.get_5v_setting

					pwr_12v = $power.get_12v_setting

					power_off( unsafe: false , check_status: false , duration_off: 10 )

					rc = -1 ; no_wait = true

					sleep 10

					if $test_info.genesis_hd_config.to_s.upcase == 'M.2' ; pwr_12v = 0.0 ; end

					@test_info[ :power_cycle_count ] += 1

					f_log( [ 'FUNC' , 'POWER ON (' + @test_info[ :power_cycle_count ].to_s + ')' , pwr_5v.to_s + ' , ' + pwr_12v.to_s + "\n" ] )

					# power_on(volt5, volt12, no_wait = false) ⇒ Integer
					# no_wait (Boolean) (defaults to: false) — if true, client doesn't report waiting for spin up status and continue
					rc = $angel.power_on( pwr_5v , pwr_12v , no_wait )

					unless rc == 0 ; force_failure( category: 'por_timeout' ) ; end
				end

				power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting )
			end
		else
			# get_drive_info( log = false , dump_logs = false , get_e6 = false )
			get_drive_info( log: false , dump_logs: true , get_e6: false )
		end
	end

	# fw_customer_id is only required when changing FW types i.e. MS to MT
	def dev_prep_p_nvme_cli( firmware: nil , fw_customer_id: nil , format: nil , wait: 240 )

		if @test_info[ :port_configuration ].to_s == '2x2' ; _warning_counter( category: 'dev_prep_error' , data: 'DEVPREP IS ONLY SUPPORTED IN 1x4 MODE' ) ; return ; end

		if fw_customer_id == nil ; fw_customer_id = @drive_info[ :fw_customer_id ] ; end

		f_log( [ 'INFO' , 'DEV-PREP-P' , 'STARTED' + "\n" ] )

		# example : /home/everest/angel_bin/nvme-cli admin-passthru --opcode=0xF0 --cdw12=0x21a /dev/nvme0
		cmd = '/home/everest/angel_bin/nvme-cli admin-passthru --opcode=0xF0 --cdw12=0x21a ' + @drive_info[ :ctrl_id ][0].to_s + ' 2>&1'

		f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

		rc = ( %x( #{ cmd } ) ).chomp

		unless rc.to_s.downcase.include?( 'success' ) ; force_failure( category: 'firmware_download_failure' , data: cmd.to_s + ' : ' + rc.to_s ) ; end

		skip = [ 2 , 3 , 4 ]

		firmware_download_nvme_cli( firmware: firmware , fw_customer_id: fw_customer_id , firmware_slot: 1 , power_cycle: 'return' , commit_action: 1 , skip_slot: skip )

		f_log( [ 'INFO' , 'ERROR HANDLING' , 'DISABLED' , __method__.to_s.upcase + "\n" ] )

		$test_status.skip_error_handling = true

		power_off( check_status: false )

		$angel.wait( 'Seconds' , 10 )

		f_log( [ 'FUNC' , 'POWER ON' + "\n" ] )

		rc = $power.set_voltage( 3.3 , 12.0 )

		rc = $power.on_both

		f_log( [ 'INFO' , 'WAIT FOR DEV-PREP-P PROCESS TO COMPLETE' , wait.to_s + "\n" ] )

		$angel.wait( 'Seconds' , wait.to_i )

		f_log( [ 'FUNC' , 'POWER OFF' + "\n" ] )

		rc = $power.off

		$angel.wait( 'Seconds' , 10 )

		f_log( [ 'FUNC' , 'POWER ON' + "\n" ] )

		$angel.power_on_default

		$angel.wait( 'Seconds' , 10 )

		power_off( check_status: false )

		$angel.wait( 'Seconds' , 10 )

		power_on()

		f_log( [ 'INFO' , 'ERROR HANDLING' , 'ENABLED' , __method__.to_s.upcase + "\n" ] )

		$test_status.skip_error_handling = false

		firmware_download_nvme_cli( firmware: firmware , fw_customer_id: fw_customer_id , firmware_slot: 1 , power_cycle: true , commit_action: 3 )

		unless format == nil ; nvme_format( block_size: format , power_cycle: true ) ; end

		f_log( [ 'INFO' , 'DEVPREP' , 'COMPLETED' + "\n" ] )
	end

	def firmware_download_nvme_cli( firmware: nil , fw_customer_id: nil , firmware_slot: 1 , power_cycle: true , commit_action: 3 , skip_slot: -1 )

		@error_info[ :pending_failure_info ] = __method__.to_s

		if fw_customer_id == nil ; fw_customer_id = @drive_info[ :fw_customer_id ] ; end

		get_firmware_files( fw_version: firmware.to_s , fw_customer_id: fw_customer_id.to_s.upcase )

		firmware_file = Dir[ '/home/everest/angel_fw_repo/' + firmware.to_s.upcase + '/' + @drive_info[ :product_family ].to_s.downcase + '*' + fw_customer_id.to_s.upcase + '*.vpkg' ][0]

		unless File.exists?( firmware_file.to_s ) ; force_failure( category: 'file_not_found' , data: '/home/everest/angel_fw_repo/' + firmware.to_s.upcase + '/' + @drive_info[ :product_family ].to_s.downcase + '*' + fw_customer_id.to_s.upcase + '*.vpkg' ) ; end

		skip = [] ; if skip_slot.class.to_s == 'Array' ; skip = skip_slot ; else ; skip.push( skip_slot ) ; end

		# Commit Actions
		# 0 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is not activated.
		# 1 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is activated at the next Controller Level Reset.
		# 2 The existing image in the specified Firmware Slot is activated at the next Controller Level Reset.
		# 3 Downloaded image replaces the existing image in the specified Firmware Slot and is then activated immediately.
		# - If there is not a newly downloaded image, then the existing image in the specified firmware slot is activated immediately.

		$angel.set_timeout( 'por' , @test_info[ :timeout_fwdl ] )

		$angel.set_timeout( 'general' , @test_info[ :timeout_fwdl ] )

		# FW Slots
		( 1 ).upto( 4 ) do |slot| 

			next if skip.include?( slot )

			if slot == firmware_slot ; commit = commit_action ; else ; commit = 0 ; end

			# example : /home/everest/angel_bin/nvme-cli fw-download /dev/nvme0 --fw=/home/everest/angel_fw_repo/LC100015/coffeebay_AD.vpkg
			cmd = '/home/everest/angel_bin/nvme-cli fw-download ' + @drive_info[ :ctrl_id ][0].to_s + ' --fw=' + firmware_file.to_s + ' 2>&1'

			f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

			rc = ( %x( #{ cmd } ) ).chomp

			unless rc.downcase.include?( 'success' ) ; force_failure( category: 'firmware_download_failure' , data: cmd.to_s + ' : ' + rc.to_s ) ; end

			# example : /home/everest/angel_bin/nvme-cli fw-commit /dev/nvme0 --slot=1 --action=3
			cmd = '/home/everest/angel_bin/nvme-cli fw-commit ' + @drive_info[ :ctrl_id ][0].to_s + ' --slot=' + slot.to_s + ' --action=' + commit.to_s + ' 2>&1'

			f_log( [ 'FUNC' , cmd.to_s + "\n" ] )

			rc = ( %x( #{ cmd } ) ).chomp

			unless rc.downcase.include?( 'success' ) ; force_failure( category: 'firmware_download_failure' , data: cmd.to_s + ' : ' + rc.to_s ) ; end
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@test_info[ :firmware_updated ] = true

		$angel.set_timeout( 'por' , @test_info[ :timeout_por ] )

		$angel.set_timeout( 'general' , @test_info[ :timeout_general ] )

		@test_info[ :parametric_offsets ] = nil

		if	power_cycle == 'return'

			return

		elsif	power_cycle == true

			power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting )

		elsif	power_cycle.to_i > 1

			1.upto( power_cycle.to_i - 1 ) do

				if @test_info[ :enable_power_control ] == true

					pwr_5v = $power.get_5v_setting

					pwr_12v = $power.get_12v_setting

					power_off( unsafe: false , check_status: false , duration_off: 10 )

					rc = -1 ; no_wait = true

					sleep 10

					if $test_info.genesis_hd_config.to_s.upcase == 'M.2' ; pwr_12v = 0.0 ; end

					@test_info[ :power_cycle_count ] += 1

					f_log( [ 'FUNC' , 'POWER ON (' + @test_info[ :power_cycle_count ].to_s + ')' , pwr_5v.to_s + ' , ' + pwr_12v.to_s + "\n" ] )

					# power_on(volt5, volt12, no_wait = false) ⇒ Integer
					# no_wait (Boolean) (defaults to: false) — if true, client doesn't report waiting for spin up status and continue
					rc = $angel.power_on( pwr_5v , pwr_12v , no_wait )

					unless rc == 0 ; force_failure( category: 'por_timeout' ) ; end
				end
			end

			power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting )
		else
			# get_drive_info( log = false , dump_logs = false , get_e6 = false )
			get_drive_info( log: false , dump_logs: true , get_e6: false )
		end
	end

	# Searches 'host_log.txt' to get the GroupID
	# @return  host_log_group_id.to_s
	def get_group_id()

		host_log_data = _get_host_log_data()

		if host_log_data == nil ; force_failure( category: 'file_not_found' ) ; end

		host_log_group_id = ( host_log_data.grep( /GroupID/ ) )[0].chomp

		host_log_group_id = host_log_group_id.split( ',' )[-1]

		return host_log_group_id.to_s
	end

	# Sets chamber temperature
	def set_chamber_temp( temp: nil , time_limit: 0 , sync: false )

		if @tester_info[ :tester_type ] == 'PSTAR'

			f_log( [ 'FUNC' , 'DRIVE' , 'SET TEMP' , ( '%02d' % temp ).to_s + "\n" ] )

			rc = $angel.set_drive_temperature( temp.to_f )

			unless rc == true ; _warning_counter( category: 'set_drive_temp' , data: 'BAD RC ( ' + rc.to_s.upcase + ' ) ' ) ; end

			return
		end

		unless @test_info[ :enable_chamber_control ] == true ; return ; end

		status = $test_status.chamber_control_state

		if status == 'OFF' ; _warning_counter( category: 'chamber_control_error' , data: 'CHAMBER CONTROL ' + status.to_s ) ; return ; end

		f_log( [ 'FUNC' , 'CHAMBER' , 'SET TEMP' , ( '%02d' % temp ).to_s + 'C ' + time_limit.to_s + ' SECONDS' + "\n" ] )

		@test_info[ :chamber_set_temp_info ] = '( ' + temp.to_s + 'C ' + time_limit.to_s + ' SECONDS )'

		$angel.set_chamber_temperature( temp , time_limit )

		if sync == true ; sync( type: 'chamber' ) ; end
	end

	# Searches 'host_log.txt' to get the log directory time stamp
	# @return log_directory name ( no path )
	def get_log_directory()

		host_log_data = _get_host_log_data()

		if host_log_data == nil ; _warning_counter( category: 'get_log_directory_error' ) ; return ; end

		host_log_start_date = ( host_log_data.grep( /StartDate/ ) )[0].chomp

		host_log_start_date = host_log_start_date.split( ',' )[-1]

		log_directory = 'Log_' + @drive_info[ :sn ].to_s + '_' + host_log_start_date[0..7].to_s + '-' + host_log_start_date[8..15]

		if log_directory == nil ; _warning_counter( category: 'get_log_directory_error' ) ; return ; end

		@test_info[ :log_directory ] = log_directory

		return log_directory
	end

	def get_test_logs_hash( key: nil )

		if key == nil ; return @test_logs ; else ; return @test_logs[ key.to_sym ] ; end
	end

	def get_drive_info_hash( key: nil )

		if key == nil ; return @drive_info ; else ; return @drive_info[ key.to_sym ] ; end
	end

	def get_test_info_hash( key: nil )

		if key == nil ; return @test_info ; else ; return @test_info[ key.to_sym ] ; end
	end

	def get_sql_info_hash( key: nil )

		if key == nil ; return @sql_info ; else ; return @sql_info[ key.to_sym ] ; end
	end

	def get_uart_info_hash( key: nil )

		if key == nil ; return @uart_info ; else ; return @uart_info[ key.to_sym ] ; end
	end

	def get_namespace_info_hash( nsid: nil , key: nil )

		if ( nsid == nil || key == nil ) ; return @namespace_info ; else ; return @namespace_info[ nsid.to_i ][ key.to_sym ] ; end
	end

	def get_zone_info_hash( nsid: @drive_info[ :zoned_namespace ] , zone_id: nil , key: nil )

		refresh_zone_info( nsid: nsid )

		if ( nsid == nil || zone_id == nil || key == nil ) ; return @zone_info ; else ; return @zone_info[ nsid.to_i ][ zone_id.to_i ][ key.to_sym ] ; end
	end

	# Sets chamber humidity
	def set_chamber_humidity( humidity: nil )

		unless @test_info[ :enable_chamber_control ] == true ; return ; end

		status = $test_status.chamber_control_state

		if status == 'OFF' ; _warning_counter( category: 'chamber_control_error' , data: 'CHAMBER CONTROL ' + status.to_s ) ; return ; end

		f_log( [ 'FUNC' , 'CHAMBER' , 'SET HUMIDITY' , humidity.to_s + "\n" ] )

		$angel.set_chamber_humidity( humidity )
	end

	# Waits for chamber temp and / or drives to complete there instructions
	# Calls $angel.sync_with_chamber if enable_sync_control == true && ( option == 'both' || option == 'chamber' )
	# Calls $angel.sync_with_other_cells if ( option == 'both' || option == 'drives' )
	# writes start and completion of syncs to /home/everest/sync.log
	def sync( type: 'both' )

		unless @test_info[ :enable_sync_control ] == true ; return ; end

		if @tester_info[ :tester_type ] == 'PSTAR'

			if type == 'chamber' ; return ; end

			if type == 'both' ; type = 'drives' ; end
		end

		if @test_info[ :enable_chamber_control ] == false && type == 'both' ; type = 'drives' ; end

		if @test_info[ :enable_chamber_control ] == false && type == 'chamber' ; return ; end

		status = $test_status.chamber_control_state

		group_id = get_group_id()

		if status == 'OFF' && ( type == 'chamber' || type == 'both' ) ; _warning_counter( category: 'chamber_control_error' , data: 'CHAMBER CONTROL ' + status.to_s ) ; return ; end

		text = type.upcase.to_s

		if type.to_s == 'chamber' || type.to_s == 'both' ; text += ' ' + @test_info[ :chamber_set_temp_info ].to_s ; end

		f_log( [ 'INFO' , 'SYNC (' + group_id.to_s + ':' + @test_info[ :sync_counter ].to_s + ')' , text.upcase.to_s + "\n" ] )

		@test_info[ :chamber_set_temp_info ] = nil

		if @test_info[ :enable_chamber_control ] == true && ( type == 'both' || type == 'chamber' )

			log( data: $test_info.cell_number.to_s + ' : ' + group_id + ' : ' + @test_info[ :sync_counter ].to_s + ' : SYNC CHAMBER' , debug_level: 0 , file: 'sync.log' , dir: '/home/everest/angel_logs/' , option: 'a' )

			$angel.sync_with_chamber

			log( data: $test_info.cell_number.to_s + ' : ' + group_id + ' : ' + @test_info[ :sync_counter ].to_s + ' :-: ' + $test_status.current_status.to_s.upcase , debug_level: 0 , file: 'sync.log' , dir: '/home/everest/angel_logs/' , option: 'a' )
		end

		if ( type == 'both' || type == 'drives' )

			log( data: $test_info.cell_number.to_s + ' : ' + group_id + ' : ' + @test_info[ :sync_counter ].to_s + ' : SYNC DRIVES' , debug_level: 0 , file: 'sync.log' , dir: '/home/everest/angel_logs/' , option: 'a' )

			$angel.sync_with_other_cells

			log( data: $test_info.cell_number.to_s + ' : ' + group_id + ' : ' + @test_info[ :sync_counter ].to_s + ' :-: ' + $test_status.current_status.to_s.upcase , debug_level: 0 , file: 'sync.log' , dir: '/home/everest/angel_logs/' , option: 'a' )
		end

		@test_info[ :sync_counter ] += 1
	end

	# Gets the angel versions
	def get_angel_versions()

		rev_info_file = $test_info.home_directory + 'RevInfo.txt'

		rev_info_data = read_file( file: rev_info_file )

		# From /home/everest/angel_host/bin/package_ver.txt
		@test_info[ :angel_package ] = ( rev_info_data.grep( /Angel Package/ )[-1].split( ',')[-1] ).to_s

		# From /home/everest/angel_host/bin/AngelHost
		@test_info[ :angel_host ] = ( rev_info_data.grep( /Host/ )[-1].split( ',')[-1] ).to_s

		# From /home/everest/angel/angel.rb
		@test_info[ :angel_rb ] = ( rev_info_data.grep( /Client/ )[-1].split( ',')[-1] ).to_s

		# From /home/everest/angel_host/dtc/lib/libDriveTemperatureCorrection.so
		@test_info[ :dtc ] = ( rev_info_data.grep( /DTC/ )[-1].split( ',')[-1] ).to_s

		@test_info[ :angel_core ] = $test_info.core_version.to_s

		@test_info[ :power_manager ] = $test_info.power_manager_version.to_s
	end

	# Displays the angel versions
	def display_angel_versions( angel_versions: nil )

		if @test_info[ :angel_versions ] == nil ; get_angel_versions() ; end

		f_log( [ 'INFO' , 'ANGEL PACKAGE' , 'VERSION' , @test_info[ :angel_package ].to_s ] )
		f_log( [ 'INFO' , 'ANGEL CORE'    , 'VERSION' , @test_info[ :angel_core ].to_s ] )
		f_log( [ 'INFO' , 'ANGEL HOST'    , 'VERSION' , @test_info[ :angel_host ].to_s ] )
		f_log( [ 'INFO' , 'ANGEL.RB'	  , 'VERSION' , @test_info[ :angel_rb ].to_s ] )
		f_log( [ 'INFO' , 'POWER MANAGER' , 'VERSION' , @test_info[ :power_manager ].to_s ] )

		log()
	end


	# Displays PTL Library Versions
	def display_ptl_lib_versions()

		f_log( [ 'INFO' , 'LIB FUNCTIONS' , 'VERSION' , Functions::VERSION.to_s ] )
		f_log( [ 'INFO' , 'LIB WORKLOADS' , 'VERSION' , Workloads::VERSION.to_s ] )

		unless @test_info[ :enable_database ] == false

			data = read_file( file: $test_info.home_directory.to_s + 'Database.rb' )

			lib_database_rev = data.grep( /VERSION/ )[0].chomp.split( ' ' )[-1]

			f_log( [ 'INFO' , 'LIB DATABASE' , 'VERSION' , lib_database_rev.to_s ] )
		end

		unless @test_info[ :enable_uart ] == false

			data = read_file( file: $test_info.home_directory.to_s + 'Serial.rb' )

			lib_serial_rev = data.grep( /VERSION/ )[0].chomp.split( ' ' )[-1]

			f_log( [ 'INFO' , 'LIB SERIAL' , 'VERSION' , lib_serial_rev.to_s ] )
		end

		log()
	end

	# Calls Functions::_verify_device_handle
	# Calls Functions::nvme_identify
	# Retrives the max drive link rate & link width
	# Calls Functions::get_log_page_XXXX
	# Calls Functions::get_parametric_data
	# Calls Functions::get_e6
	def get_drive_info( log: false , dump_logs: false , get_e6: false )

		unless @drive_info[ :drive_responsive ] == true ; return ; end

		# Populates @drive_info[ :sn ] , drive_info[ :fw ] , @drive_info[ :pn ] , @drive_info[ :capacity ] , @drive_info[ :max_lba ] , @drive_info[ :block_size ]
		# Populates @drive_info[ :name_space_id_list ] & @drive_info[ :number_of_active_namespaces ]
		nvme_identify()

		unless @drive_info[ :drive_responsive ] == true ; return ; end

		_verify_device_handle()

		if @test_info[ :device_handle_error ] == true ; @drive_info[ :drive_responsive ] = false ; return ; end

		_get_bus_link_rate()

		# C2h must be 1st to get @drive_info[ :product_family ]
		get_log_page_C2h( log: log , dump_logs: dump_logs )

		get_firmware_files( fw_version: @drive_info[ :fw ].to_s , fw_customer_id: @drive_info[ :fw_customer_id ].to_s , log: false )

		get_log_page_02h( log: log , dump_logs: dump_logs )

		get_log_page_03h( log: log , dump_logs: dump_logs , display: false )

		get_log_page_C0h_MSFT( log: log , dump_logs: dump_logs )

		get_log_page_C1h_MSFT( log: log , dump_logs: dump_logs )

		get_log_page_C2h_MSFT( log: log , dump_logs: dump_logs )

		get_log_page_D0h_AWS( log: log , dump_logs: dump_logs )

		if get_e6 == true ; get_e6( log: log ) ; end

		# Populates @drive_info[ :gbb_count ] , @drive_info[ :nand_usage ]
		get_parametric_data( log: log )

		_update_web_data_file()
	end

	# Displays the drive info
	def display_drive_info()

		current_link_speed = []
		current_link_width = []

		if @drive_info[ :data_current ] == false

			@drive_info[ :current_link_speed ][0] = 'NA'
			@drive_info[ :current_link_width ][0] = 'NA'

			current_link_speed[0] = 'NA'
			current_link_width[0] = 'NA'

			if @test_info[ :port_configuration ].to_s == '2x2'

				@drive_info[ :current_link_speed ][1] = 'NA'
				@drive_info[ :current_link_width ][1] = 'NA'

				current_link_speed[1] = 'NA'
				current_link_width[1] = 'NA'
			end
		else
			current_link_speed[0] = 'GEN' + @drive_info[ :current_link_speed ][0].to_s

			current_link_width[0] = 'x' + @drive_info[ :current_link_width ][0].to_s

			if @test_info[ :port_configuration ].to_s == '2x2'

				current_link_speed[1] = 'GEN' + @drive_info[ :current_link_speed ][1].to_s

				current_link_width[1] = 'x' + @drive_info[ :current_link_width ][1].to_s
			end
		end

		fw_version = @drive_info[ :fw ].to_s + '-' + @drive_info[ :fw_customer_id ].to_s

		if @drive_info[ :product_family ].to_s.upcase == @drive_info[ :fw_product_family ].to_s.upcase

			f_log( [ 'INFO' , 'DRIVE' , 'PRODUCT FAMILY' , @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s.upcase ] )
		else
			f_log( [ 'INFO' , 'DRIVE' , 'PRODUCT FAMILY' , @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s.upcase + ' ( ' + @drive_info[ :fw_product_family ].to_s.upcase + ' )' ] )
		end

		f_log( [ 'INFO' , 'DRIVE' , 'FORM FACTOR'	, @drive_info[ :form_factor ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'SN'		, @drive_info[ :sn ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'PRODUCT NAME'	, @drive_info[ :product_name ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'MODEL'		, @drive_info[ :model ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'PN'		, @drive_info[ :pn ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'CUSTOMER'		, @drive_info[ :customer ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'FIRMWARE'		, fw_version.to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'ARCHITECTURE'	, @drive_info[ :product_architecture ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'TMM'		, @drive_info[ :tmm_version ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'CAPACITY'		, @drive_info[ :capacity ].to_s + ' TB' ] )
		f_log( [ 'INFO' , 'DRIVE' , 'MAX LBA'		, @drive_info[ :max_lba ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'MDTS VALUE'	, @drive_info[ :MDTS ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'LBA BLOCK SIZE'	, @drive_info[ :block_size ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'MAX DATA IO SIZE'	, @test_info[ :max_blocks_per_io ].to_s + ' BLOCKS ( ' + @drive_info[ :max_bytes_per_io ].to_s + ' BYTES )' ] )
		f_log( [ 'INFO' , 'DRIVE' , 'NAND USAGE'	, @drive_info[ :nand_usage ].to_s + ' %' ] )
		f_log( [ 'INFO' , 'DRIVE' , 'SINGLE BIT ERRORS'	, 'SRAM ' + @drive_info[ :sram_single_bit_error_count ].to_i.to_s + ' : DDR ' + @drive_info[ :ddr_single_bit_error_count ].to_i.to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'GBBs'		, @drive_info[ :gbb_count ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'POH'		, @drive_info[ :power_on_hours ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'PC COUNT'		, @test_info[ :power_cycle_count ].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'OP COUNT'		, $test_status.operation_count.to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'READ BYTES'	, $test_status.read_bytes.to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'WRITE BYTES'	, $test_status.write_bytes.to_s ] )

		log()

		f_log( [ 'INFO' , 'DRIVE' , 'BUS PATH'	, 'PORT A'	, @drive_info[ :bus_path ][0].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'BUS ID'    , 'PORT A'	, @drive_info[ :bus_id ][0].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'CTRL ID'	, 'PORT A'	, @drive_info[ :ctrl_id ][0].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'LINK SPEED', 'PORT A ' 	, current_link_speed[0].to_s ] )
		f_log( [ 'INFO' , 'DRIVE' , 'LINK WIDTH', 'PORT A ' 	, current_link_width[0].to_s ] )

		if @test_info[ :port_configuration ].to_s == '2x2'

			f_log( [ 'INFO' , 'DRIVE' , 'BUS PATH'	, 'PORT B'	, @drive_info[ :bus_path ][1].to_s ] )
			f_log( [ 'INFO' , 'DRIVE' , 'BUS ID'    , 'PORT B'	, @drive_info[ :bus_id ][1].to_s ] )
			f_log( [ 'INFO' , 'DRIVE' , 'CTRL ID'	, 'PORT B'	, @drive_info[ :ctrl_id ][1].to_s ] )
			f_log( [ 'INFO' , 'DRIVE' , 'LINK SPEED', 'PORT B ' 	, current_link_speed[1].to_s ] )
			f_log( [ 'INFO' , 'DRIVE' , 'LINK WIDTH', 'PORT B ' 	, current_link_width[1].to_s ] )
		end

		1.upto( @drive_info[ :number_of_active_namespaces ].to_i ) do |nsid|

			log()

			f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , 'SIZE'		, @namespace_info[ nsid ][ :nsze ].to_s ] ) 
			f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , 'CAPACITY'		, @namespace_info[ nsid ][ :ncap ].to_s ] )
			f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , 'BLOCK SIZE'	, @namespace_info[ nsid ][ :bs ].to_s ] )
			f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , 'TYPE'		, @namespace_info[ nsid ][ :type ].to_s.upcase ] )


			if @namespace_info[ nsid ][ :nmic ] == 1 && @drive_info[ :product_family ].to_s != 'victorharbor' ; is_2x2_capable = true ; else ; is_2x2_capable = false ; end

			f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , '2x2 CAPABLE' , is_2x2_capable.to_s.upcase ] )

			if @namespace_info[ nsid ][ :type ] == 'zoned'

				f_log( [ 'INFO' , 'NAMESPACE-' + nsid.to_s , 'ZONE COUNT' , @namespace_info[ nsid ][ :number_of_zones ].to_s + "\n" ] )

				f_log( [ 'INFO' , 'MAX OPEN ZONES' , @drive_info[ :max_open_zones ].to_s ] )
			end
		end

		log()
	end

	# Gets tester info
	# @return nil
	def get_tester_info()

		cmd = '/sbin/modinfo nvme'

		driver_version = ( ( ( %x( #{ cmd } ) ).split( "\n" ) ).select{ |x| x =~ /version/ } )[0].split( ':' )[-1].strip

		cmd = '/sbin/modinfo nvme_core'

		driver_core_version = ( ( ( %x( #{ cmd } ) ).split( "\n" ) ).select{ |x| x =~ /version/ } )[0].split( ':' )[-1].strip

		cmd = 'uname -r'

		kernel_release = ( %x( #{ cmd } ) ).chomp

		cmd = 'sudo /usr/sbin/dmidecode -t 0'

		dmidecode_t0 = ( ( %x( #{ cmd } ) ).split( "\n" ) ).map{ |x| x.tr( "\t" , '' ) }

		bios_version = ( dmidecode_t0.select{ |x| x =~ /Version/ } )[0].split( ':' )[-1].strip

		bios_vendor = ( dmidecode_t0.select{ |x| x =~ /Vendor/ } )[0].split( ':' )[-1].strip

		cmd = 'sudo /usr/sbin/dmidecode -t 2'

		dmidecode_t1 = ( ( %x( #{ cmd } ) ).split( "\n" ) ).map{ |x| x.tr( "\t" , '' ) }

		motherboard_vendor = ( dmidecode_t1.select{ |x| x =~ /Manufacturer/ } )[0].split( ':' )[-1].strip

		motherboard_model = ( dmidecode_t1.select{ |x| x =~ /Product Name/ } )[0].split( ':' )[-1].strip

		motherboard_serial_numnber = ( dmidecode_t1.select{ |x| x =~ /Serial Number/ } )[0].split( ':' )[-1].strip

		cmd = 'cat /proc/meminfo'

		meminfo = ( %x( #{ cmd } ) ).split( "\n" )

		# In MegaBytes
		memory_total = ( ( ( meminfo.select{ |x| x =~ /MemTotal/ } )[0].split( ':' )[-1].strip ).split( "\s" )[0] ).to_i / 1000

		cmd = 'cat /proc/cpuinfo'

		cpu_info = ( %x( #{ cmd } ) ).split( "\n" )

		cmd = 'cat /sys/module/nvme_core/parameters/io_timeout'

		io_timeout = ( %x( #{ cmd } ) ).strip

		cmd = 'cat /sys/module/nvme_core/parameters/admin_timeout'

		admin_timeout = ( %x( #{ cmd } ) ).strip

		cmd = 'ruby -v'

		client_ruby_version = ( ( %x( #{ cmd } ) ).strip ).split( "\s" )[1]

		server_ruby_version = ( ssh( cmd: cmd ).chomp ).split( "\s" )[1]

		if $test_info.chamber_id.split( '-' )[1] == 'PSTAR'

			ifc_type = 'NA' ; pci_gen = '3'
		else
			ifc_data = $power.decode_card_fabid( $power.get_card_fabid().to_s )

			ifc_type = ifc_data[1].to_s

			pci_gen = ifc_data[0].to_s
		end

		@tester_info = {

			:driver_version		=> driver_version.to_s ,
			:driver_core_version	=> driver_core_version.to_s ,
			:kernel_release		=> kernel_release.to_s ,
			:bios_version		=> bios_version.to_s ,
			:bios_vendor		=> bios_vendor.to_s ,
			:motherboard_vendor	=> motherboard_vendor.to_s ,
			:motherboard_model	=> motherboard_model.to_s ,
			:motherboard_sn		=> motherboard_serial_numnber.to_s ,
			:memory_MB		=> memory_total.to_s ,
			:cpu_info		=> cpu_info ,
			:admin_timeout		=> admin_timeout.to_s ,
			:io_timeout		=> io_timeout.to_s ,
			:client_ruby_version	=> client_ruby_version.to_s ,
			:server_ruby_version	=> server_ruby_version.to_s ,
			:ifc_type		=> ifc_type ,
			:pci_gen		=> pci_gen ,
			:tester_type		=> $test_info.chamber_id.split( '-' )[1] ,
			:test_site		=> $test_info.chamber_id.split( '-' )[0] ,
			:tester_id		=> $test_info.chamber_id.to_s ,
		}
	end

	def display_tester_info()

		if @tester_info.empty? ; get_tester_info() ; end

		cpu_info = @tester_info[ :cpu_info ]

		cpu = [] ; processor = nil

		( 0 .. ( cpu_info.length - 1 ) ).each do |x|

			if cpu_info[ x ].include? 'processor' ; processor = cpu_info[ x ].split( ':' )[-1].to_i ; end

			if cpu_info[ x ].include? 'model name' ; cpu[ processor ] = cpu_info[ x ].split( ':' )[-1].strip ; end
		end

		if $test_info.enable_2x2 == true ; @test_info[ :port_configuration ] = '2x2' ; else ; @test_info[ :port_configuration ] = '1x4' ; end

		if $test_info.genesis_hd_config.to_s == 'Edge' ; @test_info[ :port_configuration ] = '1x8' ; end

		f_log( [ 'INFO' , 'TESTER'	, 'TYPE'		, @tester_info[ :tester_type ].to_s ] )
		f_log( [ 'INFO' , 'KERNEL'	, 'VERSION'		, @tester_info[ :kernel_release ].to_s ] )
		f_log( [ 'INFO' , 'DRIVER'	, 'VERSION'		, @tester_info[ :driver_version ].to_s ] )
		f_log( [ 'INFO' , 'DRIVER CORE'	, 'VERSION'		, @tester_info[ :driver_core_version ].to_s ] )
		f_log( [ 'INFO' , 'BIOS'	, 'VERSION'		, @tester_info[ :bios_version ].to_s ] )
		f_log( [ 'INFO' , 'BIOS'	, 'VENDOR'		, @tester_info[ :bios_vendor ].to_s ] )
		f_log( [ 'INFO' , 'MB'		, 'VENDOR'		, @tester_info[ :motherboard_vendor ].to_s ] )
		f_log( [ 'INFO' , 'MB'		, 'MODEL'		, @tester_info[ :motherboard_model ].to_s ] )
		f_log( [ 'INFO' , 'MB'		, 'SN'			, @tester_info[ :motherboard_sn ].to_s ] )
		f_log( [ 'INFO' , 'MEMORY'	, 'TOTAL'		, @tester_info[ :memory_MB ].to_s + ' MB' ] )
		f_log( [ 'INFO' , 'CPU'		, 'TYPE'		, cpu.count.to_s + ' x ' + cpu[0].to_s ] )
		f_log( [ 'INFO' , 'RUBY'	, 'SERVER VERSION'	, @tester_info[ :server_ruby_version ].to_s ] )
		f_log( [ 'INFO' , 'RUBY'	, 'CLIENT VERSION'	, @tester_info[ :client_ruby_version ].to_s ] )
		f_log( [ 'INFO' , 'INTERFACE'	, 'TYPE'		, $test_info.interface.to_s ] )
		f_log( [ 'INFO' , 'IFC'		, 'TYPE'		, @tester_info[ :ifc_type ].to_s ] )
		f_log( [ 'INFO' , 'PCI'		, 'GEN'			, @tester_info[ :pci_gen ].to_s ] )
		f_log( [ 'INFO' , 'PORT'	, 'CONFIG'		, @test_info[ :port_configuration ].to_s ] )
		f_log( [ 'INFO' , 'TIMEOUT'	, 'ADMIN'		, @tester_info[ :admin_timeout ].to_s ] )
		f_log( [ 'INFO' , 'TIMEOUT'	, 'IO'			, @tester_info[ :io_timeout ].to_s ] )

		log()
	end

	def display_power_info()

		f_log( [ 'INFO' , 'POWER' , '5V'  , 'SET'       , $power.get_5v_setting.to_s ] )
		f_log( [ 'INFO' , 'POWER' , '12V' , 'SET'       , $power.get_12v_setting.to_s ] )
		f_log( [ 'INFO' , 'POWER' , '5V'  , 'ACTUAL'    , $power.get_5v.to_s ] )
		f_log( [ 'INFO' , 'POWER' , '12V' , 'ACTUAL'    , $power.get_12v.to_s ] )
		f_log( [ 'INFO' , 'POWER' , '5V'  , 'AMPS'      , $power.get_5a.to_s ] )
		f_log( [ 'INFO' , 'POWER' , '12V' , 'AMPS'      , $power.get_12a.to_s ] )

		log()

		_get_sub_power_board_uptime()
	end

	def io_tracker( tag: nil , dwpd: false )

		if @test_info[ :io_tracker ].keys.include?( tag.to_sym )

			@test_info[ :io_tracker ][ tag.to_sym ][ :end ] = { :read_bytes => $test_status.read_bytes , :write_bytes => $test_status.write_bytes , :operation_count => $test_status.operation_count , :time => Time.now }

			read_bytes = @test_info[ :io_tracker ][ tag.to_sym ][ :end ][ :read_bytes ] - @test_info[ :io_tracker ][ tag.to_sym ][ :start ][ :read_bytes ]

			write_bytes = @test_info[ :io_tracker ][ tag.to_sym ][ :end ][ :write_bytes ] - @test_info[ :io_tracker ][ tag.to_sym ][ :start ][ :write_bytes ]

			operation_count = @test_info[ :io_tracker ][ tag.to_sym ][ :end ][ :operation_count ] - @test_info[ :io_tracker ][ tag.to_sym ][ :start ][ :operation_count ]

			duration = ( @test_info[ :io_tracker ][ tag.to_sym ][ :end ][ :time ] - @test_info[ :io_tracker ][ tag.to_sym ][ :start ][ :time ] ).round(1)

			@test_info[ :io_tracker ].delete( tag.to_sym )

			@inspector_info[ :io_tracker ][ tag.to_sym ] = {}

			@inspector_info[ :io_tracker ][ tag.to_sym ] = { read_bytes: read_bytes , write_bytes: write_bytes , operation_count: operation_count , duration: duration }

			f_log( [ 'INFO' , 'IO TRACKER ' , tag.to_s , 'READ WRITE IOPS TIME' , read_bytes.to_s , write_bytes.to_s , operation_count.to_s , duration.to_s + "\n" ] )

			if dwpd == true

				drive_writes_per_day = ( write_bytes.to_f / ( @drive_info[ :max_lba ].to_i * @drive_info[ :block_size ].to_i ).to_f ).round(2)

				f_log( [ 'INFO' , 'DWPD' , drive_writes_per_day.to_s + "\n" ] )

				@drive_info[ :drive_writes_per_day ].push( drive_writes_per_day.to_f )
			end
		else
			@test_info[ :io_tracker ][ tag.to_sym ] = {}

			@test_info[ :io_tracker ][ tag.to_sym ][ :start ] = { :read_bytes => $test_status.read_bytes , :write_bytes => $test_status.write_bytes , :operation_count => $test_status.operation_count , :time => Time.now }

			f_log( [ 'INFO' , 'IO TRACKER ' , tag.to_s , 'START' + "\n" ] )
		end
	end

	# Writes user data to file
	# option 'w' writes text file. option 'wb' writes binary file
	def write_file( dir: $test_info.home_directory , file: nil , data: nil , option: 'w' )

		log( 'dir : ' + dir.inspect )

		unless dir[-1] == '/' ; dir += '/' ; end

		log( 'dir : ' + dir.inspect )

		rc = $angel.log.write_file( dir.to_s + file.to_s , data.to_s , option.to_s )
	end

	# Reads user specified file
	# option 'r' reads text file. 'rb' reads binary file
	# @return file content in buffer 'data'
	def read_file( file: nil , option: 'r' , log: true )

		called_by = caller[0].to_s

		data = [] ; fh = nil ; file_open = false

		begin
			if File.exist?( file )

				fh = File.open( file , option )

				file_open = true

				data = fh.readlines

				data = data.map{ |line| line.scrub!.strip! }
			else
				if log == true ; _warning_counter( category: 'read_file' , data: 'FILE NOT FOUND : ' + file.to_s ) ; end
			end

		rescue StandardError => error

			_warning_counter( category: 'read_file' , data: error.to_s + ' : ' + called_by.to_s )
		end

		if file_open == true ; fh.close ; end

		return data
	end

	# Writes data to user specifed file in YAML format
	def write_yaml_file( data: nil , file: nil , option: 'w' )

		f_log( [ 'FUNC' , 'WRITE YAML FILE' , file.to_s ] , 5 )

		File.open( file , option ) do |fh| ; fh.write( data.to_yaml ) ; end
	end

	# Reads user specified YAML file to local variable yaml
	def read_yaml_file( file: nil )

		f_log( [ 'FUNC' , 'READ YAML FILE' , file.to_s ] , 5 )

		yaml = YAML.load_file( file )

		return yaml
	end

	def scp_upload( file: nil , destination: nil )

		begin
			Timeout::timeout(300) { Net::SCP.upload!( '192.0.0.254' , 'everest' , file.to_s , destination.to_s , :ssh => { :password => 'everest' } ) }

		rescue StandardError => error

			_warning_counter( category: 'scp_error' , data: error.to_s )
		end
	end

	# Reads remote file using SCP
	# If destination is provided will create file in the user specified directory
	# If destionation is nil, returns file content as buffer 'data'
	def scp_read( remote_file: nil , destination: nil )

		if destination == nil

			f_log( [ 'FUNC' , 'SCP' , remote_file.to_s , 'BUFFER' ] , 5 )
		else
			f_log( [ 'FUNC' , 'SCP' , remote_file.to_s , destination.to_s ] , 5 )
		end

		begin
			Net::SCP.download!( '192.0.0.254' , 'everest' , remote_file , destination , :ssh => { :password => 'everest' } )

		rescue StandardError => error

			force_failure( category: 'system_command_failure' , data: 'SCP : ' + remote_file.to_s + ' -> ' + destination.to_s + ' : ' + error.to_s )
		end

		return data
	end

	# Performs a net-ssh with user defined data
	# @return data from ssh command
	def ssh( cmd: nil , ip: '192.0.0.254' , username: 'everest' , password: 'everest' , non_blocking: false )

		ssh_cmd = "ssh everest@192.0.0.254 '" + cmd.to_s + "'"

                data = ( %x( #{ ssh_cmd } ) )

                return data

=begin
		data = nil

		begin
			retries ||= 0

			Net::SSH.start( ip , username , password: password ) do |ssh|

				if non_blocking == true

					ssh.exec( cmd.to_s )

					ssh.close
				else
					data = ssh.exec!( cmd.to_s )
				end
			end

		rescue StandardError => error

			if ( retries += 1 ) < 5

				puts 'SSH ERROR DETECTED : RETRY ( ' + retries.to_s + ' ) : ' + cmd.to_s

				sleep 1

				retry
			else
				puts 'SSH ERROR DETECTED : RETRIES ( ' + retries.to_s + ' ) FAILED , EXITING'

				raise error
			end
		end

		# Returns stdout from ssh command
		return data
=end
	end

	# Creates a compressed archive of the user specified file or directory
	def zip( dir: nil , zip: nil )

		f_log( [ 'FUNC' , 'ZIP' , dir.to_s , zip.to_s ] , 3 )

		Zip::File.open( zip , Zip::File::CREATE ) do |zipfile|

			Find.find( dir ) do |path|

				file = path.split( '/' )[-1]

				unless File.directory?( path.to_s )

					# Two arguments:
					# - The name of the file as it will appear in the archive
					# - The original file, including the path to find it
					zipfile.add( file , path )
				end
			end
		end
	end

	# Uncompresses the user defined zip file to the user specified directory
	def unzip( file: nil , dir: $test_info.home_directory )

		f_log( [ 'FUNC' , 'UNZIP' , file.to_s ] , 5 )

		unless dir.to_s.include?( '$/' ) ; dir = dir + '/' ; end

		Zip::File.open( file ) do |zip_file|

			zip_file.each do |fh|

				dir_file = File.join( dir , fh.name )

				zip_file.extract( fh , dir_file )
			end
		end
	end

	# Creates the user defined directory path
	def make_dir( dir: nil )

		f_log( [ 'FUNC' , 'MKDIR' , dir.to_s ] , 5 )

		FileUtils.mkdir_p( dir )
	end

	# Deletes the user specified file or directory
	def delete( file: nil )

		f_log( [ 'FUNC' , 'DELETE' , file.to_s ] , 5 )

		FileUtils.rm_rf( file )
	end

	def get_lspci_state()

		lspci_output = []

		@drive_info[ :bus_id ].each do |bus_id|

			cmd = 'sudo /sbin/lspci -x -s ' + bus_id.to_s

			data = ( %x( #{ cmd } ) ).split( "\n" )

			lspci_output.push( *data )
		end

		filename = $test_info.home_directory + 'lspci_state.log'

		lspci_output.each do |data|

			$angel.log.write_file( filename , data.to_s + "\n" , 'a' )
		end
	end

	# Creates error_condition_handler.yaml as defined in PostScriptHandler::create_error_condition_file in the working test directory and tells angel to use this file on error
	# @return nil
	def create_error_condition_file( dir: $test_info.home_directory.to_s )

		_create_error_condition_file( dir: dir.to_s )
	end

	def zns_get_random_zones( nsid: @drive_info[ :zoned_namespace ] , number_of_zones: @drive_info[ :max_open_zones ] )

		zones = {}

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		random_zones_array = array_of_zones.sample( number_of_zones )

		random_zones_array.each do |zone_id|

			zones[ zone_id ] = {}

			zone_func( nsid: nsid , zone_id: zone_id , func: 'reset' , log: false )
		end

		return zones
	end

	# Gets the tty for the attached serial port
	def uart_get_port()

		# If there are issues with retrieving the TTY ID, make sure YAML is installed on the server

		unless @test_info[ :enable_uart ] == true ; return -1 ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial-port-discovery.rb --cell=' + $test_info.cell_number.to_s

		tty = ssh( cmd: cmd ).chomp

		unless tty.to_s.include?( 'USB' )

			if	@test_info[ :uart_error_action ].to_s == 'warn'

				_warning_counter( category: 'serial_connection_failure' , data: cmd.to_s + ' : ' + tty.inspect )

				@test_info[ :enable_uart ] = false

				return -1

			elsif	@test_info[ :uart_error_action ].to_s == 'ignore'

				@test_info[ :enable_uart ] = false

				return -1
			else
				force_failure( category: 'serial_connection_failure' , data: cmd.to_s + ' : ' + tty.inspect )
			end
		end

		tty = ( tty.split( '/' )[-1] ).to_s.gsub!( 'tty' , '' )

		unless tty.to_s.include?( 'USB' )

			if	@test_info[ :uart_error_action ].to_s == 'warn'

				_warning_counter( category: 'serial_connection_failure' , data: cmd.to_s + ' : ' + tty.inspect )

				@test_info[ :enable_uart ] = false

				return -1

			elsif	@test_info[ :uart_error_action ].to_s == 'ignore'

				@test_info[ :enable_uart ] = false

				return -1
			else
				force_failure( category: 'serial_connection_failure' , data: cmd.to_s + ' : ' + tty.inspect )
			end
		end

		@uart_info[ :tty ] = tty.to_s

		return @uart_info[ :tty ]
	end

	def uart_get_menu()

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=get-menu --port=' + @uart_info[ :tty ].to_s

		menu = ssh( cmd: cmd ).chomp

		return menu.to_s
	end

	def uart_catch_blre()

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=catch-blre --port=' + @uart_info[ :tty ].to_s

		ssh( cmd: cmd ).chomp
	end

	def uart_reset()

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=reset'

		ssh( cmd: cmd ).chomp

		@uart_info[ :open ] = false
	end

	def uart_tail()

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		uart_sn = nil ; uart_customer_sn = nil

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=get-sn --port=' + @uart_info[ :tty ].to_s

		uart_sn = ssh( cmd: cmd ).chomp

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=get-customer-sn --port=' + @uart_info[ :tty ].to_s

		uart_customer_sn = ssh( cmd: cmd ).chomp

		unless uart_sn.to_s == @drive_info[ :sn ].to_s || uart_customer_sn.to_s == @drive_info[ :sn ].to_s

			uart_sn = uart_sn.split( "\n" )[0] ; uart_customer_sn = uart_customer_sn.split( "\n" )[0]

			if	@test_info[ :uart_error_action ].to_s == 'warn'

				_warning_counter( category: __method__.to_s , data: 'SN MISMATCH : ' + @drive_info[ :sn ].to_s + ' : ' + uart_sn.to_s + ' : ' + uart_customer_sn.to_s )

				@test_info[ :enable_uart ] = false

				return

			elsif	@test_info[ :uart_error_action ].to_s == 'ignore'

				@test_info[ :enable_uart ] = false

				return
			else
				f_log( [ 'WARN' , 'UART' , 'SN MISMATCH' , @drive_info[ :sn ].to_s + ' : ' + uart_sn.to_s + "\n" ] )

				force_failure( category: 'serial_connection_failure' , data: @uart_info[ :tty ].to_s )
			end
		end

		filename = 'UART_' + @uart_info[ :tty ].to_s + '_' + @drive_info[ :sn ].to_s + ( Time.now.strftime( "_%m%d%Y_%H%M%S" ) ).to_s + '.log'

		cmd = 'nohup ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --port=' + @uart_info[ :tty ].to_s + ' --func=tail --file=' + $test_info.home_directory.to_s + filename.to_s + ' &'

		ssh( cmd: cmd , non_blocking: true )

		f_log( [ 'INFO' , 'UART' , @uart_info[ :tty ].to_s , filename.to_s + "\n" ] )

		@uart_info[ :open ] = true
	end

	def uart_get_files( type: 'blre' )

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial.rb --func=get-files --port=' + @uart_info[ :tty ].to_s + ' --dir=' + $test_info.home_directory.to_s + ' --sn=' + @drive_info[ :sn ].to_s + ' --type=' + type.to_s

		rc = ssh( cmd: cmd.to_s )

		rc = rc.split( "\n" )

		rc.each do |data|

			next if data.nil?

			next unless data.include?( ':' )

			file = ( data.split( ' : ' )[0] ).split( '/' )[-1]

			if data.split( ' : ' )[-1].to_s == 'OK'

				f_log( [ 'INFO' , type.upcase , file ] )

				@test_logs[ :uart ].push( file )
			else
				error = data.split( ' : ' )[1].to_s.strip!

				if	@test_info[ :uart_error_action ].to_s == 'warn'

					_warning_counter( category: 'serial_connection_failure' , data: error.to_s )

					return

				elsif	@test_info[ :uart_error_action ].to_s == 'ignore'

					@test_info[ :enable_uart ] = false

					return
				else
					force_failure( category: 'serial_connection_failure' , data: @uart_info[ :tty ].to_s + ' : ' + error.to_s )
				end
			end
		end
	end

	# Kills the connection to /dev/ttyUSBXX 
	def uart_kill()

		if @uart_info[ :tty ] == nil

			cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'serial-port-discovery.rb --cell=' + $test_info.cell_number.to_s

			tty = ssh( cmd: cmd ).chomp

			if tty.to_s.include?( 'USB' )

				@uart_info[ :tty ] == ( tty.split( '/' )[-1] ).to_s.gsub!( 'tty' , '' )
			else
				return
			end
		end

		cmd = '/bin/fuser -k /dev/tty' + @uart_info[ :tty ].to_s

		rc = ssh( cmd: cmd.to_s )

		files = Dir[ $test_info.home_directory.to_s + 'UART*' ]

		files.each do |file|

			begin
				rc = File.delete( $test_info.home_directory + file.to_s ) if File.exists?( $test_info.home_directory + file.to_s )

			rescue StandardError => error

				_warning_counter( category: 'uart_kill_error' , data: error.to_s )
			end
		end

		@uart_info[ :open ] = false
	end

	def uart_write( data: nil , timeout: 5000 )

		unless @test_info[ :enable_uart ] == true ; return ; end

		if @uart_info[ :tty ] == nil ; uart_get_port() ; end

		if @uart_info[ :open ] == true ; uart_kill() ; end

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory.to_s + 'serial.rb --func=write --timeout=' + timeout.to_s + ' --port=' + @uart_info[ :tty ].to_s + ' --data=' + "'" + data.to_s + "'"

		f_log( [ 'DEBUG' , cmd.to_s + "\n" ] )

		return_data = ssh( cmd: cmd.to_s )

		return_data.gsub!( '[' , '' ) ; return_data.gsub!( ']' , '' ) ; return_data.gsub!( '"' , '' ) ; return_data.gsub!( /^\s/ , '' ) ; return_data.gsub!( /\s+$/ , '' )

		return_data = return_data.split( ',' )

		clean_data = []

		return_data.each do |data|

			data.gsub!( /^\s+/ , '' )

			data.gsub!( /\s+$/ , '' )

			clean_data.push( data )
		end

		uart_kill()

		return clean_data
	end

	def get_firmware_files( dir: $fw_repo , fw_version: nil , fw_customer_id: nil , log: true )

		#FIXME KAL - Need final HB FW Details
		return if @drive_info[ :product_architecture ] == 'VAIL'

		if dir[-1] != '/' ; dir += '/' ; end

		_get_firmware_file( dir: dir , fw_version: fw_version , fw_customer_id: fw_customer_id , log: log )

		_get_counters_handler_xml( dir: dir , fw_version: fw_version , fw_customer_id: fw_customer_id )
	end

	# Performs clean up action after a test has completed
	# @return nil
	def post_script_handler( status = 'passed' )

		@test_info[ :status ] = status

		if $test_status.current_status.to_s.downcase.include?( 'precheck' )

			angel_status = 'Failed' ; @test_info[ :status ] = 'precheck-failure'

		elsif	$test_status.current_status.to_s == 'Aborting'

			angel_status = 'Aborted' ; @test_info[ :status ] = 'aborted'

		elsif	@test_info[ :warning_counter ] > 0 && @test_info[ :status ] == 'passed'

			angel_status = 'Passed' ; @test_info[ :status ] = 'passed-with-warnings'
		else
			angel_status = @test_info[ :status ].capitalize
		end

		f_log( [ "\n" + 'INFO' , 'POST' , $test_info.start_script.to_s.upcase , 'STATUS' , @test_info[ :status ].to_s.upcase + "\n" ] )

		f_log( [ 'INFO' , 'ERROR HANDLING' , 'DISABLED' , __method__.to_s.upcase + "\n" ] )
		# Disables error handling in case function inside post-failure script fails
		$test_status.skip_error_handling = true

		f_log( [ 'INFO' , 'SLOT' , 'ID' , @test_info[ :slot_id ].to_s + "\n" ] )

		begin
			if angel_status.include?( 'Failed' ) ; _get_error_info() ; end

			if angel_status == 'Aborted' ; _get_abort_info() ; end

			begin
				get_drive_info( log: false , dump_logs: true , get_e6: true )

			rescue StandardError => error

				f_log( [ 'WARN' , 'GET_DRIVE_INFO' , 'POST-SCRIPT-ERROR' + "\n" ] )

				if	@test_info[ :status ] == 'passed' && @drive_info[ :assert_present ] == false

					@test_info[ :status ] = 'passed-with-warnings'

				elsif	@test_info[ :status ] == 'passed' && @drive_info[ :assert_present ] == true

					@test_info[ :status ] = 'Failed'

					angel_status = 'Failed'
				end
			end

			if @drive_info[ :drive_responsive ] == true

				f_log( [ 'INFO' , 'DRIVE STATE' , 'RESPONSIVE' + "\n" ] )
			else
				f_log( [ 'INFO' , 'DRIVE STATE' , 'UNRESPONSIVE' + "\n" ] )
			end

			if @drive_info[ :data_current ] == true

				f_log( [ 'INFO' , 'DATA STATE' , 'CURRENT' + "\n" ] )
			else

				f_log( [ 'INFO' , 'DATA STATE' , 'STALE' + "\n" ] )
			end

			begin
				display_drive_info()

			rescue StandardError => error

				_warning_counter( category: 'display_drive_info_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			begin
				display_power_info()

			rescue StandardError => error

				_warning_counter( category: 'display_power_info_error' , data: error.inspect )
	
				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			begin
				unless @test_info[ :status ] == 'aborted' ; _get_sub_power_board_registers() ; end

			rescue StandardError => error

				_warning_counter( category: 'get_sub_power_board_registers_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			if @drive_info[ :drive_responsive ] == true && @test_info[ :status ].to_s != 'precheck-failure'

				begin
					unless @test_info[ :status ] == 'aborted' ; get_eye_diagram() ; end

				rescue StandardError => error

					_warning_counter( category: 'get_eye_diagram_error' , data: error.inspect )

					f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end

				begin
					@test_logs[ :post ].each do |filename|

						type = filename.split( '_' )[1]

						f_log( [ 'FUNC' , 'GET LOG PAGE' , type.to_s , filename.to_s ] )
					end

					log()

				rescue StandardError => error

					f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end
			end

			unless @test_info[ :status ].to_s == 'precheck-failure'

				begin
					_inspector_csv

				rescue StandardError => error

					_warning_counter( category: 'inspector_csv_error' , data: error.inspect )

					f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end

				begin
					inspector_upload()

				rescue StandardError => error

					if error.backtrace.to_s.include?( 'check_mount' )

						_warning_counter( category: 'inspector_file_not_uploaded' , data: 'inspector_share_not_mounted' )
					else
						_warning_counter( category: 'inspector_file_not_uploaded' , data: @test_logs[ :inspector ].to_s )
					end

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end
			end

			begin
				_copy_angel_files()

			rescue StandardError => error

				_warning_counter( category: 'copy_angel_files_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			begin
				unless @test_info[ :status ] == 'aborted' ; get_lspci_state() ; end

			rescue StandardError => error

				_warning_counter( category: 'get_lspci_state_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			begin
				_dump_test_variables()

			rescue StandardError => error

				_warning_counter( category: 'dump_test_variables_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			unless @test_info[ :status ].to_s == 'precheck-failure'

				begin
					_update_database( status: @test_info[ :status ] )

				rescue StandardError => error

					_warning_counter( category: 'update_database_error' , data: error.inspect )

					f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end

				begin
					if @drive_info[ :drive_responsive ] == true && @test_info[ :status ] != 'aborted'

						write_drive_log( data: $test_info.start_script.to_s.upcase + ' ' + @test_info[ :status ].to_s.upcase )
					end

				rescue StandardError => error

					_warning_counter( category: 'write_drive_log_error' , data: error.inspect )

					f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

					if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
				end
			end

			begin
				_update_web_data_file()

			rescue StandardError => error

				_warning_counter( category: 'update_web_data_file_error' , data: error.inspect )

				f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] , -2 )

				if @test_info[ :status ] == 'passed' ; @test_info[ :status ] = 'passed-with-warnings' ; end
			end

			if @test_info[ :status ] == 'passed-with-warnings'

				f_log( [ 'INFO' , 'WARNINGS' , @test_info[ :warnings ].keys.join(',').to_s + "\n" ] )
			end

			( hours , mins , secs ) = ( Time.at( ( Time.now - @test_info[ :start_time ] ) ).utc.strftime( '%H:%M:%S' ) ).split( ':' )

			runtime = ( hours.to_i + ( ( ( ( Time.now - @test_info[ :start_time ] ) / ( 24.0*60*60 ) ).floor ).to_i * 24 ) ).to_s + ':' + mins.to_s + ':' + secs.to_s

			f_log( [ 'INFO' , 'STATUS' , @test_info[ :status ].to_s.upcase , runtime.to_s ] )
		ensure
			uart_kill()

			# Current known valid test_end values are 'Passed' , 'Failed' , 'Precheck Failed' , 'Aborted'
			# 'Precheck Failed' causes slot to report 'Needs Reinsert' & next start will stall. Use 'Failed' instead
			$angel.test_end( angel_status )
		end
	end

	def check_for_fw_update()

		update_firmware_yaml_file = '/home/everest/angel_config_files/update-firmware.yaml'

		if File.exists?( update_firmware_yaml_file )

			begin
				yaml_data = YAML.load( File.read( update_firmware_yaml_file ) )

				firmware = yaml_data[ @tester_info[ :tester_id ] ][ 'firmware' ].to_s

				fw_customer_id = yaml_data[ @tester_info[ :tester_id ] ][ 'fw_customer_id' ].to_s

				if fw_customer_id.to_s == 'nil' ; fw_customer_id = nil ; end

				date = yaml_data[ @tester_info[ :tester_id ] ][ 'date' ].to_s

				power_cycle = yaml_data[ @tester_info[ :tester_id ] ][ 'power_cycle' ].to_s

				commit_action = yaml_data[ @tester_info[ :tester_id ] ][ 'commit_action' ].to_s

			rescue StandardError => error

				#_warning_counter( category: 'check_for_fw_update' , data: error.inspect )
			end

			if firmware != 'nil' && firmware != @drive_info[ :fw ].to_s && date == ( Time.now ).strftime( "%m-%d-%Y" ).to_s

				f_log( [ 'INFO' , 'FIRMWARE UPDATE REQUEST DETECTED' + "\n" ] )

				firmware_download_nvme_cli( firmware: firmware , fw_customer_id: fw_customer_id , power_cycle: power_cycle , commit_action: commit_action , firmware_slot: 1 )
			end
		end
	end

	# NVME-MI ( Management Interface )
	# In-Band
	def nvme_mi()

		rc = $angel.nvme_custom_command( 0x1E , 0 , 0x804 , 0x5 , 0x0 , 0xFF , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		$angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , "nvme_mi_VPD.bin" , 4096 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		rc = $angel.nvme_custom_command( 0x1E , 0 , 0x804 , 0x0 , 0x0 , 0x0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		$angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , "nvme_mi_data.bin" , 4096 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		rc = $angel.nvme_custom_command( 0x1E , 0 , 0x804 , 0x0 , 0x1000000 , 0x0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		$angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , "nvme_mi_port0.bin" , 4096 , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

		$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

		rc = $angel.nvme_custom_command( 0x1E , 0 , 0x804 , 0x0 , 0x1010000 , 0x0 , 0 , 0 , @test_info[ :functions_buffer_id ] , 4096 )

		$angel.buffer.dump_buffer( @test_info[ :functions_buffer_id ] , "nvme_mi_port1.bin" ,  4096 , AngelCore::FileFormat_Binary,AngelCore::FileMode_Create )
	end

	private

	def _decode_snowbird_3e( log: true )

		_get_parametric_offsets()

		filename = 'ANGEL_3E_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.bin'

		if log == true ; f_log( [ 'FUNC' , 'GET LOG PAGE' , '3E' , filename.to_s ] ) ; log() ; end

		_sbdi( filename: filename , data_source: 'parametrics' )

		if @test_info[ :check_eyecatcher ] == true

			eyecatcher_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'eyecatcher' } ).keys )[0].to_s ][ 'start_byte' ]

			eyecatcher = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + eyecatcher_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_s

			if	@drive_info[ :eyecatcher ] == nil

				@drive_info[ :eyecatcher ] = eyecatcher

			elsif	@drive_info[ :eyecatcher ] != eyecatcher

				@test_info[ :invalid_eyecatcher ] += 1

				if @test_info[ :invalid_eyecatcher ] < 5

					_warning_counter( category: 'get_parametric_data_error' , data: filename.to_s )

					get_e6( log: true )

					get_parametric_data( log: true )
				else
					force_failure( category: 'get_parametric_data_error' , data: @test_info[ :invalid_eyecatcher ].to_s )
				end
			end
		end

		nand_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'life_used_percentage_x100' } ).keys )[0].to_s ][ 'start_byte' ]

		glist_grown_blocks_for_erase_fail_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'glist_grown_blocks_for_erase_fail' } ).keys )[0].to_s ][ 'start_byte' ]

		glist_grown_blocks_for_program_fail_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'glist_grown_blocks_for_program_fail' } ).keys )[0].to_s ][ 'start_byte' ]

		glist_grown_blocks_for_frame_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'glist_grown_blocks_for_frame' } ).keys )[0].to_s ][ 'start_byte' ]

		bit_errors_ddr_single_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'bit_errors_ddr_single' } ).keys )[0].to_s ][ 'start_byte' ]

		bit_errors_ddr_double_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'bit_errors_ddr_double' } ).keys )[0].to_s ][ 'start_byte' ]

		bit_errors_sram_single_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'bit_errors_sram_single' } ).keys )[0].to_s ][ 'start_byte' ]

		bit_errors_sram_double_offset = @test_info[ :parametric_offsets ][ ( ( @test_info[ :parametric_offsets ].select{ |key , hash| hash[ 'name' ] == 'bit_errors_sram_double' } ).keys )[0].to_s ][ 'start_byte' ]

		nand_usage = sprintf( '%0.2f' , ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + nand_offset.to_i ) , 4 , 'little' , 'unsigned' ) / 100.00 ) )

		@drive_info[ :nand_usage ] = nand_usage

		if ( nand_usage.to_f >= @test_info[ :nand_limit ].to_f ) ; rc = _nand_usage_limit_exceeded() ; if rc == -1 ; return ; end ; end

		# glist_grown_blocks_for_erase_fail
		gbb_count = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + glist_grown_blocks_for_erase_fail_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_i

		# glist_grown_blocks_for_program_fail
		gbb_count += ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + glist_grown_blocks_for_program_fail_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_i

		# glist_grown_blocks_for_frame
		gbb_count += ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + glist_grown_blocks_for_frame_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_i

		@drive_info[ :gbb_count ] = gbb_count

		ddr_single_bit_error_count = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + bit_errors_ddr_single_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_i

		@drive_info[ :ddr_single_bit_error_count ] = ddr_single_bit_error_count

		sram_single_bit_error_count = ( $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , ( 512 + bit_errors_sram_single_offset.to_i ) , 4 , 'little' , 'unsigned' ) ).to_i

		@drive_info[ :sram_single_bit_error_count ] = sram_single_bit_error_count

		_decode_parametrics( bin_file: filename )

		return filename
	end

	def _decode_vail_3e( file: nil )

		date_stamp = file.split( '_' )[-2]

		time_stamp = file.split( '_' )[-1].sub!( '.bin' , '' )

		inspector_date_time_stamp = date_stamp[0] + date_stamp[1] + date_stamp[2] + date_stamp[3] + '/' + date_stamp[4] + date_stamp[5] + '/' + date_stamp[6] + date_stamp[7] + ' ' + time_stamp[0] + time_stamp[1] + ':' + time_stamp[2] + time_stamp[3] + ':' + time_stamp[4] + time_stamp[5]

		@inspector_info[ :log_pages ][ '0x3E' ][ inspector_date_time_stamp.to_s ] = {}

		inspector_info = {}

		contents = File.open( $test_info.home_directory.to_s + file , 'rb' ).read

		contents_hex = contents.each_byte.to_a

		id = contents[ 0x0..0x3 ]

		total_bytes_hex = '0x' + contents_hex[ 0x4..0x7 ].map { |n| '%02X' % (n & 0xFF) }.join

		version_hex = '0x' + contents_hex[ 0x8..0x9 ].map { |n| '%02X' % (n & 0xFF) }.join

		header_size_hex = '0x' + contents_hex[ 0xA..0xB ].map { |n| '%02X' % (n & 0xFF) }.join

		number_of_sections_hex = '0x' + contents_hex[ 0xC..0xD ].map { |n| '%02X' % (n & 0xFF) }.join

		product_id_hex = '0x' + [ contents_hex[ 0xE ] ].map { |n| '%02X' % (n & 0xFF) }.join

		fw_version = contents[ 0x12..0x19 ]

		sn = contents[ 0x1A..0x21 ]

		sn_tail = contents[ 0x7C..0x7F ]

		poh = '0x' + contents_hex[ 0x22..0x25 ].map { |n| '%02X' % (n & 0xFF) }.join

		product_name = contents[ 0x42..0x49 ]

		page_offset = 0x80

		counter = 0

		loop do
			eye_catcher = contents[ page_offset.to_i..( page_offset.to_i + 7 ) ]

			page_offset += 8

			section_header_offset = '0x' + contents_hex[ ( page_offset.to_i )..( page_offset.to_i + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

			page_offset += 4

			section_header_length = '0x' + contents_hex[ ( page_offset.to_i )..( page_offset.to_i + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

			page_offset += 4

			counter += 1

			section_offset = section_header_offset.to_i(16)

			section_header_last_byte = section_offset + section_header_length.to_i(16)

			loop do
				# Log Entry Eye Catcher 
				log_entry_eye_catcher = contents[ section_offset..( section_offset + 7 ) ].to_s

				section_offset += 8

				offset_to_log_entry = '0x' + contents_hex[ section_offset..( section_offset + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

				section_offset += 4

				length_of_log_entry = '0x' + contents_hex[ section_offset..( section_offset + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

				section_offset += 4

				entry_offset = offset_to_log_entry.to_i(16)

				entry_data_last_byte = entry_offset + length_of_log_entry.to_i(16)

				loop do
					# Entry Name
					# Document says this is 4 bytes , but also says its 8 characters
					entry_name = contents[ entry_offset..( entry_offset + 7 ) ].to_s

					entry_offset += 8

					# Header Type
					header_type = '0x' + contents_hex[ entry_offset..( entry_offset + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

					entry_offset += 4

					# Version Major
					version_major = contents_hex[ entry_offset..( entry_offset + 1 ) ].map { |n| '%01X' % (n & 0xF) }.join

					entry_offset += 2

					# Version Minor
					version_minor = contents_hex[ entry_offset..( entry_offset + 1 ) ].map { |n| '%01X' % (n & 0xF) }.join

					entry_offset += 2

					entry_length = '0x' + contents_hex[ entry_offset..( entry_offset + 3 ) ].map { |n| '%02X' % (n & 0xFF) }.join

					entry_offset += 4

					reserved = 12

					entry_offset += reserved

					if entry_name.include?( 'HBLGP3E' )

						raw_data = contents[ entry_offset..entry_data_last_byte ]

						bin_3e = $test_info.home_directory.to_s + '3E.bin'

						File.binwrite( bin_3e , raw_data , 0 )

						json_file = $test_info.home_directory.to_s + '3E.json'

						cmd = '/home/everest/angel_bin/msgpack2json -di ' + bin_3e + ' > ' + json_file

						rc = ( %x( #{ cmd } ) ).chomp

						File.delete( bin_3e ) if File.exist?( bin_3e )

						json_data = File.read( json_file )

						File.delete( json_file ) if File.exist?( json_file )

						data_hash = JSON.parse( json_data )

						# FIXME KAL There is no PCODE in the HB 3E
						pcode = 0

						data_hash.each do |key , data|

							pcode += 1

							inspector_info[ pcode.to_s ] = {}

							inspector_info[ pcode.to_s ][ 'name' ] = key.to_s.downcase 

							inspector_info[ pcode.to_s ][ 'data' ] = data

							if key == 'life_used_percentage_x100' ; @drive_info[ :gbb_count ] = data ; end

							if key == 'bit_errors_ddr_single' ; @drive_info[ :ddr_single_bit_error_count ] = data ; end

							if key == 'bit_errors_sram_single' ; @drive_info[ :sram_single_bit_error_count ] = data ; end

							if key == 'glist_grown_blocks_for_erase_fail' || key == 'glist_grown_blocks_for_program_fail' || key == 'glist_grown_blocks_for_frame'

								@drive_info[ :gbb_count ] += data
							end
						end

						File.delete( json_file ) if File.exist?( json_file )
					end

					entry_offset += ( entry_data_last_byte - entry_offset ).to_i

					break if entry_offset == entry_data_last_byte
				end

				break if section_offset == section_header_last_byte
			end

			break if counter == number_of_sections_hex.to_i(16)
		end

		@inspector_info[ :log_pages ][ '0x3E' ][ inspector_date_time_stamp.to_s ] = inspector_info
	end

	def _sbdi( filename: nil , data_source: nil )

		transaction_id = 0

		until transaction_id == 2  do

			transaction_id += 1

			buffer_data = Array.new( 512 , 0x00 )

			# Snowbird Diagnostic Framework Design Document
			# 4.3.1 Host <-> Device Communication Protocol ( for the first 512 bytes of data )

			# Diagnostic Framework Protocol Signature 31:0 ( dec ) 1F:00 ( hex )
			buffer_data[ 0x00 .. 0x03 ] = [ 0x1E , 0xAB , 0x1D , 0xF0 ]

			buffer_data[ 0x20 .. 0x23 ] = [ 0x11 , 0xBA , 0x5E , 0xBA ]

			# Transaction ID 67:64 ( dec ) 40:43 ( hex )
			buffer_data[ 0x40 ] = transaction_id

			# Version ID 71:68 ( dec ) 47:44 ( hex )
			buffer_data[ 0x44 ] = 0x01

			# Command Data Arguments data structure 163:72 ( hex ) A3:48
			# Snowbird Diagnostic Framework Design Document
			# 2.2.1 Normalized Command Data Arguments
			# buffer offset 0x48 is byte 0 of Command Data Arguments

			buffer_data[ 0x48 ] = 0xF0 # OPCODE

			if transaction_id == 1

				data_size = 4

				# get 4 bytes to get the size of the data
				buffer_data[ 0x50 .. 0x57 ] = [ data_size , 0x00 , 0x00 , 0x00 , data_size , 0x00 , 0x00 , 0x00 ]

				# 2.2.2.4.1 FA Data ver. 1.0.0 – Runs in FE context
				buffer_data[ 0x60 .. 0x61 ] = [ 0x01 , 0x00 ] # options - read size : [ 0x01 , 0x00 ] , erase data : [ 0x02 , 0x00 ] , read data : [ 0x04 , 0x00 ]

				d1_total_data_size_bytes = 512

				d2_total_data_size_bytes = ( 512 + data_size )
			else
				byte50h = ( data_size.to_s.scan( /.{2}/ ) )[-1].to_i
				byte51h = ( data_size.to_s.scan( /.{2}/ ) )[-2].to_i

				byte54h = ( data_size.to_s.scan( /.{2}/ ) )[-1].to_i
				byte55h = ( data_size.to_s.scan( /.{2}/ ) )[-2].to_i

				f_log( [ 'byte50h : byte51h : byte54h : byte55h : ( int ) : ' + byte50h.to_s + ' : ' + + byte51h.to_s + ' : ' + byte54h.to_s + ' : ' + byte55h.to_s ] , -1 )
				f_log( [ 'byte50h : byte51h : byte54h : byte55h : ( hex ) : ' + byte50h.to_s(16) + ' : ' + + byte51h.to_s(16) + ' : ' + byte54h.to_s(16) + ' : ' + byte55h.to_s(16) + "\n" ] , -1 )

				buffer_data[ 0x50 .. 0x57 ] = [ byte50h , byte51h , 0x00 , 0x00 , byte54h , byte55h , 0x00 , 0x00 ]

				# 2.2.2.4.1 FA Data ver. 1.0.0 – Runs in FE context
				buffer_data[ 0x60 .. 0x61 ] = [ 0x04 , 0x00 ] # options - read size : [ 0x01 , 0x00 ] , erase data : [ 0x02 , 0x00 ] , read data : [ 0x04 , 0x00 ]

				d2_total_data_size_bytes = ( 512 + data_size )
			end

			f_log( [ 'data_size-' + transaction_id.to_s , data_size.to_s + ' : 0x' + data_size.to_s(16) ] , -1 )
			f_log( [ 'd1_total_data_size_bytes-' + transaction_id.to_s , d1_total_data_size_bytes.to_s + ' : 0x' + d1_total_data_size_bytes.to_s(16) ] , -1 )
			f_log( [ 'd2_total_data_size_bytes-' + transaction_id.to_s , d2_total_data_size_bytes.to_s + ' : 0x' + d2_total_data_size_bytes.to_s(16) + "\n" ] , -1 )

			if	data_source == 'parametrics' 

				buffer_data[ 0x62 .. 0x63 ] = [ 0x10 , 0x00 ] # FA Data Source - assert_dump_1 : [ 0x02, 0x00 ] , eventlog [ 0x08 , 0x00 ] , parametrics [ 0x10 , 0x00 ]

			elsif	data_source == 'eventlog' 

				buffer_data[ 0x62 .. 0x63 ] = [ 0x08 , 0x00 ]
			end

			# Clear Buffer
			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			# Fill buffer with data from data array for D1 command
			rc = $angel.buffer.set_array( buffer_data , @test_info[ :functions_buffer_id ] , 0 , buffer_data.length )

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			# d1_data_transfer_size_bytes should be < @drive_info[ :max_bytes_per_io ]
			d1_data_transfer_size_bytes = d1_total_data_size_bytes

			# DWORD-10 is transfer length in DWORDS
			rc = $angel.nvme_custom_command( 0xD1 , 0 , ( d1_data_transfer_size_bytes / 4 ) , 0 , transaction_id , 0 , 0 , 0 , @test_info[ :functions_buffer_id ] , d1_data_transfer_size_bytes )

			unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

			# Clear Buffer
			$angel.buffer.clear( @test_info[ :functions_buffer_id ] )

			# Buffer changes for D2 command
			buffer_data[ 0x60 .. 0x63 ] = [ 0x00 , 0x00 , 0x00 , 0x00 ]

			# Fill buffer with data from data array for D2 command
			rc = $angel.buffer.set_array( buffer_data , @test_info[ :functions_buffer_id ] , 0 , buffer_data.length ) # to get the data

			unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

			d2_data_transfer_size_bytes = [ d2_total_data_size_bytes , 1048576 ].min

			offset = 0

			until ( offset == d2_total_data_size_bytes )

				f_log( [ 'offset' , offset.to_s ] , -1 )

				f_log( [ 'd2_data_transfer_size_bytes' , d2_data_transfer_size_bytes.to_s + "\n" ] , -1 )

				# DWORD-10 is transfer length in dwords
				# DWORD-13 is offset in dwords
				rc = $angel.nvme_custom_command( 0xD2 , 0 , ( d2_data_transfer_size_bytes / 4 ) , 0 , transaction_id , ( offset / 4 ) , 0 , 0 , @test_info[ :functions_buffer_id ] , d2_data_transfer_size_bytes )

				unless rc == 0 ; force_failure( category: 'nvme_custom_command_failure' , data: rc.to_s ) ; return ; end

				if	data_source == 'parametrics'

					rc = $angel.buffer.dump_buffer_with_offset( @test_info[ :functions_buffer_id ] , 512 , filename , d2_data_transfer_size_bytes , AngelCore::FileFormat_Binary , AngelCore::FileMode_Create )

					unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end

				elsif	data_source == 'eventlog'

					# Dump the data buffer to file
					rc = $angel.buffer.dump_buffer_with_offset( @test_info[ :functions_buffer_id ] , 512 , filename , d2_data_transfer_size_bytes , AngelCore::FileFormat_Binary , AngelCore::FileMode_Append )

					unless rc == 0 ; force_failure( category: 'angel_command_failure' , data: rc.to_s ) ; return ; end
				end

				offset += d2_data_transfer_size_bytes

				if ( d2_total_data_size_bytes - offset ) < d2_data_transfer_size_bytes ; d2_data_transfer_size_bytes = ( d2_total_data_size_bytes - offset ) ; end
			end

			if transaction_id == 1 ; data_size = $angel.buffer.get_integer( @test_info[ :functions_buffer_id ] , 512 , 4 , 'little' , 'unsigned' ) ; end
		end
	end

	def _get_tmm_files( tmm: nil )

		if File.exists?( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tmms/' + tmm.to_s )

			return
		else
			cmd = 'cp -R ' + $fw_repo + @drive_info[ :fw ].to_s.upcase + '/tmms ' + @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/'

			return_data = ( ssh( cmd: cmd.to_s ) ).split( "\n" )[0]

			unless File.exists?( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tmms/' + tmm.to_s )

				force_failure( category: 'file_not_found' , data: $fw_repo + @drive_info[ :fw ].to_s.upcase + '/tmms/' + tdd.to_s )
			end
		end
	end

	def _get_tdd_files( tdd: nil )

		if File.exists?( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tdds/' + tdd.to_s )

			return
		else
			cmd = 'cp -R ' + $fw_repo + @drive_info[ :fw ].to_s.upcase + '/tdds ' + @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/'

			return_data = ( ssh( cmd: cmd.to_s ) ).split( "\n" )[0]

			unless File.exists?( @test_info[ :local_fw_repo ] + @drive_info[ :fw ].to_s.upcase + '/tdds/' + tdd.to_s )

				force_failure( category: 'file_not_found' , data: $fw_repo + @drive_info[ :fw ].to_s.upcase + '/tdds/' + tdd.to_s )
			end
		end
	end

	def _get_firmware_file( dir: nil , fw_version: nil , fw_customer_id: nil , log: false )

		local_repo_fw_file = Dir[ @test_info[ :local_fw_repo ] + fw_version.to_s.upcase + '/*' + fw_customer_id.to_s + '.vpkg' ][0]

		if File.exists?( local_repo_fw_file.to_s )

			return
		else
			cmd = 'ls ' + dir.to_s + fw_version.to_s.upcase + '/*' + fw_customer_id.to_s.upcase + '*.vpkg'

			return_data = ( ssh( cmd: cmd.to_s ) ).split( "\n" )[0]

			if      return_data == nil

				_warning_counter( category: 'file_not_found' , data: 'FW FILE NOT FOUND IN ' + dir.to_s + fw_version.to_s + '/' )

                        elsif   return_data.include?( 'No such file or directory' ) || return_data == nil

				_warning_counter( category: 'file_not_found' , data: 'FW FILE NOT FOUND IN ' + dir.to_s + fw_version.to_s + '/' )
			else
				FileUtils.mkdir( @test_info[ :local_fw_repo ] + fw_version.to_s.upcase , mode: 0777 ) unless File.exists?( @test_info[ :local_fw_repo ] + fw_version.to_s.upcase )

				fw_file = return_data

				destination = @test_info[ :local_fw_repo ] + fw_version.to_s.upcase + '/'

				cmd = 'cp ' + fw_file.to_s + ' ' + destination.to_s

				return_data = ssh( cmd: cmd.to_s )

				if return_data == ''

					if log == true ; f_log( [ 'INFO' , 'FW FILE COPIED TO LOCAL FW REPO' , destination.to_s + ( fw_file.split( '/' ) )[-1] + "\n" ] ) ; end
				else
					force_failure( category: 'file_copy_failure' , data: return_data.inspect )
				end
			end
		end
	end

	def _get_counters_handler_xml( dir: nil , fw_version: nil , fw_customer_id: nil )

		local_repo_counters_handler_xml = @test_info[ :local_fw_repo ] + fw_version.to_s.upcase + '/countershandler.xml'

		local_repo_dict_archive_file = @test_info[ :local_fw_repo ] + fw_version.to_s.upcase + '/DictArchive.zip'

		if File.exists?( local_repo_counters_handler_xml )

			return

		elsif File.exists?( local_repo_dict_archive_file )

			Zip::File.open( local_repo_dict_archive_file ) do |zip|

				zip.each do |file|

					next unless file.name == 'countershandler.xml'

					zip.extract( file.name.to_s , local_repo_counters_handler_xml ) unless File.exists?( local_repo_counters_handler_xml )

					FileUtils.chmod 0777 , local_repo_counters_handler_xml
				end
			end

		else
			cmd = 'cp ' + dir + fw_version.to_s.upcase + '/DictArchive.zip ' + @test_info[ :local_fw_repo ] + fw_version.to_s.upcase + '/'

			return_data = ssh( cmd: cmd.to_s )

			if return_data == ''

				Zip::File.open( local_repo_dict_archive_file ) do |zip|

					zip.each do |file|

						next unless file.name == 'countershandler.xml'

						zip.extract( file.name.to_s , local_repo_counters_handler_xml ) unless File.exists?( local_repo_counters_handler_xml )

						FileUtils.chmod 0777 , local_repo_counters_handler_xml
					end
				end
			else
				force_failure( category: 'file_copy_failure' , data: return_data.inspect )
			end
		end
	end

	def _get_sub_power_board_uptime()

		unless @tester_info[ :tester_type ] == 'G100' || @tester_info[ :tester_type ] == 'G10' ; return ; end

		# Update timer registers (adr 0x38 - 0x3B) with current counter value
		$power.set_card_register( 0x01 , 0x10 )

		sub_power_board_uptime_days_upper_value = $power.get_card_register( 0x3A ) << 8

		sub_power_board_uptime_days_lower_value = $power.get_card_register( 0x3B )

		sub_power_board_uptime_days = sub_power_board_uptime_days_upper_value | sub_power_board_uptime_days_lower_value

		sub_power_board_uptime_hours = $power.get_card_register( 0x39 )

		sub_power_board_uptime_hours = sub_power_board_uptime_hours + ( sub_power_board_uptime_days * 24 )

		sub_power_board_uptime_minutes = $power.get_card_register( 0x38 )

		data = sprintf( "%03d" , sub_power_board_uptime_hours.to_s ) + ':' + sprintf( "%02d" , sub_power_board_uptime_minutes.to_s )

		f_log( [ 'INFO' , 'SUB-POWER BOARD' , 'FW' , 'VERSION' , ( $power.get_card_version ).split( "\s" )[2] ] )

		f_log( [ 'INFO' , 'SUB-POWER BOARD' , 'UPTIME' , 'HHH:MM' , data.to_s + "\n" ] )
	end

	def _get_sub_power_board_registers()

		unless @tester_info[ :tester_type ] == 'G100' || @tester_info[ :tester_type ] == 'G10' ; return ; end

		error_detected = -1

		data = {}

		registers = [ 0x3C , 0x3D , 0x3E , 0x3F ]

		registers.each do |register|

			rc = '0x' + ( $power.get_card_register( register ) ).to_s(16)

			unless rc == '0x0' ; error_detected = 1 ; end

			data[ '0x' + register.to_s(16) ] = rc

			_decode_sub_power_board_status_code( register: '0x' + register.to_s(16).upcase , status_code: rc )
		end

		log()

		@error_info[ :power_failure_info ] = data
	end

	def _inspector_csv( *opt , log: true )

		unless opt[0].nil? ; log = opt[0] ; end

		inspector_csv_file = $test_info.home_directory + @test_logs[ :inspector ].to_s

		if	@test_logs[ :inspector ] == nil

			filename = 'ANGEL_INSPECTOR-DATA_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + @drive_info[ :sn ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.csv'

			@test_logs[ :inspector ] = filename

			if log == true ; f_log( [ 'FUNC' , 'INSPECTOR CSV' , 'CREATE' , @test_logs[ :inspector ].to_s + "\n" ] ) ; end

			inspector_csv_file = $test_info.home_directory + @test_logs[ :inspector ]

			headers = %w{ INSTANCE OPERATION TEST_START_DATE SYSTEM_ID TEST_SOFTWARE ANGEL_PACKAGE_VERSION BUS_INTERFACE BUS_SPEED TEST_SCRIPT_NAME DRIVE_MODEL_NUM DRIVE_CAPACITY FIRMWARE_REV BLOCK_SIZE DRIVE_SERIAL_NUM }

			counter = 0 ; @inspector_info[ :instance_counter ] = 1

			$angel.log.write_file( inspector_csv_file.to_s , "TABLE=TEST_INFORMATION\n" , 'a' )

			headers.each do |header|

				$angel.log.write_file( inspector_csv_file.to_s , header.to_s , 'a' )

				counter += 1

				if counter.to_i == headers.length ; $angel.log.write_file( inspector_csv_file.to_s , "\n" , 'a' ) ; else ; $angel.log.write_file( inspector_csv_file.to_s , ',' , 'a' ) ; end
			end

			if @test_info[ :script_name ] == 'TC-RGT'

				script_name = @test_info[ :script_name ].gsub( '-' , '' ).to_s.upcase
			else
				script_name = @test_info[ :script_name ].gsub( '-' , '_' ).to_s.upcase
			end

			if @test_info[ :port_configuration ] == '1x4'

				current_link_rate = @drive_info[ :current_link_speed ][0].to_s + '.' + @drive_info[ :current_link_width ][0].to_s

			elsif @test_info[ :port_configuration ] == '2x2'

				current_link_rate = @drive_info[ :current_link_speed ][1].to_s + '.' + @drive_info[ :current_link_width ][0].to_s + ':' + @drive_info[ :current_link_speed ][1].to_s + '.' + @drive_info[ :current_link_width ][1].to_s
			end

			data_array = [ @inspector_info[ :instance_counter ].to_s , script_name , @test_info[ :start_time ].to_s[0..-7].to_s , @test_info[ :slot_id ].to_s , 'ANGEL' , @test_info[ :angel_package ].to_s , 'NVME' , current_link_rate.to_s , script_name + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :fw_feature_set ].to_s.upcase + '_' + @drive_info[ :fw_customer_id ].to_s + '_' + @test_info[ :test_phase ].to_s.upcase , @drive_info[ :pn ].to_s , @drive_info[ :capacity ].to_s , @drive_info[ :fw ].to_s , @drive_info[ :block_size ].to_s , @drive_info[ :sn ].to_s ]

			counter = 0

			data_array.each do |data|

				$angel.log.write_file( inspector_csv_file.to_s , data.to_s , 'a' )

				counter += 1

				if counter.to_i == data_array.length ; $angel.log.write_file( inspector_csv_file.to_s , "\n" , 'a' ) ; else ; $angel.log.write_file( inspector_csv_file.to_s , ',' , 'a' ) ; end
			end

		elsif	@inspector_info[ :log_pages ][ '0x02' ].length == 0 && @inspector_info[ :log_pages ][ '0xD0' ].length == 0 && @inspector_info[ :log_pages ][ '0x3E' ].length == 0 && @inspector_info[ :log_pages ][ '0xC0_MSFT' ].length == 0 && @inspector_info[ :log_pages ][ '0xC1_MSFT' ].length == 0 && @inspector_info[ :log_pages ][ '0xC2_MSFT' ].length == 0 && @inspector_info[ :io_tracker ].length == 0

			return
		else
			f_log( [ 'FUNC' , 'INSPECTOR CSV' , 'UPDATED' + "\n" ] )
		end

		@inspector_info[ :log_pages ].each_key do |log_page|

			@inspector_info[ :log_pages ][ log_page.to_s ].each_key do |date_time|

				@inspector_info[ :instance_counter ] += 1

				if log_page.to_s == '0x3E'

					headers = "\nINSTANCE,PARAM_CODE,FIELD_NAME,FIELD_VALUE,TIME_PULLED\n"

					$angel.log.write_file( inspector_csv_file.to_s , 'TABLE=UA_LogPage' + log_page.to_s + headers.to_s , 'a' )
				else
					headers = "\nINSTANCE,LOG_PAGE,FIELD_NAME,FIELD_VALUE,TIME_PULLED\n"

					$angel.log.write_file( inspector_csv_file.to_s , 'TABLE=UA_LogPage' + log_page.to_s + headers.to_s , 'a' )
				end

				@inspector_info[ :log_pages ][ log_page.to_s ][ date_time.to_s ].each_key do |key|

					if log_page.to_s == '0x3E'

						pcode = key

						name = @inspector_info[ :log_pages ][ log_page.to_s ][ date_time.to_s ][ pcode.to_s ][ 'name' ].to_s

						value = @inspector_info[ :log_pages ][ log_page.to_s ][ date_time.to_s ][ pcode.to_s ][ 'data' ].to_s

						data = @inspector_info[ :instance_counter ].to_s + ',' + pcode.to_s + ',' + name.to_s + ',' + value.to_s + ',' + date_time.to_s + "\n"
					else
						if log_page.include?( '_' )

							log_page_stamp = Integer( log_page.to_s.split( '_' )[0] ).to_s
						else
							log_page_stamp = Integer( log_page.to_s ).to_s
						end

						value = @inspector_info[ :log_pages ][ log_page.to_s ][ date_time.to_s ][ key.to_s ]

						# Removes the entry number from the name ( valid_fw_activation_history_entries-1 => valid_fw_activation_history_entries )
						if log_page.to_s == '0xC2_MSFT' ; if key.include?( '-' ) ; key = key.split( '-' )[0] ; end ; end

						data = @inspector_info[ :instance_counter ].to_s + ',' + log_page_stamp.to_s + ',' + key.to_s.downcase + ',' + value.to_s + ',' + date_time.to_s + "\n"
					end

					$angel.log.write_file( inspector_csv_file.to_s , data.to_s , 'a' )
				end
			end

			 @inspector_info[ :log_pages ][ log_page.to_s ].clear
		end

		@inspector_info[ :io_tracker ].each_key do |io_tracker_id|

			@inspector_info[ :instance_counter ] += 1

			headers = "\nINSTANCE,OPERATION,DURATION,READ_BYTES,WRITE_BYTES,OPERATION_COUNT\n"

			$angel.log.write_file( inspector_csv_file.to_s , 'TABLE=ANGEL_IO_TRACKER' + headers.to_s , 'a' )

			duration = @inspector_info[ :io_tracker ][ io_tracker_id.to_sym ][ :duration ]

			read_bytes = @inspector_info[ :io_tracker ][ io_tracker_id.to_sym ][ :read_bytes ]

			write_bytes = @inspector_info[ :io_tracker ][ io_tracker_id.to_sym ][ :write_bytes ]

			operation_count = @inspector_info[ :io_tracker ][ io_tracker_id.to_sym ][ :operation_count ]

			data = @inspector_info[ :instance_counter ].to_s + ',' + io_tracker_id.to_s + ',' + duration.to_s + ',' + read_bytes.to_s + ',' + write_bytes.to_s + ',' + operation_count.to_s + "\n"

			$angel.log.write_file( inspector_csv_file.to_s , data.to_s , 'a' )
		end

		@inspector_info[ :io_tracker ].clear
	end

	def _decode_sub_power_board_status_code( register: nil , status_code: nil )

		if status_code == '0x0'

			status_details = 'No Error'

		elsif	register == '0x3C' || register == '0x3D'

			case status_code

				when '0x10' ; status_details = 'Not clear error status'
				when '0x11' ; status_details = 'No Detect DUT'
				when '0x12' ; status_details = 'Mis-match power mode'
				when '0x13' ; status_details = 'Mis-match voltage value'
				when '0x14' ; status_details = 'Off mode of Power profile'
				when '0x21' ; status_details = 'No Detect DUT'
				when '0x22' ; status_details = 'Change value of power control1 register'
				when '0x23' ; status_details = 'Change value of power control2_3 register'
				when '0x24' ; status_details = 'Change value of power control5_6 register'
				when '0x26' ; status_details = 'Change value of power control19 register'
				when '0x29' ; status_details = 'Out of voltage limit'
				else ; status_details = 'UNKNOWN'
			end

		elsif	register == '0x3E' || register == '0x3F'

			case status_code

				when '0x10' ; status_details = 'Not clear error status'
				when '0x11' ; status_details = 'No Detect DUT'
				when '0x12' ; status_details = 'Mis-match power mode and power profile'
				when '0x13' ; status_details = 'Mis-match power mode and power profile'
				when '0x14' ; status_details = 'Off mode of Power profile'
				when '0x21' ; status_details = 'No Detect DUT'
				when '0x25' ; status_details = 'Change value of power control8 register'
				when '0x26' ; status_details = 'Change value of power control19 register'
				when '0x27' ; status_details = 'Change value of power control20_21 register'
				when '0x28' ; status_details = 'Change value of power control22_23 register'
				when '0x29' ; status_details = 'Out of voltage limit'
				else ; status_details = 'UNKNOWN'
			end

		else ; status_details = 'UNKNOWN' ; end

		if status_details == 'No Error'

			f_log( [ 'INFO' , 'SUB-POWER BOARD' , 'REGISTER' , register.to_s , '( ' + status_code.to_s + ' ) ' + status_details.to_s.upcase ] )
		else
			_warning_counter( category: 'SUB-POWER BOARD' , data: 'REGISTER : ' + register.to_s + ' : ( ' + status_code.to_s + ' ) ' + status_details.to_s.upcase )
		end
	end

	def _set_cell_color( background_color: nil , text_color: nil )

		begin
			data = 'CCC,' + background_color.to_s + ',' + text_color.to_s

			file = $test_info.home_directory + 'status'

			fh = File.open( file , 'w' ) ; fh.write( data ) ; fh.close

		rescue StandardError => error

			_warning_counter( catergory: '_set_cell_color' , data: error.to_s )
		end
	end

	def _copy_angel_host_logs()

		if @test_info[ :copy_host_logs ] == false ; return ; end

		f_log( [ 'FUNC' , 'COPY' , 'HOST LOGS' ] )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		angel_host_logs = Dir[ '/home/everest/angel_host/bin/log/*' ]

		start_date = @test_info[ :start_time ].to_s.split( /\s+/ )[0].gsub( '-' , '' )

		angel_host_logs.each do |file|

	 		date_stamp = file.split( '_' )[-1]

			next unless date_stamp >= start_date

			begin
				FileUtils.copy( file , $test_info.home_directory ) if File.exists?( file )

			rescue StandardError => error

				_warning_counter( category: '_copy_angel_host_logs' , data: error.to_s )
			end

			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction
		end
	end

	def _copy_port_logs()

		f_log( [ 'FUNC' , 'COPY' , 'PORT LOGS' ] )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		port_logs = Dir[ '/home/everest/client' + $test_info.client.to_s + '/port' + $test_info.port.to_s + '_*.log' ]

		port_logs.each do |file|

			begin
				FileUtils.copy( file , $test_info.home_directory ) if File.exists?( file )

			rescue StandardError => error

				_warning_counter( category: '_copy_port_logs' , data: error.to_s )
			end

			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction
		end
	end

	def _copy_instruction_logs()

		f_log( [ 'FUNC' , 'COPY' , 'INSTRUCTION LOGS' ] )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		instruction_log = Dir[ '/home/everest/client' + $test_info.client.to_s + '/instruction*.log' ]

		instruction_log.each do |file|

			begin
				FileUtils.copy( file , $test_info.home_directory ) if File.exists?( file )

			rescue StandardError => error

				_warning_counter( category: '_copy_instruction_logs' , data: error.to_s )
			end

			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction
		end
	end

	# Copies /home/everest/clientX/client_manager.log to current test directory
	def _copy_client_manager_log()

		client_manager_log = nil

		f_log( [ 'FUNC' , 'COPY' , 'CLIENT MANAGER LOG' ] )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		if	File.exists?( '/home/everest/client' + $test_info.client.to_s + '/client_manager.log' )

			client_manager_log = '/home/everest/client' + $test_info.client.to_s + '/client_manager.log'

		elsif	File.exists?( '/home/everest/client' + $test_info.client.to_s + '/client_manager_log/client_manager.log' )

			client_manager_log = '/home/everest/client' + $test_info.client.to_s + '/client_manager_log/client_manager.log'
		end

		begin
			FileUtils.copy( client_manager_log , $test_info.home_directory ) if File.exists?( client_manager_log )

		rescue StandardError => error

			_warning_counter( category: '_copy_client_manager_log' , data: error.to_s )
		end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction
	end

	# Copies /home/everest/clientX/power_manager.log to current test directory
	def _copy_power_manager_log()

		power_manager_log = '/home/everest/client' + $test_info.client.to_s + '/power_manager.log'

		f_log( [ 'FUNC' , 'COPY' , 'POWER MANAGER LOG' ] )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		begin
			FileUtils.copy( power_manager_log , $test_info.home_directory.to_s ) if File.exist?( power_manager_log )

		rescue StandardError => error

			_warning_counter( category: '_copy_power_manager_log' , data: error.to_s )
		end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction
	end

	# Reads and Parses the client syslog and moves the pertinent info into the test directory
	def _copy_sys_log()

		f_log( [ 'FUNC' , 'COPY' , 'SYSLOG' ] )

		begin
			syslog_in = File.open( '/var/log/sys.log' ) if File.exists?( '/var/log/sys.log' )

		rescue StandardError => error

			_warning_counter( category: '_copy_sys_log' , data: error.to_s )
		end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		begin
			syslog_out = File.open( $test_info.home_directory + 'syslog.log' , 'w' )

		rescue StandardError => error

			_warning_counter( category: '_copy_sys_log' , data: error.to_s )
		end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		start_time_epoch = ( _time_to_epoch( time: @test_info[ :start_time ] ) - 120 )

		begin
			syslog_in.each do |line|

				# Removes invalid character encoding
				line.scrub!

				line.chomp!

				( date , time , text ) = line.split( /\s+/ , 3 )

				next if text == nil

				date.gsub!( '/' , '-' )

				date_time = date + ' ' + time

				date_time_stamp_epoch = _time_stamp_to_epoch( timestamp: date_time.to_s )

				next unless date_time_stamp_epoch >= start_time_epoch

				syslog_out.write( date_time.to_s + ' ' + text + "\n" )

				# This should stop Angel from going No Response During non-Angel commands
				$angel.check_instruction
			end
	
		rescue StandardError => error

			_warning_counter( category: '_copy_sys_log' , data: error.to_s )
		end

		syslog_in.close

		syslog_out.close
	end

	def _copy_kern_log()

		kern_log = '/var/log/kern.log'

		var_log_kern_log = read_file( file: kern_log )

		start_time_epoch = _time_to_epoch( time: @test_info[ :start_time ] )

		kern_log_formated = File.open( $test_info.home_directory + 'kern.log.client' + $test_info.client.to_s , 'w' )

		var_log_kern_log.each do |line|

			( month , day , time , text ) = line.split( /\s+/ , 4 )

			next if text == nil

			date_time_stamp_epoch = _time_stamp_to_epoch( timestamp: ( month + ' ' + day + ' ' + time ).to_s )

			next unless date_time_stamp_epoch >= start_time_epoch

			kern_log_formated.write( Time.parse( ( month + ' ' + day + ' ' + time ).to_s ).strftime( "%Y-%m-%d %H:%M:%S" ) + ' ' + text + "\n" )

			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction
		end

		kern_log_formated.close

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction
	end

	# bin_file is the parametrics data ( no header )
	def _decode_parametrics( bin_file: nil )

		unless @test_info[ :enable_parametrics ] == true ; return ; end

		fw_version = bin_file.split( '_' )[ -4 ]

		counters_handler_file = '/home/everest/angel_fw_repo/' + fw_version.to_s.upcase + '/countershandler.xml'

		if	File.exist?( counters_handler_file )

			counters_handler_hash = XmlSimple.xml_in( counters_handler_file )
		else
			@test_info[ :enable_parametrics ] = false

			force_failure( category: 'file_not_found' , data: counters_handler_file )
		end

		parametrics_data_bin = File.open( $test_info.home_directory + bin_file , 'rb' ).read

		parametrics_data_hex = parametrics_data_bin.each_byte.to_a

		date_stamp = bin_file.split( '_' )[-2]

		time_stamp = bin_file.split( '_' )[-1].sub!( '.bin' , '' )

		inspector_date_time_stamp = date_stamp[0] + date_stamp[1] + date_stamp[2] + date_stamp[3] + '/' + date_stamp[4] + date_stamp[5] + '/' + date_stamp[6] + date_stamp[7] + ' ' + time_stamp[0] + time_stamp[1] + ':' + time_stamp[2] + time_stamp[3] + ':' + time_stamp[4] + time_stamp[5]

		inspector_info = {} ; offset = 0 ; total = 0

		( counters_handler_hash[ 'table' ][1][ 'entry' ] ).each do |hash|

			multiplier = 1

			if hash[ 'pcode' ].include?( '-' )

				pcode = hash[ 'pcode' ].split( '-' )

				multiplier = ( pcode[-1].hex - pcode[0].hex ) + 1

				data_length = ( hash[ 'size' ].to_i * multiplier.to_i )

				first_byte = offset ; last_byte = ( offset + data_length - 1 )

				data_array_little_endien = parametrics_data_hex[ first_byte .. last_byte ]

				data_string_little_endien = data_array_little_endien.map { |n| '%02X' % ( n & 0xFF ) }.join

				data = "b'" + data_string_little_endien + "'"
			else
				pcode = hash[ 'pcode' ]

				data_length = ( hash[ 'size' ].to_i * multiplier.to_i )

				first_byte = offset ; last_byte = ( offset + data_length - 1 )

				data_array_little_endien = parametrics_data_hex[ first_byte .. last_byte ]

				data_array_big_endien = data_array_little_endien.reverse

				data_string_big_endien = data_array_big_endien.map { |n| '%02X' % (n & 0xFF) }.join

				data = data_string_big_endien

				data.gsub!( /^[0]+/ , '' )

				if data == '' ; data = 0 ; end

				data = '0x' + data.to_s
			end

			unless pcode.class.to_s == 'Array'

				inspector_info[ pcode.to_s ] = {}
				inspector_info[ pcode.to_s ][ 'name' ] = hash[ 'name' ].to_s
				inspector_info[ pcode.to_s ][ 'data' ] = Integer( data ).to_s

				# Convert this to a signed integer
				if hash[ 'name' ].include?( 'case_composite_temperature' ) || hash[ 'name' ].include?( 'drive_temperature' )

					inspector_info[ pcode.to_s ][ 'data' ] = Integer( ([ Integer( data ) ].pack('S*').unpack('s*') )[0] ).to_s
				end
			end

			#data_decoded[ hash[ 'name' ] ] = data.to_s

			offset += data_length ; total += data_length
		end

		@inspector_info[ :log_pages ][ '0x3E' ][ inspector_date_time_stamp.to_s ] = {}

		@inspector_info[ :log_pages ][ '0x3E' ][ inspector_date_time_stamp.to_s ] = inspector_info
	end

	def _get_database_field_count()

		unless @test_info[ :enable_database ] == true ; return ; end

		sql_cmd = 'SELECT COUNT(*) AS NUMBEROFCOLUMNS FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema = \"' + @sql_info[ :sql_status_database ].to_s + '\" AND table_name = \"' + @sql_info[ :sql_status_table ].to_s + '\"'

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --query --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + sql_cmd.to_s + '"'

		rc = ssh( cmd: cmd ).chomp

		@sql_info[ :number_of_fields ] = ( rc.split( '>' ) )[-1].to_i
	end

	# Calls ruby script write-to-sql.rb to interface with PTL mysql status database
	# If status is 'Running' creates a new database entry
	# If status is other than 'Running' updates database record
	def _update_database( status: nil )

		unless @test_info[ :enable_database ] == true ; return ; end

		if	status.upcase == 'RUNNING'

			data = read_file( file: $test_info.home_directory.to_s + 'Database.rb' )

			lib_database_rev = data.grep( /VERSION/ )[0].chomp.split( / = / )[-1]

			data = read_file( file: $test_info.home_directory.to_s + 'precheck.rb' )

			precheck_version = data.grep( /VERSION/ )[0].chomp.split( / = / )[-1].gsub( "'" , '' )

			ptl_lib_versions = precheck_version.to_s + '/' + Workloads::VERSION.to_s + '/' + Functions::VERSION.to_s + '/' + lib_database_rev.to_s

			comment = 'NA'

			get_angel_versions()

			drive_temp = _get_core_log_temps()

			# Not all Angel versions are available at the start of the test
			angel_versions_data = @test_info[ :angel_package ] + '/' + @test_info[ :angel_core ] + '/' + @test_info[ :angel_rb ] + '/' + @test_info[ :angel_host ] + '/' + @test_info[ :power_manager ]

			date = ( @test_info[ :start_time ].to_s ).split( ' ' )[0]

			time = ( @test_info[ :start_time ].to_s ).split( ' ' )[1]

			if @drive_info[ :data_current ] == true ; data_state = 'CURRENT' ; else ; data_state = 'STALE' ; end

			data = [ $test_info.start_script.to_s , date.to_s , time.to_s , @test_info[ :slot_id ].to_s , @tester_info[ :kernel_release ].to_s , @tester_info[ :driver_version ].to_s , @test_info[ :test_phase ].to_s.upcase , @test_info[ :port_configuration ].to_s , @tester_info[ :ifc_type ].to_s + ' GEN' + @tester_info[ :pci_gen ].to_s , @drive_info[ :product_family ].to_s.upcase , @drive_info[ :pn ].to_s , @drive_info[ :model ].to_s , @drive_info[ :product_name ].to_s , @drive_info[ :sn ].to_s , @drive_info[ :fw ].to_s , @drive_info[ :tmm_version ].to_s , @drive_info[ :capacity ].to_s , @drive_info[ :block_size ].to_s , @drive_info[ :nand_usage ].to_s , @drive_info[ :gbb_count ].to_s , $test_status.operation_count.to_s , $test_status.read_bytes.to_s , $test_status.write_bytes.to_s , @drive_info[ :power_on_hours ].to_s , status.to_s.upcase , data_state , @test_info[ :test_mode ].to_s , 'NULL' , @test_info[ :power_cycle_count ].to_s , '00:00:00' , drive_temp.to_s , 'NULL' , 'NULL' , 'NULL' , 'NA' , 'NA' , 'NA' , 'NA' , 'NA' , 'NA' , 'NA' , 'NULL' , comment , ptl_lib_versions , angel_versions_data , 'NULL' , 'NULL' , 'NULL' , 'NULL' , @drive_info[ :customer ].to_s + ' : ' + @test_info[ :jira_customer ].to_s , @drive_info[ :fw_feature_set ].to_s ]

			# Reduces the data arrary if the databse does not have the new fields due to tests in process
			# @sql_info[ :number_of_fields ] includes the record id , the data arrary does not
			if ( data.count.to_i + 1 ) > @sql_info[ :number_of_fields ].to_i ; data.pop( ( data.count.to_i + 1 ) - @sql_info[ :number_of_fields ].to_i ) ; end

			data = data.map{ |x| x.gsub!( /\s+/ , ' ' ) ; x.gsub!( /\n+/ , '' ) ; x.to_s }.join( "," )

			cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --insert --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + data + '"'

			@sql_info[ :record_id ] = _sql_insert( cmd: cmd )

			f_log( [ 'FUNC' , 'DATABASE' , @sql_info[ :sql_status_database ].to_s.upcase , 'CREATE RECORD' , @sql_info[ :record_id ].to_s + "\n" ] )

			return
		end

		f_log( [ 'FUNC' , 'DATABASE' , @sql_info[ :sql_status_database ].to_s.upcase , 'UPDATE RECORD' , @sql_info[ :record_id ].to_s + "\n" ] )

		if status.upcase == 'FAILED'

			if @drive_info[ :data_current ] == true

				data_state = 'CURRENT'
			else
				data_state = 'STALE'
			end

			hash = {

				'set'   => {

					'fields' => [ 'Status' , 'Data State' , 'Fail Sequence' , 'Failure Info' , 'Failure Category' , 'NVME RC' , 'IOCTL Code' , 'OS RC' , 'PF Code' , 'Shack Builder Link' , 'Assert Present' ] ,

					'data'  => [ 'Failed' , data_state , @error_info[ :trace ].gsub!( "\n" , ' ' ).to_s , @error_info[ :script_failure_info ].to_s , @error_info[ :category ] , @error_info[ :nvme_rc ] , @error_info[ :ioctl_rc ] , @error_info[ :os_rc ].to_s , @error_info[ :pfcode ].to_s , @test_logs[ :shack_builder_e6 ].to_s , @drive_info[ :assert_present ].to_s.upcase ]
				} ,

				'where' => {

					'fields' => [ 'Record' ] ,

					'data'  => [ @sql_info[ :record_id ].to_s ] ,

					'join'  => 'AND'
				} ,
			}

			cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --update --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + hash.inspect + '"'

			_sql_update( cmd: cmd )
		end

		query = 'UPDATE ' + @sql_info[ :sql_status_table ].to_s + ' SET \`NAND Usage\` = CONCAT( \`NAND Usage\` , \":' + @drive_info[ :nand_usage ].to_s + '\" ) WHERE Record = ' + @sql_info[ :record_id ].to_s

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --query --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + query + '"'

		_sql_update( cmd: cmd )

		query = 'UPDATE ' + @sql_info[ :sql_status_table ].to_s + ' SET POH = CONCAT( POH , \":' + @drive_info[ :power_on_hours ].to_s + '\" ) WHERE Record = ' + @sql_info[ :record_id ].to_s

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --query --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + query + '"'

		_sql_update( cmd: cmd )

		query = 'UPDATE ' + @sql_info[ :sql_status_table ].to_s + ' SET GBBs = CONCAT( GBBs , \":' + @drive_info[ :gbb_count ].to_s + '\" ) WHERE Record = ' + @sql_info[ :record_id ].to_s

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --query --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + query + '"'

		_sql_update( cmd: cmd )

		start_date_time = @test_info[ :log_directory ].split( '_' )[-1]

		start_date_time = start_date_time.gsub( '-' , '_' )

		destination_directory = @test_info[ :slot_id ].to_s + '_' + @test_info[ :script_name ].to_s + '_' + @test_info[ :test_phase ] + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :sn ].to_s + '_' + start_date_time.to_s

		last_power_on = Time.at( Time.now - @drive_info[ :last_power_on ] ).utc.strftime( '%H:%M:%S' )

		( hours , mins , secs ) = ( Time.at( ( Time.now - @test_info[ :start_time ] ) ).utc.strftime( '%H:%M:%S' ) ).split( ':' )

		runtime = ( hours.to_i + ( ( ( ( Time.now - @test_info[ :start_time ] ) / ( 24.0*60*60 ) ).floor ).to_i * 24 ) ).to_s + ':' + mins.to_s + ':' + secs.to_s

		drive_amps = ( $power.get_ampere )[0].to_s + '/' + ( $power.get_ampere )[1].to_s

		drive_temp = _get_core_log_temps()

		if @drive_info[ :data_current ] == true ; data_state = 'CURRENT' ; else ; data_state = 'STALE' ; end

		hash = {
			'set'   => {
				'fields' => [ 'Status' , 'Data State' , 'Runtime' , 'Operation Count' , 'Read Byte Count' , 'Write Byte Count' , 'Test Mode' , 'PC COUNT' , 'Last Power On' , 'Drive Temp' , 'Drive Voltage' , 'Drive Amps' , 'Assert Present' , 'Log Directory' , 'Test Logs' , 'TMM' ] ,
				'data'  => [ status.to_s.upcase , data_state , runtime.to_s , $test_status.operation_count.to_s , $test_status.read_bytes.to_s , $test_status.write_bytes.to_s , @test_info[ :test_mode ].to_s , @test_info[ :power_cycle_count ].to_s , last_power_on.to_s , drive_temp.to_s , $test_status.voltage_5v.to_s + '/' + $test_status.voltage_12v.to_s , drive_amps.to_s , @drive_info[ :assert_present ].to_s.upcase , @test_info[ :log_directory ].to_s , destination_directory.to_s , @drive_info[ :tmm_version ] ]
			} ,

			'where' => {

				'fields' => [ 'Record' ] ,

				'data'  => [ @sql_info[ :record_id ].to_s ] ,

				'join'  => 'AND'
			} ,
		}

		hash = hash.inspect.gsub( /\"/ , '\"' )

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --update --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + hash.to_s + '"'

		_sql_update( cmd: cmd )
	end

	def _precheck_thread()

		Thread.abort_on_exception = true

		precheck_thread = Thread.new {

			instruction_file = $test_info.home_directory.to_s + 'instruction'

			loop do
				begin ; instruction_data = File.open( instruction_file ).readlines ; instruction_data = instruction_data[0].strip ; rescue ; end

				unless instruction_data == nil 

					f_log( [ 'DEBUG' , 'INSTRUCTION FILE DATA ( precheck ) ' , instruction_data.inspect.to_s , $test_status.current_status.to_s ] , -1 )

					if ( instruction_data.to_s.downcase.index( /fail|abort|clear/ ) || $test_status.current_status.to_s.downcase.index( /fail|abort/ ) ) ; Thread.exit ; end

					if instruction_data.to_s.downcase.index( /start|run/ ) ; break ; end
                                end
                        end

			f_log( [ 'INFO' , 'STARTUP' , 'THREAD' , 'STARTED' + "\n" ] )

			get_angel_versions()

			display_angel_versions()

			display_ptl_lib_versions()

			comments = 'NA'

			if File.exist?( $test_info.home_directory + 'Comment.txt' )

				comments_array = read_file( file: $test_info.home_directory + 'Comment.txt' , log: false )

				comments_array.shift(2)

				comments = comments_array.join( ' : ' )

				if comments == '' ; comments = 'NA' ; end
			end

			f_log( [ 'INFO' , 'TEST' , 'COMMENTS' , comments.to_s + "\n" ] )

			# Gets the log directory name from the host_log.txt ( the start time will change between precheck and running state )
			get_log_directory()

			_get_database_field_count()

			_update_database( status: 'Running' )

			_update_web_data_file()

			start_date_time = @test_info[ :log_directory ].split( '_' )[-1]

			start_date_time = start_date_time.gsub( '-' , '_' )

			destination_directory = @test_info[ :slot_id ].to_s + '_' + @test_info[ :script_name ].to_s + '_' + @test_info[ :test_phase ].to_s + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :sn ].to_s + '_' + start_date_time.to_s

			archive_info = { 'database' => @sql_info[ :sql_status_database ].to_s , 'record_id' => @sql_info[ :record_id ].to_s , 'tester_id' => @test_info[ :slot_id ].to_s , 'source' => @test_info[ :log_directory ].to_s , 'destination' => destination_directory.to_s }

			write_yaml_file( data: archive_info , file: $test_info.home_directory + 'archive-data.yaml' , option: 'w' )

			text = @test_info[ :script_name ].to_s

			unless @test_info[ :script_version ] == nil ; text += ' ' + @test_info[ :script_version ] ; end

			f_log( [ 'INFO' , 'START SCRIPT' , text.to_s , @test_info[ :test_phase ].to_s + "\n" ] )

			Thread.exit
		}
	end

	def _get_max_block_tx_size()

		# Reports 1 if meta data is transfered in the LBA buffer
		if @namespace_info[1][ :flbas ][4] == 1 ; meta_data_size = @namespace_info[1][ :ms ].to_i ; else ; meta_data_size = 0 ; end

		if	@drive_info[ :MDTS ] == 0 && $test_status.queue_operation == false

			@test_info[ :max_blocks_per_io ] = $test_status.buffer_size / ( @drive_info[ :block_size ] + meta_data_size )

		elsif	@drive_info[ :MDTS ] == 0 && $test_status.queue_operation == true

			# When queing is enabled buffer size is 4MB
			@test_info[ :max_blocks_per_io ] = 4000000 / ( @drive_info[ :block_size ] + meta_data_size )

		elsif	@drive_info[ :MDTS ] != 0

			max_blocks_per_io_without_queing = @drive_info[ :max_bytes_per_io ] / ( @drive_info[ :block_size ] + meta_data_size )

			# When queing is enabled buffer size is 4MB
			max_blocks_per_io_with_queing = 4000000 / ( @drive_info[ :block_size ] + meta_data_size )

			if $test_status.queue_operation == true && ( max_blocks_per_io_with_queing.to_i < max_blocks_per_io_without_queing.to_i )

				@test_info[ :max_blocks_per_io ] = max_blocks_per_io_with_queing
			else
				@test_info[ :max_blocks_per_io ] = max_blocks_per_io_without_queing
			end
		end

		# There is a ceiling of 0xFFFF for number of max_blocks_per_io value since that is the size of the value in the command
		# This is a 0 based value so the maximum number of sectors per command is 0x10000 ( 65536 )
		if @test_info[ :max_blocks_per_io ] > 65536 ; @test_info[ :max_blocks_per_io ] = 65536 ; end
	end

	def _dump_test_variables( log: false )

		zones = 0

		1.upto( @drive_info[ :number_of_active_namespaces ].to_i ) do |nsid| ; if @namespace_info[ nsid ][ :type ] == 'zoned' ; zones += @namespace_info[ nsid ][ :number_of_zones ] ; end ; end

		if log == true

			if zones < 10000

				f_log( [ 'FUNC' , 'DUMP' , 'TEST VARIABLES' + "\n" ] )
			else
				f_log( [ 'FUNC' , 'DUMP' , 'TEST VARIABLES' , '( ON A ZONED DRIVE THIS PROCESS CAN TAKE SEVERAL MINUTES )' + "\n" ] )
			end
		end

		filename = 'ANGEL_DATA_' + @test_info[ :test_phase ].to_s.upcase + '_' + @test_info[ :script_name ].to_s.upcase + '_' + @drive_info[ :product_family ].to_s.upcase + '_' + @drive_info[ :sn ].to_s + '_' + @drive_info[ :fw ].to_s + '_' + ( Time.now.strftime( "%Y%m%d_%H%M%S" ) ).to_s + '.dump'

		# $angel.shared.p_latest_error_info_ replaces $error_data

		_get_methods( cmd: $angel.shared.p_latest_error_info_ , file: filename.to_s )
		_get_methods( cmd: $test_status , file: filename.to_s )
		_get_methods( cmd: $test_info , file: filename.to_s )
		_get_methods( cmd: $power , file: filename.to_s )
		_get_methods( cmd: $drive_info , file: filename.to_s )

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @test_info.keys ).each do |key| ; log( '@test_info : ' + key.to_s + ' : ' + @test_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @tester_info.keys ).each do |key| ; log( '@tester_info : ' + key.to_s + ' : ' + @tester_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @drive_info.keys ).each do |key| ; log( '@drive_info : ' + key.to_s + ' : ' + @drive_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		begin
			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction

			@namespace_info.each do |nsid , attr| ; attr.each do |key , value| ; log( '@namespace_info : NSID-' + nsid.to_s + ' : ' + key.to_s + ' : ' + value.to_s , 0 , filename.to_s ) ; end ; end
		rescue
		end

		1.upto( @drive_info[ :number_of_active_namespaces ].to_i ) do |nsid|

			begin
				next unless @namespace_info[ nsid ][ :type ] == 'zoned'

				@zone_info[nsid].each do |zid , value|

					log( '@zone_info : NSID-' + nsid.to_s + ' : ' + 'ZID-' + zid.to_s + ' : ' + value.inspect , 0 , filename.to_s )

					# This should stop Angel from going No Response During non-Angel commands
					$angel.check_instruction
				end
			rescue
			end
		end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @sql_info.keys ).each do |key| ; log( '@sql_info : ' + key.to_s + ' : ' + @sql_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @error_info.keys ).each do |key| ; log( '@error_info : ' + key.to_s + ' : ' + @error_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @uart_info.keys ).each do |key| ; log( '@uart_info : ' + key.to_s + ' : ' + @uart_info[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction

		( @test_logs.keys ).each do |key| ; log( '@test_logs : ' + key.to_s + ' : ' + @test_logs[ :"#{key}" ].inspect , 0 , filename.to_s ) ; end

		# This should stop Angel from going No Response During non-Angel commands
		$angel.check_instruction
	end

	def _update_web_data_file()

		unless File.exist?( '/home/everest/angel_web_data' ) ; return ; end

		web_data_file = '/home/everest/angel_web_data/' + @test_info[ :slot_id ].to_s + '.json' ;

		if @tester_info[ :ifc_type ] == 'NA' || @tester_info[ :pci_gen ] == 'NA'

			ifc_type = 'UNKNOWN'
		else
			ifc_type = @tester_info[ :ifc_type ].to_s + ' GEN' + @tester_info[ :pci_gen ].to_s + ' ' + @test_info[ :port_configuration ].to_s
		end 

		average_drive_writes_per_day = ( @drive_info[ :drive_writes_per_day ].inject{ |sum , el| sum + el }.to_f / @drive_info[ :drive_writes_per_day ].size ).round(2)

		if average_drive_writes_per_day == 'NaN' ; average_drive_writes_per_day = '---' ; end

		sub_power_board_fw_version = ( $power.get_card_version ).split( "\s" )[2]

		begin
			File.open( web_data_file , 'w' ) { |fh| fh.write( {
				'block_size'		=>	@drive_info[ :block_size ].to_s ,
				'capacity'		=>	@drive_info[ :capacity ].to_s + ' TB' ,
				'nand_usage'		=>	@drive_info[ :nand_usage ].to_s ,
				'test_mode'		=>	@test_info[ :test_mode ].to_s ,
				'test_phase'		=>	@test_info[ :test_phase ].to_s ,
				'in_precheck'		=>	@test_info[ :in_precheck ] ,
				'dir'			=>	@test_info[ :log_directory ].to_s ,
				'gbb_count'		=>	@drive_info[ :gbb_count ].to_s ,
				'tmm_ver'		=>	@drive_info[ :tmm_version ].to_s ,
				'single_bit_errors'	=>	'SRAM ' + @drive_info[ :sram_single_bit_error_count ].to_i.to_s + ' : DDR ' + @drive_info[ :ddr_single_bit_error_count ].to_i.to_s ,
				'warnings'		=>	@test_info[ :warnings ].keys.join( "\n" ).to_s ,
				'error_category'	=>	@error_info[ :category ].to_s ,
				'os_rc'			=>	@error_info[ :os_rc ].to_s ,
				'nvme_rc'		=>	@error_info[ :nvme_rc ].to_s ,
				'ioctl_rc'		=>	@error_info[ :ioctl_rc ].to_s ,
				'failure_info'		=>	@error_info[ :script_failure_info ].to_s ,
				'family'		=>	@drive_info[ :product_family ].to_s.upcase + '-' + @drive_info[ :fw_feature_set ].to_s.upcase ,
				'ifc_type'		=>	ifc_type.to_s ,
				'pc_count'		=>	@test_info[ :power_cycle_count ].to_s ,
				'ungraceful_pc_count'	=>	@test_info[ :ungraceful_power_cycle_count ].to_s ,
				'power_fw_ver'		=>	sub_power_board_fw_version.to_s ,
				'fw_customer_id'	=>	@drive_info[ :fw_customer_id ].to_s ,
				'customer'		=>	@drive_info[ :customer ].to_s ,
				'dwpd'			=>	average_drive_writes_per_day.to_s ,
			}.to_json ) }

		rescue StandardError => error

			_warning_counter( category: 'update_web_data_file_error' , data: error.to_s )
		end
	end

	def _get_chamber_temp()

		if $test_status.current_status.downcase.include?( 'precheck' ) || @tester_info[ :tester_type ] == 'G10' || @tester_info[ :tester_type ] == 'D16' ; return '---' ; end

		if @test_info[ :chamber_temp_last_update_time ] == nil || ( _current_epoch_time() ).to_i - @test_info[ :chamber_temp_last_update_time ].to_i > @test_info[ :chamber_temp_update_interval ].to_i

			begin
				$angel.get_chamber_log()

			rescue StandardError => error

				_warning_counter( category: '_get_chamber_temp' , data: error.to_s )
			end

			@test_info[ :chamber_temp_last_update_time ] = ( _current_epoch_time() ).to_i
		end

		return $test_status.chamber_current_temperature.to_i
	end

	def _get_core_log_temps()

		if $test_status.current_status.to_s.downcase.include?( 'precheck' ) ; return '---' ; end

		begin 
			core_log = $test_info.home_directory + 'core.log'

			core_log_fh = File.open( core_log ) if File.exist?( core_log )

			# This is similar to using core_log_fh.grep( /Drive Temp/ )[-1].split( /\,/ )[-1].chomp , but 'scrubs' any bad characters or fille encoding
			drive_temp = core_log_fh.select { |line| /Drive Temp/ === line.scrub! }[-1].split( /\,/ )[-1].chomp

			core_log_fh.pos = 0

			core_log_fh.close

		rescue StandardError => error

			d_log( data: 'GET CORE LOG TEMP ERROR : ' + error.to_s )
		end

		if drive_temp == nil ; drive_temp = '---' ; else ; drive_temp = drive_temp.to_i ; end

		return drive_temp
	end

	def _nand_usage_limit_exceeded()

		if	@test_info[ :nand_limit_action ] == 'warn'

			_warning_counter( category: 'nand_usage_limit_exceeded' , data: @drive_info[ :nand_usage ].to_s , suppress: true )

		elsif	@test_info[ :nand_limit_action ] == 'abort'

			force_failure( category: 'nand_usage_limit_exceeded' , data: @drive_info[ :nand_usage ].to_s )

			return( -1 )

		elsif	@test_info[ :nand_limit_action ] == 'read-only'

			@test_info[ :test_mode ] = 'read-only'

			_warning_counter( category: 'nand_usage_limit_exceeded' , data: @drive_info[ :nand_usage ].to_s , suppress: true )

			_set_cell_color( background_color: 'teal' , text_color: 'black' )
		end
	end

	def _sql_insert( cmd: nil )

		unless @test_info[ :enable_database ] == true ; return ; end

		record_id = ssh( cmd: cmd ).chomp

		if record_id.include?( 'MYSQL ERROR' ) || record_id.include?( 'syntax error' ) || record_id.include?( 'EOF' ) || record_id.include?( 'bad interpreter' ) || record_id.include?( 'LoadError' )

			_warning_counter( category: 'sql_insert_error' , data: cmd.to_s + "\n" + record_id.to_s )
		else
			return record_id
		end
	end

	def _sql_update( cmd: nil )

		unless @test_info[ :enable_database ] == true ; return ; end

		rc = ssh( cmd: cmd ).chomp

		unless rc == ''

			_warning_counter( category: 'sql_insert_error' , data: cmd.to_s + "\n" + rc.to_s )
		end
	end

	def _sql_update_stale_database_records()

		unless @test_info[ :enable_database ] == true ; return ; end

		sql_cmd = 'SELECT Record FROM ' + @sql_info[ :sql_status_table ].to_s + ' WHERE Status = \"RUNNING\" AND Tester = \"' + @test_info[ :slot_id ].to_s + '\" ORDER BY Record ASC'

		cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --query --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data=' + '"' + sql_cmd.to_s + '"'

		begin sql_data = ssh( cmd: cmd ).chomp ; rescue ; end

		records = sql_data.split( "\n" )

		return if records.length == 0

		records.each do |record|

			record = ( record.split( '>' )[-1] ).sub( '}' , '' ).to_s

			sql_cmd = 'UPDATE ' + @sql_info[ :sql_status_table ].to_s + ' SET Status = "STOPPED" WHRERE Record = ' + record.to_s

			hash = { 'set' => { 'fields' => [ 'Status' , 'Data State' ] , 'data' => [ 'STOPPED' , 'STALE' ] } , 'where' => { 'fields' => [ 'Record' ] , 'data'  => [ record.to_s ] } , }

			hash = hash.inspect.gsub!( /\"/ , '\"' )

			cmd = 'ruby -I ' + $test_info.home_directory.to_s + ' ' + $test_info.home_directory + 'write-to-sql.rb --ip=' + @sql_info[ :sql_ip ].to_s + ' --username=' + @sql_info[ :sql_username ] + ' --password=' + @sql_info[ :sql_password ] + ' --update --database=' + '"' + @sql_info[ :sql_status_database ].to_s + '" --table="' + @sql_info[ :sql_status_table ].to_s + '" --data="' + hash.to_s + '"'

			_sql_update( cmd: cmd )
		end
	end

	def _get_bus_link_rate()

		@drive_info[ :data_current ] = false

		@error_info[ :pending_failure_info ] = __method__.to_s

		#@drive_info[ :max_link_rate ] = []
		@drive_info[ :max_link_speed ] = []
		@drive_info[ :max_link_width ] = []

		#@drive_info[ :current_link_rate ] = []

		@drive_info[ :bus_id ].each do |bus|

			begin
				counter ||= 0

				cmd = 'sudo setpci -s ' + bus.to_s + ' CAP_EXP+0xC.B'

				return_data = ( %x( #{ cmd } ) ).chomp

				if return_data[0] == nil || return_data[1] == nil ; raise 'NILL RC' ; end

			rescue StandardError => error

				counter += 1

				if counter < 3 ; retry ; else ; _warning_counter( category: 'get_bus_link_rate_error' , data: 'NILL RC : ' + cmd.to_s ) ; end
			end

			max_link_speed = return_data[1].to_s

			max_link_width = return_data[0].to_s

			#max_link_rate = return_data[1].to_s + '.' + return_data[0].to_s

			@drive_info[ :max_link_speed ].push( max_link_speed )

			@drive_info[ :max_link_width ].push( max_link_width )

			#@drive_info[ :max_link_rate ].push( max_link_rate.to_f )

			begin
				counter ||= 0

				cmd = 'sudo setpci -s ' + bus.to_s + ' CAP_EXP+0x12.B'

				return_data = ( %x( #{ cmd } ) ).chomp

				if return_data[0] == nil || return_data[1] == nil ; raise 'NILL RC' ; end

			rescue StandardError => error

				counter += 1

				if counter < 3 ; retry ; else ; _warning_counter( category: 'get_bus_link_rate_error' , data: 'NILL RC : ' + cmd.to_s ) ; end
			end

			current_link_speed = return_data[1].to_s

			current_link_width = return_data[0].to_s

			#current_link_rate = return_data[1].to_s + '.' + return_data[0].to_s

			@drive_info[ :current_link_speed ].push( current_link_speed )
			@drive_info[ :current_link_width ].push( current_link_width )

			#@drive_info[ :current_link_rate ].push( current_link_rate.to_f )
		end

		@error_info[ :pending_failure_info ] = 'NA'

		@drive_info[ :data_current ] = true
	end

	def _time_stamp_to_epoch( timestamp: nil )

		begin epoch_time = Time.parse( timestamp.to_s ).utc.strftime( "%s" ).to_i ; rescue ; _warning_counter( category: 'time_stamp_to_epoch_error' , data: timestamp.inspect ) ; end

		return epoch_time
	end

	def _time_to_epoch( time: nil )

		epoch_time = time.utc.strftime( '%s' ).to_i

		return epoch_time
	end

	def _current_epoch_time()

		epoch_time = Time.now.utc.strftime( "%s" ).to_i

		return epoch_time
	end

	def _warning_counter( category: nil , data: nil , suppress: false )

		if category == nil ; return ; end ; category.gsub!( ' ' , '' ) ; if category == '' ; return ; end

		if data == nil ; data = 'NA' ; end

		if category == '_max_blocks_per_io_exceeded' && @test_info[ :enable_io_size_warnings ] == false ; return ; end

		if	@test_info[ :warnings ][ category.to_s ].nil?

			@test_info[ :warnings ][ category.to_s ] = 1
		else
			@test_info[ :warnings ][ category.to_s ] += 1
		end

		@test_info[ :warning_counter ] += 1

		unless suppress == true #|| @test_info[ :warnings ][ category.to_s ].to_i > 1

			log()

			f_log( [ 'WARN' , category.to_s , data.to_s , ( caller[0] ).split( ':' )[0..1].join( ' : ' ).to_s + "\n" ] )

			_set_cell_color( background_color: 'yellow' , text_color: 'black' )

			_update_web_data_file()
		end
	end

	def _get_host_log_data()

		begin
			host_log_data = File.open( $test_info.home_directory + 'host_log.txt' ).readlines if File.exist?( $test_info.home_directory + 'host_log.txt' )

		rescue StandardError => error

			force_failure( category: 'get_host_log_failure' , data: error.to_s )
		end

		return host_log_data
	end

	def _get_methods( cmd: nil , file: nil )

		cmd.public_methods(false).each { |method|

			# This should stop Angel from going No Response During non-Angel commands
			$angel.check_instruction

			begin
				next unless method.to_s.match( /^[a-z]/ )

				next if method.to_s.match( 'method' )

				next if method.to_s.match( /\=$/ )

				next if method.to_s.include?( '?' )

				if ( cmd.to_s.include?( 'PowerCard' ) )

					if method.to_s.include?( 'get' )

						data = cmd.send( method )
					else
						data = 'NA'
					end
				else
					data = cmd.send( method )
				end

				if file == nil

					f_log( [ cmd.to_s.upcase , method.to_s , data.to_s ] )
				else
					log( cmd.to_s.upcase + ' : ' + method.to_s + ' : ' + data.to_s , 0 , file )
				end

				rescue StandardError => error

					if file == nil

						f_log( [ cmd.to_s.upcase , method.to_s , error.backtrace.to_s ] )
					else
						log( cmd.to_s.upcase + ' : ' + method.to_s + ' : ' + error.backtrace.to_s , 0 , file )
					end
				next
			end
		}
	end

	def _get_trace_info()

		counter = 0 ; trace = String.new

		caller.reverse.each do |data|

                        counter += 1

                        ( path , line , func ) = data.split( ':' )

                        script = path.split( '/' )[-1]

                        func = func.split( "\s" )[-1] ; func.tr!( "'|`|>|<|(|)" , '' )

                        if      counter < ( caller.length - 2 )

                                trace += '( ' + script + ' : ' + line + ' : ' + func + ' ) -> '
			else
                                trace += '( ' + script + ' : ' + line + ' : ' + func + ' )'
                        end
                end

		f_log( [ 'INFO' , trace.to_s ] )
	end

	def _get_parametric_offsets()

		unless @test_info[ :enable_parametrics ] == true ; return ; end

		unless @test_info[ :parametric_offsets ] == nil ; return ; end

		counters_handler_file = '/home/everest/angel_fw_repo/' + @drive_info[ :fw ] + '/countershandler.xml'

		if	File.exists?( counters_handler_file )

			counters_handler_hash = XmlSimple.xml_in( counters_handler_file )
		else
			@test_info[ :enable_parametrics ] = false

			force_failure( category: 'file_not_found' , data: dictionary_file.to_s )
		end

		angel_hash = {}

		offset = 0

		counters_handler_hash[ 'table' ][1][ 'entry' ].each do | data |

			pcode = data[ 'pcode' ].to_s

			name = data[ 'name' ].to_s

			size = data[ 'size' ].to_i

			if pcode.include?( '-' )

				start_pcode = pcode.split( '-' )[0]

				end_pcode = pcode.split( '-' )[1]

				size = ( end_pcode.to_i(16) - start_pcode.to_i(16) + 1 ).to_i * size.to_i
			end

			angel_hash[ pcode ] = {}

			angel_hash[ pcode ][ 'name' ] = name.strip
			angel_hash[ pcode ][ 'start_byte' ] = offset
			angel_hash[ pcode ][ 'end_byte' ] = ( offset.to_i + size.to_i - 1 )

			#puts pcode + ':' + name + ':' + offset.to_s + ':' + ( offset.to_i + size.to_i - 1 ).to_s

			offset += size.to_i
		end

		@test_info[ :parametric_offsets ] = angel_hash

		if @test_info[ :parametric_offsets ].key?( 'FFFF' ) && @test_info[ :parametric_offsets ][ 'FFFF' ][ 'name' ] == 'eyecatcher' ; @test_info[ :check_eyecatcher ] = true ; end
	end

	# Populates @drive_info[ :bus_path ] , @drive_info[ :bus_id ] , @drive_info[ :device_id ]
	def _get_bus_path()

		core_log = $test_info.home_directory + 'core.log'

		core_log_fh = File.open( core_log ) if File.exist?( core_log )

		core_log_data = core_log_fh.select { |line| /PCIe device path/ === line.scrub! }

		core_log_fh.close

		bus_id_portA = core_log_data[0].chomp.split( /\s/ )[-1].split( /\// )[-1]

		bus_path_portA = '/sys/' + ( File.readlink( '/sys/bus/pci/devices/' + bus_id_portA.to_s ).gsub( '../' , '' ) )

		bus_id_portA = bus_path_portA.split( '/' )[-1]

		if @test_info[ :port_configuration ].to_s == '2x2'

			bus_id_portB = core_log_data[1].chomp.split( /\s/ )[-1].split( /\// )[-1]

			bus_path_portB = '/sys/' + ( File.readlink( '/sys/bus/pci/devices/' + bus_id_portB.to_s ).gsub( '../' , '' ) )

			bus_id_portB = bus_path_portB.split( '/' )[-1]

			@drive_info[ :bus_path ] = [ bus_path_portA , bus_path_portB ]

			@drive_info[ :bus_id ] = [ bus_id_portA , bus_id_portB ]
		else
			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s ]

			@drive_info[ :bus_path ] = [ bus_path_portA ]

			@drive_info[ :bus_id ] = [ bus_id_portA ]
		end

		cmd = 'cat ' + @drive_info[ :bus_path ][0].to_s + '/device'

		device_id = ( %x( #{ cmd } ) ).chomp

		@drive_info[ :device_id ] = device_id
	end

	def _verify_device_handle()

		if	$test_info.genesis_hd_config.to_s == 'Edge'

			@test_info[ :port_configuration ] = '1x8'

			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s ]

			@drive_info[ :ctrl_id ] = [ ( @drive_info[ :dev_node ][0][ 0..-3 ] ) ]

		elsif	$test_info.enable_2x2 == true

			@test_info[ :port_configuration ] = '2x2'

			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s , $angel.get_device_name( 'port_b' ).to_s ]

			@drive_info[ :ctrl_id ] = [ ( @drive_info[ :dev_node ][0][ 0..-3 ] ) , ( @drive_info[ :dev_node ][1][ 0..-3 ] ) ]

			$angel.set_sas_port_mode( AngelCore::Port_Toggle )
		else
			@test_info[ :port_configuration ] = '1x4'

			@drive_info[ :dev_node ] = [ $angel.get_device_name( 'port_a' ).to_s ]

			@drive_info[ :ctrl_id ] = [ ( @drive_info[ :dev_node ][0][ 0..-3 ] ) ]
		end

		port = 0

		@drive_info[ :bus_path ].each do |bus_path|

			cmd = 'ls ' + bus_path.to_s + '/nvme/'

			nvme = ( %x( #{ cmd } ) ).chomp

			if nvme == ''

				@drive_info[ :ctrl_id ][ port ] = 'NA'

				@drive_info[ :dev_node ][ port ] = 'NA'

				@drive_info[ :current_link_speed ][ port ] = 'NA'

				@drive_info[ :current_link_width ][ port ] = 'NA'

				@test_info[ :device_handle_error ] = true
			else
				@drive_info[ :ctrl_id ][ port ] = '/dev/' + nvme.to_s

				unless @drive_info[ :ctrl_id ][ port ].to_s == ( '/dev/' + nvme.to_s ).to_s

					@test_info[ :device_handle_error ] = true
				end
			end

			port += 1
		end

		if @test_info[ :device_handle_error ] == true

			if @test_info[ :status ] == 'testing'

				force_failure( category: 'device_handle_error' )
			else
				_warning_counter( category: 'invalid_file_handle' , data: 'INVALID ANGEL FILE-HANDLE ENCOUNTERED' )
			end
		end
	end

	def _decode_fw_info()

		# https://confluence.wdc.com/pages/viewpage.action?spaceKey=SSDFW&title=Firmware+Versioning
		fw_version_decoder = $test_info.home_directory.to_s + 'fw-version-decoder.yaml'

		if @external_data_tables[ :fw_version_decoder ].empty?()

			unless File.file?( fw_version_decoder ) ; force_failure( category: 'file_not_found' , data: fw_version_decoder.to_s ) ; end

			@external_data_tables[ :fw_version_decoder ] = YAML.load( File.read( fw_version_decoder ) )
		end

		@drive_info[ :fw_product_family ] = @external_data_tables[ :fw_version_decoder ][ 'product_family' ][ @drive_info[ :fw ][1].to_s ].to_s

		if @drive_info[ :fw_product_family ] == 'aspen' && @drive_info[ :product_family ].downcase !~ /aspen/ ; @drive_info[ :fw_product_family ] = 'SMOKE-BUILD' ; end

		if	@drive_info[ :fw_product_family ].to_s.downcase == 'borabora'

			if @drive_info[ :fw ][2].to_s == '1' ; @drive_info[ :fw_feature_set ] = 'CONV' ; elsif @drive_info[ :fw ][2].to_s == 'Z' ; @drive_info[ :fw_feature_set ] = 'ZNS' ; end

		# Hack for COFFEEBAY_HP as program is not following FW versioning guidelines
		elsif	@drive_info[ :fw_product_family ].to_s.upcase == 'COFFEEBAY_HP'	

			@drive_info[ :fw_feature_set ] = 'QS3'
		else
			@drive_info[ :fw_feature_set ] = 'QS' + @drive_info[ :fw ][2].to_s
		end
	end

	def _decode_fw_customer_id( id: nil )

		# Information Is From Security Roadmap and Requirements Summary.xlsx ( https://wdc.app.box.com/folder/87561046914?s=2fhn9pndl3knrge1red8ma5ejb1wa958 )
		fw_customer_id_file = $test_info.home_directory.to_s + 'c2-fw-customer-ids.yaml'

		if @external_data_tables[ :customer_id_table ].empty?()

			unless File.file?( fw_customer_id_file ) ; force_failure( category: 'file_not_found' , data: fw_customer_id_file.to_s ) ; end

			@external_data_tables[ :customer_id_table ] = YAML.load( File.read( fw_customer_id_file ) )
		end

		if @external_data_tables[ :customer_id_table ].key?( id.to_s )

			@drive_info[ :customer ] = @external_data_tables[ :customer_id_table ][ id.to_s ][ 'cust' ]

			@drive_info[ :fw_customer_id ] = @external_data_tables[ :customer_id_table ][ id.to_s ][ 'fw-id' ]

			@test_info[ :jira_customer ] = @external_data_tables[ :customer_id_table ][ id.to_s ][ 'jira-cust' ]
		else
			_warning_counter( category: 'external_data_file_error' , data: 'UPDATE : ' + fw_customer_id_file + ' ( id : ' + id.to_s + ' )' )
		end
	end

	# Copies logs to working directory
	def _copy_angel_files()

		begin
			_copy_sys_log()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		begin
			_copy_angel_host_logs()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		begin
			_copy_port_logs()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		begin
			_copy_instruction_logs()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		begin
			_copy_client_manager_log()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		begin
			_copy_power_manager_log()

		rescue StandardError => error

			f_log( [ 'WARN' , error.inspect , error.backtrace.to_s + "\n" ] )
		end

		log()
	end

	def _get_abort_info()

		host_log_data = _get_host_log_data()

		abort_reason = host_log_data.grep( /AbortReason/ )

		if abort_reason.length == 0

			abort_reason = 'UNKOWN'
		else
			abort_reason = abort_reason[0].split( ',' )[-1]

			abort_reason = abort_reason.strip

			if abort_reason == '' ; abort_reason = 'UNKOWN' ; end
		end

		f_log( [ 'INFO' , 'TEST ABORTED' , 'ABORT REASON' , abort_reason.to_s.upcase + "\n" ] )
	end

	# Gets and displays error information
	def _get_error_info()

		# Dump command trace so that trace does not overflow
		$angel.log.dump_command_trace

		# sets option to keep drive powered on after failure
		unless $angel.shared.p_latest_error_info_ == nil ; $angel.shared.p_latest_error_info_.after_action_.power_keep=true ; end

		trace = '' ; counter = 0 ; caller_data = caller

		caller_data.reverse.each do |data|

			counter += 1

			( path , line , func ) = data.split( ':' )

			script = path.split( '/' )[-1]

			func = func.split( "\s" )[-1] ; func.tr!( "'|`|>|<|(|)" , '' )

			if	counter < ( caller_data.length - 4 )

				trace += '( ' + script + ' : ' + line + ' : ' + func + ' ) -> '

			elsif	counter == ( caller_data.length - 4 )

				trace += '( ' + script + ' : ' + line + ' : ' + func + ' )'

				@error_info[ :cmd ] = func

			elsif	counter == ( caller_data.length - 3 )

				trace += "\n" + ':: post :: [ ' + '( ' + script + ' : ' + line + ' : ' + func + ' ) -> '

			elsif   counter == ( caller_data.length - 2 ) || counter == ( caller_data.length - 1 )

				trace += '( ' + script + ' : ' + line + ' : ' + func + ' ) -> '

			elsif	counter == caller_data.length

				trace += '( ' + script + ' : ' + line + ' : ' + func + ' ) ]'
			end
		end

		@error_info[ :trace ] = trace

		error_info = $angel.shared.p_latest_error_info_

		angel_trace = error_info.script_information_.to_s

		f_log( [ 'INFO' , 'ANGEL TRACE' , angel_trace.to_s + "\n" ] )

		f_log( [ 'INFO' , 'RUBY TRACE' + "\n" +  @error_info[ :trace ].to_s + "\n" ] )

		unless error_info == nil

			@error_info[ :os_rc ] = error_info.errno_.to_s

			unless @error_info[ :os_rc ].to_i == 0

				# /usr/bin/perror
				cmd = 'perror ' + error_info.errno_.to_s

				os_rc_desc = ( %x( #{ cmd.to_s } ).chomp ).split( /\:/ )[-1].strip 

				@error_info[ :os_rc ] += ' : ' + os_rc_desc
			end

			@error_info[ :category	] = error_info.category_.to_s
			@error_info[ :ioctl_rc	] = error_info.ioctl_return_code_.to_s
			@error_info[ :nvme_rc	] = error_info.nvme_ioctl_rc_.to_s(16)
			@error_info[ :cmd_time	] = ( error_info.command_elapsed_time_ / 1000000 ).to_s
			@error_info[ :nvme_cmd	] = error_info.get_error_command_string
			@error_info[ :pfcode	] = error_info.pf_code_.to_s

			unless @error_info[ :category ].downcase == 'file_not_found' ; @error_info[ :script_failure_info ] = @error_info[ :script_failure_info ].to_s.upcase ; end

			@error_info[ :script_failure_info ].to_s.gsub!( /"/ , '' )

			@error_info[ :script_failure_info ].to_s.gsub!( /'/ , '' )

			f_log( [ 'INFO' , 'ERROR' , 'CATEGORY'		, @error_info[ :category ].to_s.upcase ] )
			f_log( [ 'INFO' , 'ERROR' , 'FAILURE INFO'	, @error_info[ :script_failure_info ].to_s ] )
			f_log( [ 'INFO' , 'ERROR' , 'CALLER'		, @error_info[ :caller ].to_s ] )
			f_log( [ 'INFO' , 'ERROR' , 'IOCTL RC'		, @error_info[ :ioctl_rc ] ] )
			f_log( [ 'INFO' , 'ERROR' , 'NVME RC'		, @error_info[ :nvme_rc ] ] )
			f_log( [ 'INFO' , 'ERROR' , 'OS RC'		, @error_info[ :os_rc ] ] )
			f_log( [ 'INFO' , 'ERROR' , 'PFCODE'		, @error_info[ :pfcode ] ] )
			f_log( [ 'INFO' , 'ERROR' , 'CMD TIME (SECS)'	, @error_info[ :cmd_time ] ] )

			log()
		end

		if File.file?( $test_info.home_directory.to_s + 'ruby_exception.log' )

			ruby_exception = []

			ruby_exception = File.readlines( $test_info.home_directory.to_s + 'ruby_exception.log' )

			ruby_exception.each do |line| ; f_log( [ 'INFO' , 'RUBY EXCEPTION' , + line.chomp.to_s ] ) ; end

			log()
		end
	end

	# Uses the user supplied hash to over-write the default settings
	def _get_test_options( options: {} , override: false )

		unless $test_status.current_status.to_s.downcase.include?( 'precheck' ) || override == true ; return ; end

		# General Timeout Setting
		unless options.key?( :timeout_general ) ; options[ :timeout_general ] = @test_info[ :timeout_general ] ; end
		@test_info[ :timeout_general ] = options[ :timeout_general ]
		$angel.set_timeout( 'general' , @test_info[ :timeout_general ] )

		# POR Timeout Setting
		unless options.key?( :timeout_por ) ; options[ :timeout_por ] = @test_info[ :timeout_por ] ; end
		@test_info[ :timeout_por ] = options[ :timeout_por ]
		$angel.set_timeout( 'por' , @test_info[ :timeout_por ] )

		# Wait Timeout Setting
		unless options.key?( :timeout_wait_time ) ; options[ :timeout_wait_time ] = @test_info[ :timeout_wait_time ] ;  end
		@test_info[ :timeout_wait_time ] = options[ :timeout_wait_time ]
		$angel.set_timeout( 'wait time' , @test_info[ :timeout_wait_time ] )

		# Firmware Download Timeout Setting
		unless options.key?( :timeout_fwdl ) ; options[ :timeout_fwdl ] = @test_info[ :timeout_fwdl ] ;  end
		@test_info[ :timeout_fwdl ] = options[ :timeout_fwdl ]

		# Sets the frequency of drive temperature checking ( in milliseconds )
		# Also sets the frequency of PLX temperature checking
		unless options.key?( :periodic_temp_checking_interval ) ; options[ :periodic_temp_checking_interval ] = @test_info[ :periodic_temp_checking_interval ] ; end
		@test_info[ :periodic_temp_checking_interval ] = options[ :periodic_temp_checking_interval ]

		if @test_info[ :periodic_temp_checking_interval ] < 1 

			$angel.disable_automatic_PLX_temperature_reading

			$angel.disable_automatic_temperature_reading
		else
			$angel.enable_automatic_temperature_reading( @test_info[ :periodic_temp_checking_interval ] )
			$angel.enable_automatic_PLX_temperature_reading( @test_info[ :periodic_temp_checking_interval ] )
		end

		# Set default value for switch board temp limit
		unless options.key?( :plx_temp_limit ) ; options[ :plx_temp_limit ] = @test_info[ :plx_temp_limit ] ; end
		@test_info[ :plx_temp_limit ] = options[ :plx_temp_limit ]
		$angel.enable_PLX_temperature_limit( @test_info[ :plx_temp_limit ].to_i )

		# Sets the max drive temperature
		unless options.key?( :drive_temp_limit ) ; options[ :drive_temp_limit ] = @test_info[ :drive_temp_limit ] ; end
		@test_info[ :drive_temp_limit ] = options[ :drive_temp_limit ]
		$angel.enable_temperature_limit( @test_info[ :drive_temp_limit ] )

		# Sets Debug Settings for Tools.rb
		unless options.key?( :debug_level ) ; options[ :debug_level ] = @test_info[ :debug_level ] ; end
		@test_info[ :debug_level ] = options[ :debug_level ]

		# Sets Power Control Setting for Functions.rb
		unless options.key?( :enable_power_control ) ; options[ :enable_power_control ] = @test_info[ :enable_power_control ] ; end
		@test_info[ :enable_power_control ] = options[ :enable_power_control ]

		# Sets Link Rate & Width Checking Settings for Functions.rb
		unless options.key?( :enable_link_check ) ; options[ :enable_link_check ] = @test_info[ :enable_link_check ] ; end
		@test_info[ :enable_link_check ] = options[ :enable_link_check ]

		# Set compare on / off globally for Workloads.rb
		unless options.key?( :enable_compare ) ; options[ :enable_compare ] = @test_info[ :enable_compare ] ; end
		@test_info[ :enable_compare ] = options[ :enable_compare ]

		# Enable / disable chamber controls
		unless options.key?( :enable_chamber_control ) ; options[ :enable_chamber_control ] = @test_info[ :enable_chamber_control ] ; end 
		@test_info[ :enable_chamber_control ] = options[ :enable_chamber_control ]

		# Enables / disables chamber / drive syncing
		unless options.key?( :enable_sync_control ) ; options[ :enable_sync_control ] = @test_info[ :enable_sync_control ] ; end
		@test_info[ :enable_sync_control ] = options[ :enable_sync_control ]

		# Sets the NAND usage limit
		unless options.key?( :nand_limit ) ; options[ :nand_limit ] = @test_info[ :nand_limit ] ; end
		@test_info[ :nand_limit ] = options[ :nand_limit ]

		# nand_limit_action sets the action to take when NAND limit is reached ( warn , fail , abort , ignore , read-only )
		unless options.key?( :nand_limit_action ) ; options[ :nand_limit_action ] = @test_info[ :nand_limit_action ] ; end
		@test_info[ :nand_limit_action ] = options[ :nand_limit_action ]

		# Sets the test mode ( read-only , read-write )
		unless options.key?( :test_mode ) ; options[ :test_mode ] = @test_info[ :test_mode ] ; end
		@test_info[ :test_mode ] = options[ :test_mode ]
		if @test_info[ :test_mode ] == 'read-only' ; _set_cell_color( background_color: 'teal' , text_color: 'black' ) ; else ; _set_cell_color( background_color: 'default' , text_color: 'default' ) ; end

		# Sets the action to take if the check_tmm function fails
		unless options.key?( :tmm_check_error_action ) ; options[ :tmm_check_error_action ] = @test_info[ :tmm_check_error_action ] ; end
		@test_info[ :tmm_check_error_action ] = options[ :tmm_check_error_action ]

		# Enables / disables the preconditioning of the drive prior to starting test
		unless options.key?( :precondition ) ; options[ :precondition ] = @test_info[ :precondition ] ; end
		@test_info[ :precondition ] = options[ :precondition ]

		# Enables / disables the running of the baseline workloads prior to starting test
		unless options.key?( :baseline ) ; options[ :baseline ] = @test_info[ :baseline ] ; end
		@test_info[ :baseline ] = options[ :baseline ]

		# Controls if assert is cleared prior to starting the test
		unless options.key?( :clear_assert ) ; options[ :clear_assert ] = @test_info[ :clear_assert ] ; end
		@test_info[ :clear_assert ] = options[ :clear_assert ]

		# Enables / Disables retriving the eye diagram functionality
		unless options.key?( :get_eye_diagram ) ; options[ :get_eye_diagram ] = @test_info[ :get_eye_diagram ] ; end
		@test_info[ :get_eye_diagram ] = options[ :get_eye_diagram ]

		# Enables / Disables getting the parametric data
		unless options.key?( :enable_parametrics ) ; options[ :enable_parametrics ] = @test_info[ :enable_parametrics ] ; end
		@test_info[ :enable_parametrics ] = options[ :enable_parametrics ]

		# Sets the number of retries attempts when opening an NVME device
		unless options.key?( :device_open_retries ) ; options[ :device_open_retries ] = @test_info[ :device_open_retries ] ; end
		@test_info[ :device_open_retries ] = options[ :device_open_retries ]
		$angel.set_nvme_device_open_retry( @test_info[ :device_open_retries ].to_i )

		# Enables / Disables retries for bad file handles
		unless options.key?( :enable_bad_fh_retries ) ; options[ :enable_bad_fh_retries ] = @test_info[ :enable_bad_fh_retries ] ; end
		@test_info[ :enable_bad_fh_retries ] = options[ :enable_bad_fh_retries ]
		if @test_info[ :enable_bad_fh_retries ] == true ; $angel.enable_nvme_bad_handle_retry ; else ; $angel.disable_nvme_bad_handle_retry ; end

		# Enables / Disables the UART interface
		unless options.key?( :enable_uart ) ; options[ :enable_uart ] = @test_info[ :enable_uart ] ; end
		@test_info[ :enable_uart ] = options[ :enable_uart ]

		# Sets the action to take on UART failure ( warn or fail )
		unless options.key?( :uart_error_action ) ; options[ :uart_error_action ] = @test_info[ :uart_error_action ] ; end
		@test_info[ :uart_error_action ] = options[ :uart_error_action ]

		# Enables / Disables all SMART critical warning cheecks
		unless options.key?( :enable_smart_checking ) ; options[ :enable_smart_checking ] = @test_info[ :enable_smart_checking ] ; end
		@test_info[ :enable_smart_checking ] = options[ :enable_smart_checking ]

		# Disables all queuing operations
		unless options.key?( :enable_queuing ) ; options[ :enable_queuing ] = @test_info[ :enable_queuing ] ; end
		@test_info[ :enable_queuing ] = options[ :enable_queuing ]

		# Defines the current PTL test phase , EVT , DVT , etc
		unless options.key?( :test_phase ) ; options[ :test_phase ] = @test_info[ :test_phase ] ; end
		@test_info[ :test_phase ] = options[ :test_phase ] ; @test_info[ :test_phase ].tr!( '_' , '-' )

		# Enables / Disables writting to the drive log
		unless options.key?( :write_drive_log ) ; options[ :write_drive_log ] = @test_info[ :write_drive_log ] ; end
		@test_info[ :write_drive_log ] = options[ :write_drive_log ]

		# Sets the depth of the Angel failure trace
		unless options.key?( :angel_trace_depth ) ; options[ :angel_trace_depth ] = @test_info[ :angel_trace_depth ] ; end
		@test_info[ :angel_trace_depth ] = options[ :angel_trace_depth ]
		$angel.set_script_information_depth( @test_info[ :angel_trace_depth ].to_i )

		# Sets the chamber temperature update interval
		unless options.key?( :chamber_temp_update_interval ) ; options[ :chamber_temp_update_interval ] = @test_info[ :chamber_temp_update_interval ] ; end
		@test_info[ :chamber_temp_update_interval ] = options[ :chamber_temp_update_interval ]

		unless options.key?( :enable_inspector_uploads ) ; options[ :enable_inspector_uploads ] = @test_info[ :enable_inspector_uploads ] ; end
		@test_info[ :enable_inspector_uploads ] = options[ :enable_inspector_uploads ]

		unless options.key?( :enable_io_size_warnings ) ; options[ :enable_io_size_warnings ] = @test_info[ :enable_io_size_warnings ] ; end
		@test_info[ :enable_io_size_warnings ] = options[ :enable_io_size_warnings ]

		unless options.key?( :inspector_mount_dir ) ; options[ :inspector_mount_dir ] = @test_info[ :inspector_mount_dir ] ; end
		@test_info[ :inspector_mount_dir ] = options[ :inspector_mount_dir ]

		# Enables / disables writing to the PTL database
		unless options.key?( :enable_database ) ; options[ :enable_database ] = @test_info[ :enable_database ] ; end
		@test_info[ :enable_database ] = options[ :enable_database ]

		invalid_option_detected = false

		options.keys.each do |option|

			valid_option = false

			if @test_info.member?( option ) == true ; valid_option = true ; end

			if valid_option != true ; f_log( [ 'WARN' , 'INVALID TEST OPTION' , option.to_s + "\n" ] ) ; invalid_option_detected = true ; end
		end

		if invalid_option_detected == true ; return( -1 ) ; end
	end

	def _display_test_options()

		f_log( [ 'INFO' , 'GENERAL' 		, 'TIMEOUT'	, @test_info[ :timeout_general ].to_s + ' MSEC' ] )
		f_log( [ 'INFO' , 'POR'			, 'TIMEOUT'	, @test_info[ :timeout_por ].to_s  + ' MSEC' ] )
		f_log( [ 'INFO' , 'WAIT'		, 'TIMEOUT'	, @test_info[ :timeout_wait_time ].to_s  + ' MSEC' ] )
		f_log( [ 'INFO' , 'FW-DL'		, 'TIMEOUT'	, @test_info[ :timeout_fwdl ].to_s  + ' MSEC' ] )
		f_log( [ 'INFO' , 'SSD TEMP CHECK'	, 'INTERVAL'	, @test_info[ :periodic_temp_checking_interval ].to_s + ' MSEC' ] )
		f_log( [ 'INFO' , 'CHAMBER TEMP CHECK'	, 'INTERVAL'	, @test_info[ :chamber_temp_update_interval ].to_s + ' SEC' ] )
		log()
		f_log( [ 'INFO' , 'FUNC'		, 'BUFFER ID'	, @test_info[ :functions_buffer_id ].to_s ] )
		f_log( [ 'INFO' , 'WRITE'		, 'BUFFER ID'	, @test_info[ :write_buffer_id ].to_s ] )
		f_log( [ 'INFO' , 'READ'		, 'BUFFER ID'	, @test_info[ :read_buffer_id ].to_s ] )
		f_log( [ 'INFO' , 'DEVICE OPEN'		, 'RETRIES'	, @test_info[ :device_open_retries ].to_s ] )
		f_log( [ 'INFO' , 'ANGEL TRACE'		, 'DEPTH'	, @test_info[ :angel_trace_depth ].to_s ] )
		f_log( [ 'INFO' , 'DEBUG'		, 'LEVEL'	, @test_info[ :debug_level ].to_s ] )
		f_log( [ 'INFO' , 'PLX TEMP'		, 'LIMIT'	, @test_info[ :plx_temp_limit ].to_s.upcase ] )
		f_log( [ 'INFO' , 'DRIVE TEMP' 		, 'LIMIT'	, @test_info[ :drive_temp_limit ].round.to_s ] )
		f_log( [ 'INFO' , 'NAND'        	, 'LIMIT'	, @test_info[ :nand_limit ].to_s.upcase ] )
		f_log( [ 'INFO' , 'NAND'        	, 'LIMIT ACTION', @test_info[ :nand_limit_action ].to_s.upcase ] )
		f_log( [ 'INFO' , 'TMM CHECK' 		, 'ERROR ACTION', @test_info[ :tmm_check_error_action ].to_s.upcase ] )
		f_log( [ 'INFO' , 'UART'		, 'ERROR ACTION', @test_info[ :uart_error_action ].to_s.upcase ] )
		log()
		f_log( [ 'INFO' , 'CLEAR ASSERT'	, 'ENABLED'	, @test_info[ :clear_assert ].to_s.upcase ] )
		f_log( [ 'INFO' , 'DATABASE'		, 'ENABLED'	, @test_info[ :enable_database ].to_s.upcase ] )
		f_log( [ 'INFO' , 'PRECONDITION'	, 'ENABLED'	, @test_info[ :precondition ].to_s.upcase ] )
		f_log( [ 'INFO' , 'BASELINE'		, 'ENABLED'	, @test_info[ :baseline ].to_s.upcase ] )
		f_log( [ 'INFO' , 'INSPECTOR UPLOAD'	, 'ENABLED'	, @test_info[ :enable_inspector_uploads ].to_s.upcase ] )
		f_log( [ 'INFO' , 'EYE DIAGRAM'		, 'ENABLED'	, @test_info[ :get_eye_diagram ].to_s.upcase ] )
		f_log( [ 'INFO' , 'PARAMETRICS'		, 'ENABLED'	, @test_info[ :enable_parametrics ].to_s.upcase ] )
		f_log( [ 'INFO' , 'QUEUING'		, 'ENABLED'	, @test_info[ :enable_queuing ].to_s.upcase ] )
		f_log( [ 'INFO' , 'COMPARE'		, 'ENABLED'	, @test_info[ :enable_compare ].to_s.upcase ] )
		f_log( [ 'INFO' , 'WRITE SSD LOG'	, 'ENABLED'	, @test_info[ :write_drive_log ].to_s.upcase ] )
		f_log( [ 'INFO' , 'CHAMBER CONTROL'	, 'ENABLED'	, @test_info[ :enable_chamber_control ].to_s.upcase ] )
		f_log( [ 'INFO' , 'POWER CONTROL'	, 'ENABLED'	, @test_info[ :enable_power_control ].to_s.upcase ] )
		f_log( [ 'INFO' , 'SYNC CONTROL'	, 'ENABLED'	, @test_info[ :enable_sync_control ].to_s.upcase ] )
		f_log( [ 'INFO' , 'LINK CHECK'		, 'ENABLED'	, @test_info[ :enable_link_check ].to_s.upcase ] )
		f_log( [ 'INFO' , 'CHECK SMART'		, 'ENABLED'	, @test_info[ :enable_smart_checking ].to_s.upcase ] )
		f_log( [ 'INFO' , 'IO SIZE WARNING'	, 'ENABLED'	, @test_info[ :enable_io_size_warnings ].to_s.upcase ] )
		f_log( [ 'INFO' , 'BAD FH RETRIES'	, 'ENABLED'	, @test_info[ :enable_bad_fh_retries ].to_s.upcase ] )
		f_log( [ 'INFO' , 'UART'		, 'ENABLED'	, @test_info[ :enable_uart ].to_s.upcase ] )
		log()
	end

	# Creates error_condition_handler.yaml as defined in PostScriptHandler::create_error_condition_file in the working test directory and tells angel to use this file on error
	# @return nil
	def _create_error_condition_file( dir: $test_info.home_directory.to_s )

		user_script = dir + 'angel_error_handler.rb'

		yaml = {}

		yaml[ 'error_condition' ] = [

			{	'priority'	=> 1,
				'category'	=> 'invalid_command_opcode',
				'key'		=> 'nvme',
				'key_value'	=> '.001',
				'pf_code' 	=> [0,1001],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_field_in_command',
				'key'		=> 'nvme',
				'key_value' 	=> '.002',
				'pf_code' 	=> [0,1002],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_id_conflict',
				'key' 		=> 'nvme',
				'key_value' 	=> '.003',
				'pf_code' 	=> [0,1003],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'data_transfer_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.004',
				'pf_code' 	=> [0,1004],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'commands_aborted_due_to_power_loss_notification',
				'key'		=> 'nvme',
				'key_value' 	=> '.005',
				'pf_code' 	=> [0,1005],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'internal_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.006',
				'pf_code' 	=> [0,1006],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_abort_requested',
				'key'		=> 'nvme',
				'key_value' 	=> '.007',
				'pf_code' 	=> [0,1007],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_aborted_due_to_sq_deletion',
				'key'		=> 'nvme',
				'key_value' 	=> '.008',
				'pf_code' 	=> [0,1008],
				'user_script' 	=> user_script,
			} ,
			{	'priority' 	=> 1,
				'category' 	=> 'command_aborted_due_to_failed_fused_command',
				'key'		=> 'nvme',
				'key_value' 	=> '.009',
				'pf_code' 	=> [0,1009],
				'user_script' 	=> user_script,
			} ,
			{	'priority' 	=> 1,
				'category' 	=> 'command_aborted_due_to_missing_fused_command',
				'key'		=> 'nvme',
				'key_value' 	=> '.00A',
				'pf_code' 	=> [0,1010],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_namespace_or_format',
				'key'		=> 'nvme',
				'key_value' 	=> '.00B',
				'pf_code' 	=> [0,1011],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_sequence_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.00C',
				'pf_code' 	=> [0,1012],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_sgl_segment_descriptor',
				'key'		=> 'nvme',
				'key_value' 	=> '.00D',
				'pf_code' 	=> [0,1013],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_number_of_sgl_descriptors',
				'key'		=> 'nvme',
				'key_value' 	=> '.00E',
				'pf_code' 	=> [0,1014],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'data_sgl_length_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.00F',
				'pf_code' 	=> [0,1015],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'metadata_sgl_length_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.010',
				'pf_code' 	=> [0,1016],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'sgl_descriptor_type_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.011',
				'pf_code' 	=> [0,1017],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_use_of_controller_memory_buffer',
				'key'		=> 'nvme',
				'key_value' 	=> '.012',
				'pf_code' 	=> [0,1018],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'prp_offset_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.013',
				'pf_code' 	=> [0,1019],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'atomic_write_unit_exceeded',
				'key'		=> 'nvme',
				'key_value' 	=> '.014',
				'pf_code' 	=> [0,1020],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'operation_denied',
				'key'		=> 'nvme',
				'key_value' 	=> '.015',
				'pf_code' 	=> [0,1021],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'sgl_offset_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.016',
				'pf_code' 	=> [0,1022],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'host_identifier_inconsistent_format',
				'key'		=> 'nvme',
				'key_value' 	=> '.018',
				'pf_code' 	=> [0,1024],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'keep_alive_timeout_expired',
				'key'		=> 'nvme',
				'key_value' 	=> '.019',
				'pf_code' 	=> [0,1025],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'keep_alive_timeout_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.01A',
				'pf_code' 	=> [0,1026],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_aborted_due_to_preempt_and_abort',
				'key'		=> 'nvme',
				'key_value' 	=> '.01B',
				'pf_code' 	=> [0,1027],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'sanitize_failed',
				'key'		=> 'nvme',
				'key_value' 	=> '.01C',
				'pf_code' 	=> [0,1028],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'sanitize_in_progress',
				'key'		=> 'nvme',
				'key_value' 	=> '.01D',
				'pf_code' 	=> [0,1029],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'sgl_data_block_granularity_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.01E',
				'pf_code' 	=> [0,1030],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'command_not_supported_for_queue_in_cmb',
				'key'		=> 'nvme',
				'key_value' 	=> '.01F',
				'pf_code' 	=> [0,1031],
				'user_script' 	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'namespace_is_write_protected',
				'key'		=> 'nvme',
				'key_value'	=> '.020',
				'pf_code'	=> [0,1032],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'command_interrrupted',
				'key'		=> 'nvme',
				'key_value'	=> '.021',
				'pf_code'	=> [0,1033],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'transient_transport_error',
				'key'		=> 'nvme',
				'key_value'	=> '.022',
				'pf_code'	=> [0,1034],
				'user_script'	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'lba_out_of_range',
				'key'		=> 'nvme',
				'key_value' 	=> '.080',
				'pf_code' 	=> [0,1128],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'capacity_exceeded',
				'key'		=> 'nvme',
				'key_value' 	=> '.081',
				'pf_code' 	=> [0,1129],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_not_ready',
				'key'		=> 'nvme',
				'key_value' 	=> '.082',
				'pf_code' 	=> [0,1130],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'reservation_conflict',
				'key'		=> 'nvme',
				'key_value' 	=> '.083',
				'pf_code' 	=> [0,1131],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'format_in_progress',
				'key'		=> 'nvme',
				'key_value' 	=> '.084',
				'pf_code' 	=> [0,1132],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'completion_queue_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.100',
				'pf_code' 	=> [0,1256],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_queue_identifier',
				'key'		=> 'nvme',
				'key_value' 	=> '.101',
				'pf_code' 	=> [0,1257],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_queue_size',
				'key'		=> 'nvme',
				'key_value' 	=> '.102',
				'pf_code' 	=> [0,1258],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'abort_command_limit_exceeded',
				'key'		=> 'nvme',
				'key_value' 	=> '.103',
				'pf_code' 	=> [0,1259],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'asynchronous_event_request_limit_exceeded',
				'key'		=> 'nvme',
				'key_value' 	=> '.105',
				'pf_code' 	=> [0,1261],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_firmware_slot',
				'key'		=> 'nvme',
				'key_value' 	=> '.106',
				'pf_code' 	=> [0,1262],
				'user_script' 	=> user_script,
			} ,
			{	'priority' 	=> 1,
				'category' 	=> 'invalid_firmware_image',
				'key'		=> 'nvme',
				'key_value' 	=> '.107',
				'pf_code' 	=> [0,1263],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_interrupt_vector',
				'key'		=> 'nvme',
				'key_value' 	=> '.108',
				'pf_code' 	=> [0,1264],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_log_page',
				'key'		=> 'nvme',
				'key_value' 	=> '.109',
				'pf_code' 	=> [0,1265],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_format',
				'key'		=> 'nvme',
				'key_value' 	=> '.10A',
				'pf_code' 	=> [0,1266],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'firmware_activation_requires_conventional_reset',
				'key'		=> 'nvme',
				'key_value' 	=> '.10B',
				'pf_code' 	=> [0,1267],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_queue_deletion',
				'key'		=> 'nvme',
				'key_value' 	=> '.10C',
				'pf_code' 	=> [0,1268],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'feature_identifier_not_saveable',
				'key'		=> 'nvme',
				'key_value' 	=> '.10D',
				'pf_code' 	=> [0,1269],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'feature_not_changeable',
				'key'		=> 'nvme',
				'key_value' 	=> '.10E',
				'pf_code' 	=> [0,1270],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'feature_not_namespace_specific',
				'key'		=> 'nvme',
				'key_value' 	=> '.10F',
				'pf_code' 	=> [0,1271],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'firmware_activation_requires_nvm_subsystem_reset',
				'key'		=> 'nvme',
				'key_value' 	=> '.110',
				'pf_code' 	=> [0,1272],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'firmware_activation_requires_reset',
				'key'		=> 'nvme',
				'key_value' 	=> '.111',
				'pf_code' 	=> [0,1273],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'firmware_activation_requires_maximum_time_violation',
				'key'		=> 'nvme',
				'key_value' 	=> '.112',
				'pf_code' 	=> [0,1274],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'firmware_activation_prohibited',
				'key'		=> 'nvme',
				'key_value' 	=> '.113',
				'pf_code' 	=> [0,1275],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'overlapping_range',
				'key'		=> 'nvme',
				'key_value' 	=> '.114',
				'pf_code' 	=> [0,1276],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_insufficient_capacity',
				'key'		=> 'nvme',
				'key_value' 	=> '.115',
				'pf_code' 	=> [0,1277],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_identifier_unavailable',
				'key'		=> 'nvme',
				'key_value' 	=> '.116',
				'pf_code' 	=> [0,1278],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_already_attached',
				'key'		=> 'nvme',
				'key_value' 	=> '.118',
				'pf_code' 	=> [0,1280],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_is_private',
				'key'		=> 'nvme',
				'key_value' 	=> '.119',
				'pf_code' 	=> [0,1281],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'namespace_not_attached',
				'key'		=> 'nvme',
				'key_value' 	=> '.11A',
				'pf_code' 	=> [0,1282],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'thin_provisioning_not_supported',
				'key'		=> 'nvme',
				'key_value' 	=> '.11B',
				'pf_code' 	=> [0,1283],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'controller_list_invalid',
				'key'		=> 'nvme',
				'key_value' 	=> '.11C',
				'pf_code' 	=> [0,1284],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'device_self-test_in_progress',
				'key'		=> 'nvme',
				'key_value' 	=> '.11D',
				'pf_code' 	=> [0,1285],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'boot_partition_write_prohibited',
				'key'		=> 'nvme',
				'key_value' 	=> '.11E',
				'pf_code' 	=> [0,1286],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_controller_identifier',
				'key'		=> 'nvme',
				'key_value' 	=> '.11F',
				'pf_code' 	=> [0,1287],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_secondary_controller_state',
				'key'		=> 'nvme',
				'key_value' 	=> '.120',
				'pf_code' 	=> [0,1288],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_number_of_controller_resources',
				'key'		=> 'nvme',
				'key_value' 	=> '.121',
				'pf_code' 	=> [0,1289],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_resource_identifier',
				'key'		=> 'nvme',
				'key_value' 	=> '.122',
				'pf_code' 	=> [0,1290],
				'user_script' 	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'sanitize_prohibited',
				'key'		=> 'nvme',
				'key_value'	=> '.123',
				'pf_code'	=> [0,1291],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'ana_group_identifier_invalid',
				'key'		=> 'nvme',
				'key_value'	=> '.124',
				'pf_code'	=> [0,1292],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'ana_attach_failed',
				'key'		=> 'nvme',
				'key_value'	=> '.125',
				'pf_code'	=> [0,1293],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'io_command_set_not_supported',
				'key'		=> 'nvme',
				'key_value'	=> '.129',
				'pf_code'	=> [0,1294],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'io_command_set_not_enabled',
				'key'		=> 'nvme',
				'key_value'	=> '.12A',
				'pf_code'	=> [0,1295],
				'user_script'	=> user_script,
				} ,
			{	'priority'	=> 1,
				'category'	=> 'io_command_set_combination_rejected',
				'key'		=> 'nvme',
				'key_value'	=> '.12B',
				'pf_code'	=> [0,1296],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'invalid_io_command_set',
				'key'		=> 'nvme',
				'key_value'	=> '.12C',
				'pf_code'	=> [0,1297],
				'user_script'	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'conflicting_attributes',
				'key'		=> 'nvme',
				'key_value' 	=> '.180',
				'pf_code' 	=> [0,1298],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'invalid_protection_information',
				'key'		=> 'nvme',
				'key_value' 	=> '.181',
				'pf_code' 	=> [0,1299],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'attempted_write_to_read_only_range',
				'key'		=> 'nvme',
				'key_value' 	=> '.182',
				'pf_code' 	=> [0,1300],
				'user_script' 	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'invalid_operation_requested',
				'key'		=> 'nvme',
				'key_value'	=> '.1B6',
				'pf_code'	=> [0,1400],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zrwa_allocation_failed',
				'key'		=> 'nvme',
				'key_value'	=> '.1B7',
				'pf_code'	=> [0,1401],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zone_boundary_error',
				'key'		=> 'nvme',
				'key_value'	=> '.1B8',
				'pf_code'	=> [0,1403],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zone_is_full',
				'key'		=> 'nvme',
				'key_value'	=> '.1B9',
				'pf_code'	=> [0,1404],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zone_is_read_only',
				'key'		=> 'nvme',
				'key_value'	=> '.1BA',
				'pf_code'	=> [0,1405],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zone_is_offline',
				'key'		=> 'nvme',
				'key_value'	=> '.1BB',
				'pf_code'	=> [0,1406],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'zone_invalid_write',
				'key'		=> 'nvme',
				'key_value'	=> '.1BC',
				'pf_code'	=> [0,1407],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'too_many_active_zones',
				'key'		=> 'nvme',
				'key_value'	=> '.1BD',
				'pf_code'	=> [0,1408],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'too_many_open_zones',
				'key'		=> 'nvme',
				'key_value'	=> '.1BE',
				'pf_code'	=> [0,1409],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 1,
				'category'	=> 'invalid_zone_state_transition',
				'key'		=> 'nvme',
				'key_value'	=> '.1BF',
				'pf_code'	=> [0,1410],
				'user_script'	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'write_fault',
				'key'		=> 'nvme',
				'key_value' 	=> '.280',
				'pf_code' 	=> [0,1640],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'unrecovered_read_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.281',
				'pf_code' 	=> [0,1641],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'end-to-end_guard_check_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.282',
				'pf_code' 	=> [0,1642],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'end-to-end_application_tag_check_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.283',
				'pf_code' 	=> [0,1643],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'end-to-end_reference_tag_check_error',
				'key'		=> 'nvme',
				'key_value' 	=> '.284',
				'pf_code' 	=> [0,1644],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'compare_failure',
				'key'		=> 'nvme',
				'key_value' 	=> '.285',
				'pf_code' 	=> [0,1645],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'access_denied',
				'key'		=> 'nvme',
				'key_value' 	=> '.286',
				'pf_code' 	=> [0,1646],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 1,
				'category' 	=> 'deallocated_or_unwritten_logical_block',
				'key'		=> 'nvme',
				'key_value' 	=> '.287',
				'pf_code' 	=> [0,1647],
				'user_script' 	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category'	=> 'reset_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_RESET_ERROR',
				'pf_code'	=> [0,2001],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category'	=> 'crc_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_CRC_ERROR',
				'pf_code'	=> [0,2002],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category'	=> 'por_timeout',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_POR_TIMEOUT',
				'pf_code'	=> [0,2003],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category'	=> 'command_timeout',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_COMMAND_TIMEOUT',
				'pf_code'	=> [0,2004],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'commnd_timeout',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_COMMAND_TIMEOUT_LIMIT_OVER',
				'pf_code'	=> [0,2005],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'function_not_supported',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_FUNCTION_NOT_SUPPORTED',
				'pf_code'	=> [0,2006],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'find_device_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_FIND_DEVICE',
				'pf_code'	=> [0,2007],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'open_file_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_CANNOT_OPEN_FILE',
				'pf_code'	=> [0,2008],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'function_not_defined',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_FUNCTION_NOT_DEFINED',
				'pf_code'	=> [0,2009],
				'user_script'	=> user_script,
			} ,
			{ 	'priority'	=> 2,
				'category'	=> 'compare_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_COMPARE_ERROR',
				'pf_code'	=> [0,2010],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'hard_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_HARD_ERROR',
				'pf_code'	=> [0,2011],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'hba_sync_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_HBA_SYNC_ERROR',
				'pf_code'	=> [0,2012],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'link_error_tx',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_TX_LINK_ERROR',
				'pf_code'	=> [0,2013],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'link_error_rx',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_RX_LINK_ERROR',
				'pf_code'	=> [0,2014],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'out_of_range_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_OUT_OF_RANGE',
				'pf_code'	=> [0,2015],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'memory_allocation_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_MEMORY_ALLOC',
				'pf_code'	=> [0,2016],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'device_open_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_DEVICE_OPEN',
				'pf_code'	=> [0,2017],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'hba_decoder_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_HBA_DECORDER_ERROR',
				'pf_code'	=> [0,2018],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'phy_decoding_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_PHY_DECORDING_ERROR',
				'pf_code'	=> [0,2019],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'slow_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_SLOW_ERROR',
				'pf_code'	=> [0,2020],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category' 	=> 'long_slow_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_LONG_SLOW_ERROR',
				'pf_code'	=> [0,2021],
				'user_script'	=> user_script,
			} ,
			{	'priority'	=> 2,
				'category' 	=> 'over_temp_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_OVER_TEMP_LIMIT',
				'pf_code'	=> [0,2022],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'hba_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_HBA',
				'pf_code'	=> [0,2023],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'rc_error_nvme',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_NVME',
				'pf_code'	=> [0,2024],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 2,
				'category' 	=> 'smart_warning',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR_SMART_WARNING',
				'pf_code'	=> [0,2025],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'firmware_download_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9001],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'angel_command_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9002],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'incorrect_link_speed',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9003],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'system_command_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9004],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'pci_error_detected',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9005],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'switch_board_temp',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9006],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'file_creation_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9007],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'database_command_error',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9008],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'nvme_identify_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9009],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'file_not_found',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9010],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'nvme_custom_command_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9011],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'io_command_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9012],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'serial_connection_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9013],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'get_tdd_failed',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9014],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'incorrect_link_width',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9015],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'get_host_log_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9101],
				'user_script'	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'select_namespace_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9102],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'zone_function_error',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9103],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'get_parametric_data_error',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9104],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'invalid_namespace_selected',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9105],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'tmm_lookup_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9106],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'tmm_check_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9107],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'file_copy_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9108],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'device_handle_error',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9109],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'load_tmm_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9010],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'mount_not_found',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9011],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'external_data_file_error',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9012],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'missing_required_parameter',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9013],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'scp_error',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9014],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'nvme_device_cleanup_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9015],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'finish_spl_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9016],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'dir_not_found',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9017],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'nvme_cli_command_failure',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9018],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'assert_detected',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9019],
				'user_script' 	=> user_script,
			} ,
			{ 	'priority' 	=> 9,
				'category' 	=> 'unexpected_error_during_spl',
				'key'		=> 'rc',
				'key_value' 	=> 'AngelCore::RC_ERROR',
				'pf_code' 	=> [0,9020],
				'user_script' 	=> user_script,
			} ,
			# New Entries should go above this line
			{	'priority' 	=> 9,
				'category' 	=> 'ruby_exception',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9100],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 9,
				'category' 	=> 'user_force_failure',
				'key'		=> 'rc',
				'key_value'	=> 'AngelCore::RC_ERROR',
				'pf_code'	=> [0,9101],
				'user_script'	=> user_script,
			} ,
			{	'priority' 	=> 10,
				'category' 	=> 'nvme_error',
				'key'		=> 'nvme',
				'key_value'	=> '....',
				'pf_code'	=> [0,9999],
				'user_script'	=> user_script,
			} ,
		]

		yaml[ 'stop_count' ] = [
			{ 'category'	=> 'assert_detected',					'stop_count' => 1 },
			{ 'category'	=> 'unexpected_error_during_spl',			'stop_count' => 1 },
			{ 'category'	=> 'nvme_cli_command_failure',				'stop_count' => 1 },
			{ 'category'	=> 'nvme_custom_command_failure',			'stop_count' => 1 },
			{ 'category'	=> 'nvme_device_cleanup_failure',			'stop_count' => 1 },
			{ 'category'	=> 'finish_spl_failure',				'stop_count' => 1 },
			{ 'category'	=> 'external_data_file_error',				'stop_count' => 1 },
			{ 'category'	=> 'device_handle_error',				'stop_count' => 1 },
			{ 'category'	=> 'mount_not_found',					'stop_count' => 1 },
			{ 'category'	=> 'scp_error',						'stop_count' => 1 },
			{ 'category'	=> 'missing_required_parameter',			'stop_count' => 1 },
			{ 'category'	=> 'tmm_lookup_failure',				'stop_count' => 1 },
			{ 'category'	=> 'tmm_check_failure',					'stop_count' => 1 },
			{ 'category'	=> 'load_tmm_failure',					'stop_count' => 1 },
			{ 'category'	=> 'get_parametric_data_error',				'stop_count' => 1 },
			{ 'category'	=> 'zone_function_error',				'stop_count' => 1 },
			{ 'category'	=> 'select_namespace_failure',				'stop_count' => 1 },
			{ 'category'	=> 'serial_connection_failure',				'stop_count' => 1 },
			{ 'category'	=> 'io_command_failure',				'stop_count' => 1 },
			{ 'category'	=> 'file_not_found',					'stop_count' => 1 },
			{ 'category'	=> 'dir_not_found',					'stop_count' => 1 },
			{ 'category'	=> 'get_tdd_failed',					'stop_count' => 1 },
			{ 'category'	=> 'rc_error_nvme',					'stop_count' => 1 },
			{ 'category'	=> 'pci_error_detected',				'stop_count' => 1 },
			{ 'category'	=> 'nvme_identify_failure',				'stop_count' => 1 },
			{ 'category'	=> 'ruby_exception',					'stop_count' => 1 },
			{ 'category'	=> 'get_host_log_failure',				'stop_count' => 1 },
			{ 'category'	=> 'switch_board_temp',					'stop_count' => 1 },
			{ 'category'	=> 'database_command_error',				'stop_count' => 1 },
			{ 'category'	=> 'nand_usage_limit_exceeded',				'stop_count' => 1 },
			{ 'category'	=> 'nvme_error',					'stop_count' => 1 },
			{ 'category'	=> 'file_creation_failure',				'stop_count' => 1 },
			{ 'category'	=> 'file_copy_failure',					'stop_count' => 1 },
			{ 'category'	=> 'angel_command_failure',				'stop_count' => 1 },
			{ 'category'	=> 'incorrect_link_speed',				'stop_count' => 1 },
			{ 'category'	=> 'incorrect_link_width',				'stop_count' => 1 },
			{ 'category'	=> 'system_command_failure',				'stop_count' => 1 },
			{ 'category'	=> 'user_force_failure',				'stop_count' => 1 },
			{ 'category'	=> 'reset_error',					'stop_count' => 1 },
			{ 'category'	=> 'crc_error',						'stop_count' => 1 },
			{ 'category'	=> 'por_timeout',					'stop_count' => 1 },
			{ 'category'	=> 'compare_error',					'stop_count' => 1 },
			{ 'category'	=> 'over_temp_error',					'stop_count' => 1 },
			{ 'category'	=> 'firmware_download_failure',				'stop_count' => 1 },
			{ 'category'	=> 'write_fault',					'stop_count' => 1 },
			{ 'category'	=> 'unrecovered_read_error',				'stop_count' => 1 },
			{ 'category'	=> 'end-to-end_guard_check_error',			'stop_count' => 1 },
			{ 'category'	=> 'end-to-end_application_tag_check_error',		'stop_count' => 1 },
			{ 'category'	=> 'end-to-end_reference_tag_check_error',		'stop_count' => 1 },
			{ 'category'	=> 'compare_failure',					'stop_count' => 1 },
			{ 'category'	=> 'access_denied',					'stop_count' => 1 },
			{ 'category'	=> 'deallocated_or_unwritten_logical_block',		'stop_count' => 1 },
			{ 'category'	=> 'completion_queue_invalid',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_queue_identifier',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_queue_size',				'stop_count' => 1 },
			{ 'category'	=> 'abort_command_limit_exceeded',			'stop_count' => 1 },
			{ 'category'	=> 'asynchronous_event_request_limit_exceeded',		'stop_count' => 1 },
			{ 'category'	=> 'invalid_firmware_slot',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_firmware_image',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_interrupt_vector',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_log_page',					'stop_count' => 1 },
			{ 'category'	=> 'invalid_format',					'stop_count' => 1 },
			{ 'category'	=> 'firmware_activation_requires_conventional_reset',	'stop_count' => 1 },
			{ 'category'	=> 'invalid_queue_deletion',				'stop_count' => 1 },
			{ 'category'	=> 'feature_identifier_not_saveable',			'stop_count' => 1 },
			{ 'category'	=> 'feature_not_changeable',				'stop_count' => 1 },
			{ 'category'	=> 'feature_not_namespace_specific',			'stop_count' => 1 },
			{ 'category'	=> 'firmware_activation_requires_nvm_subsystem_reset',	'stop_count' => 1 },
			{ 'category'	=> 'firmware_activation_requires_reset',		'stop_count' => 1 },
			{ 'category'	=> 'firmware_activation_requires_maximum_time_violation','stop_count' => 1 },
			{ 'category'	=> 'firmware_activation_prohibited',			'stop_count' => 1 },
			{ 'category'	=> 'overlapping_range',					'stop_count' => 1 },
			{ 'category'	=> 'namespace_insufficient_capacity',			'stop_count' => 1 },
			{ 'category'	=> 'namespace_identifier_unavailable',			'stop_count' => 1 },
			{ 'category'	=> 'namespace_already_attached',			'stop_count' => 1 },
			{ 'category'	=> 'namespace_is_private',				'stop_count' => 1 },
			{ 'category'	=> 'namespace_not_attached',				'stop_count' => 1 },
			{ 'category'	=> 'thin_provisioning_not_supported',			'stop_count' => 1 },
			{ 'category'	=> 'controller_list_invalid',				'stop_count' => 1 },
			{ 'category'	=> 'device_self-test_in_progress',			'stop_count' => 1 },
			{ 'category'	=> 'boot_partition_write_prohibited',			'stop_count' => 1 },
			{ 'category'	=> 'invalid_controller_identifier',			'stop_count' => 1 },
			{ 'category'	=> 'invalid_secondary_controller_state',		'stop_count' => 1 },
			{ 'category'	=> 'invalid_number_of_controller_resources',		'stop_count' => 1 },
			{ 'category'	=> 'invalid_resource_identifier',			'stop_count' => 1 },
			{ 'category'	=> 'conflicting_attributes',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_protection_information',			'stop_count' => 1 },
			{ 'category'	=> 'attempted_write_to_read_only_range',		'stop_count' => 1 },
			{ 'category'	=> 'invalid_command_opcode',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_field_in_command',				'stop_count' => 1 },
			{ 'category'	=> 'command_id_conflict',				'stop_count' => 1 },
			{ 'category'	=> 'data_transfer_error',				'stop_count' => 1 },
			{ 'category'	=> 'commands_aborted_due_to_power_loss_notification',	'stop_count' => 1 },
			{ 'category'	=> 'internal_error',					'stop_count' => 1 },
			{ 'category'	=> 'command_abort_requested',				'stop_count' => 1 },
			{ 'category'	=> 'command_aborted_due_to_sq_deletion',		'stop_count' => 1 },
			{ 'category'	=> 'command_aborted_due_to_failed_fused_command',	'stop_count' => 1 },
			{ 'category'	=> 'command_aborted_due_to_missing_fused_command',	'stop_count' => 1 },
			{ 'category'	=> 'invalid_namespace_or_format',			'stop_count' => 1 },
			{ 'category'	=> 'command_sequence_error',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_sgl_segment_descriptor',			'stop_count' => 1 },
			{ 'category'	=> 'invalid_number_of_sgl_descriptors',			'stop_count' => 1 },
			{ 'category'	=> 'data_sgl_length_invalid',				'stop_count' => 1 },
			{ 'category'	=> 'metadata_sgl_length_invalid',			'stop_count' => 1 },
			{ 'category'	=> 'sgl_descriptor_type_invalid',			'stop_count' => 1 },
			{ 'category'	=> 'invalid_use_of_controller_memory_buffer',		'stop_count' => 1 },
			{ 'category'	=> 'prp_offset_invalid',				'stop_count' => 1 },
			{ 'category'	=> 'atomic_write_unit_exceeded',			'stop_count' => 1 },
			{ 'category'	=> 'operation_denied',					'stop_count' => 1 },
			{ 'category'	=> 'sgl_offset_invalid',				'stop_count' => 1 },
			{ 'category'	=> 'host_identifier_inconsistent_format',		'stop_count' => 1 },
			{ 'category'	=> 'keep_alive_timeout_expired',			'stop_count' => 1 },
			{ 'category'	=> 'keep_alive_timeout_invalid',			'stop_count' => 1 },
			{ 'category'	=> 'command_aborted_due_to_preempt_and_abort',		'stop_count' => 1 },
			{ 'category'	=> 'sanitize_failed',					'stop_count' => 1 },
			{ 'category'	=> 'sanitize_in_progress',				'stop_count' => 1 },
			{ 'category'	=> 'sgl_data_block_granularity_invalid',		'stop_count' => 1 },
			{ 'category'	=> 'command_not_supported_for_queue_in_cmb',		'stop_count' => 1 },
			{ 'category'	=> 'lba_out_of_range',					'stop_count' => 1 },
			{ 'category'	=> 'capacity_exceeded',					'stop_count' => 1 },
			{ 'category'	=> 'namespace_not_ready',				'stop_count' => 1 },
			{ 'category'	=> 'reservation_conflict',				'stop_count' => 1 },
			{ 'category'	=> 'format_in_progress',				'stop_count' => 1 },
			{ 'category'	=> 'function_not_supported',				'stop_count' => 1 },
			{ 'category'	=> 'find_device_error',					'stop_count' => 1 },
			{ 'category'	=> 'open_file_error',					'stop_count' => 1 },
			{ 'category'	=> 'function_not_defined',				'stop_count' => 1 },
			{ 'category'	=> 'hard_error',					'stop_count' => 1 },
			{ 'category'	=> 'hba_sync_error',					'stop_count' => 1 },
			{ 'category'	=> 'link_error_tx',					'stop_count' => 1 },
			{ 'category'	=> 'link_error_rx',					'stop_count' => 1 },
			{ 'category'	=> 'out_of_range_error',				'stop_count' => 1 },
			{ 'category'	=> 'memory_allocation_error',				'stop_count' => 1 },
			{ 'category'	=> 'device_open_error',					'stop_count' => 1 },
			{ 'category'	=> 'hba_decoder_error',					'stop_count' => 1 },
			{ 'category'	=> 'phy_decoding_error',				'stop_count' => 1 },
			{ 'category'	=> 'slow_error',					'stop_count' => 1 },
			{ 'category'	=> 'long_slow_error',					'stop_count' => 1 },
			{ 'category'	=> 'smart_warning',					'stop_count' => 1 },
			{ 'category'	=> 'hba_error',						'stop_count' => 1 },
			{ 'category'	=> 'command_timeout',					'stop_count' => 1 },
			{ 'category'	=> 'namespace_is_write_protected',			'stop_count' => 1 },
			{ 'category'	=> 'command_interrrupted',				'stop_count' => 1 },
			{ 'category'	=> 'transient_transport_error',				'stop_count' => 1 },
			{ 'category'	=> 'sanitize_prohibited',				'stop_count' => 1 },
			{ 'category'	=> 'ana_group_identifier_invalid',			'stop_count' => 1 },
			{ 'category'	=> 'ana_attach_failed',					'stop_count' => 1 },
			{ 'category'	=> 'io_command_set_not_supported',			'stop_count' => 1 },
			{ 'category'	=> 'io_command_set_not_enabled',			'stop_count' => 1 },
			{ 'category'	=> 'io_command_set_combination_rejected',		'stop_count' => 1 },
			{ 'category'	=> 'invalid_io_command_set',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_operation_requested',			'stop_count' => 1 },
			{ 'category'	=> 'zrwa_allocation_failed',				'stop_count' => 1 },
			{ 'category'	=> 'zone_boundary_error',				'stop_count' => 1 },
			{ 'category'	=> 'zone_is_full',					'stop_count' => 1 },
			{ 'category'	=> 'zone_is_read_only',					'stop_count' => 1 },
			{ 'category'	=> 'zone_is_offline',					'stop_count' => 1 },
			{ 'category'	=> 'zone_invalid_write',				'stop_count' => 1 },
			{ 'category'	=> 'too_many_active_zones',				'stop_count' => 1 },
			{ 'category'	=> 'too_many_open_zones',				'stop_count' => 1 },
			{ 'category'	=> 'invalid_zone_state_transition',			'stop_count' => 1 },
		]

		write_yaml_file( data: yaml , file: dir + 'error_condition_handler.yaml' , option: 'w' )

		if File.size( dir + 'error_condition_handler.yaml' ) == 0 ; force_failure( category: 'file_creation_failure' , data: '0 size file' ) ; end

		$angel.load_error_condition( dir.to_s + 'error_condition_handler.yaml' , AngelCore::DEFAULT_TEST_MODE )
	end
end
