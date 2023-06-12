
require 'Functions'

class Workloads < Functions

	VERSION = 8.41

	# TO LOG DEBUG OUTPUT FOR THIS LIBRARY SET DEBUG_LEVEL TO -2
	def initialize()

		super()

		# clear write & read buffers
		# Returns nil
		$angel.buffer.clear( @test_info[ :write_buffer_id ] )

		# Returns nil
		$angel.buffer.clear( @test_info[ :read_buffer_id ] )

		# Caused precheck to hang in Angel Package 20210129
		#data_pattern( @test_info[ :data_pattern ] )

		@zns_data_patterns = [ '0x0000FFFF' , AngelCore::DataPattern_Random , AngelCore::DataPattern_Increment , AngelCore::DataPattern_Decrement ]

		$angel.log.write_file( $test_info.home_directory.to_s + 'script-trace.log' , 'WORKLOADS ' + "\n\n" , 'a' )
	end

	def get_random_jedec_group()

		lba_region_05_start = 0

		lba_region_05_end   = ( $drive_info.max_lba * 0.05 ).round

		lba_region_15_start = ( $drive_info.max_lba * 0.05 ).round + 1

		lba_region_15_end   = ( $drive_info.max_lba * 0.20 ).round

		lba_region_80_start = ( $drive_info.max_lba * 0.20 ).round + 1

		lba_region_80_end   = $drive_info.max_lba

		group = []

		# group 0 is 05% , 15% , 80%
		group[0] = [ [ lba_region_05_start , lba_region_05_end ] , [ lba_region_15_start , lba_region_15_end ] , [ lba_region_80_start , lba_region_80_end ] ]
		# group 1 is 15% , 80% , 05%
		group[1] = [ [ lba_region_15_start , lba_region_15_end ] , [ lba_region_80_start , lba_region_80_end ] , [ lba_region_05_start , lba_region_05_end ] ]
		# group 2 is 80% , 05% , 15%
		group[2] = [ [ lba_region_80_start , lba_region_80_end ] , [ lba_region_05_start , lba_region_05_end ] , [ lba_region_15_start , lba_region_15_end ] ]

		# Get random group
		group_id = [ 0 , 1 , 2 ].sample

		return group[ group_id ]
	end

	# Performs a block write with the user defined lba & blocks_per_io
	def block_w( lba: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] )

		if @test_info[ :test_mode ] == 'read-only' ; return ; end

		blocks_per_io = _check_blocks_per_io( blocks_per_io: blocks_per_io )

		f_log( [ 'DEBUG' , 'BLOCK-W' , lba.to_s , blocks_per_io.to_s ] , -2 )

		rc = $angel.device_write( lba , blocks_per_io , @test_info[ :write_buffer_id ] )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Performs a block write with the user defined lba & blocks_per_io
	# Perfoms a data compare if compare option is set to true
	def block_r( lba: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false )

		if @test_info[ :enable_compare ] == false ; compare = false ; end

		if @test_info[ :test_mode ] == 'read-only' ; compare = false ; end

		blocks_per_io = _check_blocks_per_io( blocks_per_io: blocks_per_io )

		if compare == true

			write_buffer_id = @test_info[ :write_buffer_id ]

			f_log( [ 'DEBUG' , 'BLOCK-R-C' , lba.to_s , blocks_per_io.to_s ] , -2 )
		else
			write_buffer_id = -1

			f_log( [ 'DEBUG' , 'BLOCK-R' , lba.to_s , blocks_per_io.to_s ] , -2 )
		end

		rc = $angel.device_read( lba , blocks_per_io.to_i , @test_info[ :read_buffer_id ] , write_buffer_id , AngelCore::CompareMode_Full )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Perfoms a sequential write with the user defined start_lba , end_lba & blocks_per_io
	def seq_w( start_lba: 0 , end_lba: @drive_info[ :max_lba ] , blocks_per_io: @test_info[ :max_blocks_per_io ] )

		if @test_info[ :test_mode ] == 'read-only' ; return ; end

		blocks_per_io = _check_blocks_per_io( blocks_per_io: blocks_per_io )

		f_log( [ 'DEBUG' , 'SEQ-W' , start_lba.to_s , end_lba.to_s , blocks_per_io.to_s ] , -2 )

		rc = $angel.sequential_write( start_lba.to_i , end_lba.to_i , blocks_per_io.to_i , @test_info[ :write_buffer_id ] )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Perfoms a sequential read with the user defined start_lba , end_lba & blocks_per_io
	# Perfoms a data compare if compare option is set to true
	def seq_r( start_lba: 0 , end_lba: @drive_info[ :max_lba ] , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false )

		if @test_info[ :enable_compare ] == false ; compare = false ; end

		if @test_info[ :test_mode ] == 'read-only' ; compare = false ; end

		blocks_per_io = _check_blocks_per_io( blocks_per_io: blocks_per_io )

		if compare == true

			write_buffer_id = @test_info[ :write_buffer_id ]

			f_log( [ 'DEBUG' , 'SEQ-R-C' , start_lba.to_s , end_lba.to_s , blocks_per_io.to_s ] , -2 )
		else
			write_buffer_id = -1

			f_log( [ 'DEBUG' , 'SEQ-R' , start_lba.to_s , end_lba.to_s , blocks_per_io.to_s ] , -2 )
		end

		rc = $angel.sequential_read( start_lba.to_i , end_lba.to_i , blocks_per_io.to_i , @test_info[ :read_buffer_id ] , write_buffer_id , AngelCore::CompareMode_Full )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Calls $angel.jedec_219_write
	def jedec_write( min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 1000 )

		if @test_info[ :test_mode ] == 'read-only' ; return ; end

		f_log( [ 'DEBUG' , 'JEDEC-WRITE' , min_lba.to_s , max_lba.to_s , loop_count.to_s ] , -2 )

		rc = $angel.jedec_219_write( min_lba , max_lba , loop_count , @test_info[ :write_buffer_id ] )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Calls $angel.jedec_219_read
	def jedec_read( min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 1000 , compare: false )

		if compare == true

			write_buffer_id = @test_info[ :write_buffer_id ]

			f_log( [ 'DEBUG' , 'JEDEC-READ-C' , min_lba.to_s , max_lba.to_s , loop_count.to_s ] , -2 )
		else
			write_buffer_id = -1

			f_log( [ 'DEBUG' , 'JEDEC-READ' , min_lba.to_s , max_lba.to_s , loop_count.to_s ] , -2 )
		end

		rc = $angel.jedec_219_read( min_lba , max_lba , loop_count , @test_info[ :read_buffer_id ] , write_buffer_id , AngelCore::CompareMode_Full )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	# Calls $angel.jedec_219_mixed
	def jedec_w_r( write_percentage: 50 , min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 10000 , compare: false )

		if @test_info[ :test_mode ] == 'read-only' ; write_percentage = 0 ; compare = -1 ; end

		compare_pattern = AngelCore::CompareMode_Full

		if compare == true

			f_log( [ 'DEBUG' , 'JEDEC-MIXED-C' , min_lba.to_s , max_lba.to_s , write_percentage.to_s , loop_count.to_s ] , -2 )
		else
			compare_pattern = -1

			f_log( [ 'DEBUG' , 'JEDEC-MIXED' , min_lba.to_s , max_lba.to_s , write_percentage.to_s , loop_count.to_s ] , -2 )
		end

		rc = $angel.jedec_219_mixed( write_percentage , min_lba , max_lba , loop_count , @test_info[ :read_buffer_id ] , @test_info[ :write_buffer_id ] , compare_pattern )

		unless rc == 0 ; force_failure( category: 'io_command_failure' , data: rc.to_s ) ; end
	end

	def timed_jedec_w( runtime: nil , min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 10000 )

		start_time = Time.now

		loop do
			jedec_write( min_lba: min_lba , max_lba: max_lba , loop_count: loop_count )

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end
	end

	def timed_jedec_r( runtime: nil , min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 10000 , compare: false )

		start_time = Time.now

		loop do
			jedec_read( min_lba: min_lba , max_lba: max_lba , loop_count: loop_count , compare: compare )

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end
	end

	def timed_jedec_w_r( write_percentage: 50 , min_lba: 0 , max_lba: @drive_info[ :max_lba ] , loop_count: 10000 , runtime: nil , compare: false )

		start_time = Time.now

		loop do
			jedec_w_r( write_percentage: write_percentage , min_lba: min_lba , max_lba: max_lba , loop_count: loop_count , compare: compare )

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end
	end

	def timed_jedec_219_workload( runtime: nil , write_percentage: 50 , loop_count: 100000 , compare: false , queue_depth: 32 )

		start_time = Time.now

		enable_queuing( queue_depth: queue_depth , log: false )

		# 50% access in 1st LBA range
		loop_count_lba_region_0 = ( loop_count * ( 50.0 / 100 ).to_f ).to_i
		# 30% access in 1st LBA range
		loop_count_lba_region_1 = ( loop_count * ( 30.0 / 100 ).to_f ).to_i
		# 20% access in 1st LBA range
		loop_count_lba_region_2 = ( loop_count * ( 20.0 / 100 ).to_f ).to_i

		region = get_random_jedec_group()

		loop do
			jedec_w_r( write_percentage: write_percentage , min_lba: region[0][0] , max_lba: region[0][1] , loop_count: loop_count_lba_region_0 , compare: compare )

			break if Time.now >= ( start_time + runtime )

			jedec_w_r( write_percentage: write_percentage , min_lba: region[1][0] , max_lba: region[1][1] , loop_count: loop_count_lba_region_1 , compare: compare )

			break if Time.now >= ( start_time + runtime )

			jedec_w_r( write_percentage: write_percentage , min_lba: region[2][0] , max_lba: region[2][1] , loop_count: loop_count_lba_region_2 , compare: compare )

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end

		disable_queuing( log: false )
	end

	# Performs a block write on the user specified zone starting at the current write_pointer location
	# If write_pointer + blocks_per_io > zone_max_lba : blocks_per_io will be automatically reduced
	# Calls Functions::refresh_zone_info
	# Calls Workloads::block_w
	# @return nil
	def zoned_block_w( zone_id: nil , blocks_per_io: @test_info[ :max_blocks_per_io ] , nsid: @drive_info[ :zoned_namespace ] )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		refresh_zone_info( nsid: nsid )

		lba = @zone_info[ nsid ][ zone_id ][ :write_pointer ]

		if lba + blocks_per_io > @zone_info[ nsid ][ zone_id ][ :zone_end_lba ] ; blocks_per_io = @zone_info[ nsid ][ zone_id ][ :zone_end_lba ] - lba ; end

		f_log( [ 'DEBUG' , __method__.to_s.upcase.gsub!( '_' , '-' ) , zone_id.to_s , lba.to_s , blocks_per_io.to_s ] , -2 )

		block_w( lba: lba , blocks_per_io: blocks_per_io )
	end

	# Performs a block read on the user specified zone
	# User can supply lba or offset : lba has precedence
	# offset sets lba as @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + offset
	# If lba + blocks_per_io > zone_max_lba : blocks_per_io will be automatically reduced
	# Calls Workloads::block_r
	# @return nil
	def zoned_block_r( zone_id: nil , lba: nil , offset: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false , nsid: @drive_info[ :zoned_namespace ] )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		refresh_zone_info( nsid: nsid )

		if lba == nil ; lba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + offset ; end

		if lba > @zone_info[ nsid ][ zone_id ][ :zone_end_lba ]

			force_failure( category: 'zone_boundary_error' , data: lba.to_s + ' > ' + @zone_info[ nsid ][ zone_id ][ :zone_end_lba ].to_s )
		end

		if lba < @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]

			force_failure( category: 'zone_boundary_error' , data: lba.to_s + ' < ' + @zone_info[ nsid ][ zone_id ][ :zone_start_lba ].to_s )
		end

		if lba + blocks_per_io > @zone_info[ nsid ][ zone_id ][ :zone_end_lba ] ; blocks_per_io = @zone_info[ nsid ][ zone_id ][ :zone_end_lba ] - lba ; end

		f_log( [ 'DEBUG' , __method__.to_s.upcase.gsub!( '_' , '-' ) , zone_id.to_s , lba.to_s , blocks_per_io.to_s , compare.to_s ] , -2 )

		block_r( lba: lba , blocks_per_io: blocks_per_io , compare: compare )
	end

	# Performs a sequential write on the user specified zone from write_pointer to user defined end_lba or @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] if end_lba is not supplied by user
	# if end_lba > @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] : end_lba will be set to @zone_info[ nsid ][ zone_id ][ :zone_max_lba ]
	# Calls Functions::refresh_zone_info
	# Calls Workloads::seq_w
	# @return nil
	def zoned_seq_w( zone_id: nil , end_lba: nil , blocks_per_io: @test_info[ :max_blocks_per_io ] , nsid: @drive_info[ :zoned_namespace ] )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		refresh_zone_info( nsid: nsid )

		start_lba = @zone_info[ nsid ][ zone_id ][ :write_pointer ]

		if end_lba == nil || end_lba > @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] ; end_lba = @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] ; end

		f_log( [ 'DEBUG' , __method__.to_s.upcase.gsub!( '_' , '-' ) , zone_id.to_s , start_lba.to_s , end_lba.to_s , blocks_per_io.to_s ] , -2 )

		seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )
	end

	# Performs a sequential write on the user specified zone from to user defined start_lba & end_lba
	# If start_lba < @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] : start_lba will be set to @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
	# If end_lba > @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] : start_lba will be set to @zone_info[ nsid ][ zone_id ][ :zone_max_lba ]
	# Performs a sequential read on the user specified zone & LBAs
	# start_lba defaults is @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]
	# end_lba defaults to @zone_info[ nsid ][ zone_id ][ :zone_end_lba ]
	# Calls Workloads::seq_r
	# @return nil
	def zoned_seq_r( zone_id: nil , start_lba: nil , end_lba: nil , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false , nsid: @drive_info[ :zoned_namespace ] )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		if ( @namespace_info[ nsid ] == nil || @namespace_info[ nsid ][ :type ] != 'zoned' ) ; force_failure( category: 'invalid_namespace_selected' ) ; end

		refresh_zone_info( nsid: nsid )

		if start_lba == nil || start_lba < @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] ; start_lba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] ; end

		if end_lba == nil || end_lba > @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] ; end_lba = @zone_info[ nsid ][ zone_id ][ :zone_max_lba ] ; end

		f_log( [ 'DEBUG' , __method__.to_s.upcase.gsub!( '_' , '-' ) , zone_id.to_s , start_lba.to_s , end_lba.to_s , blocks_per_io.to_s , compare.to_s ] , -2 )

		seq_r( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io , compare: compare )
	end

	# Calls Workloads::seq_w
	# Call Workloads::seq_r
	# Perfoms a data compare if compare option is set to true
	# @return nil
	def seq_w_r( start_lba: 0 , end_lba: @drive_info[ :max_lba ] , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false )

		if @test_info[ :enable_compare ] == false ; compare = false ; end

		if @test_info[ :test_mode ] == 'read-only' ; compare = false ; end

		unless @test_info[ :test_mode ] == 'read-only' ; seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io ) ; end

		seq_r( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io , compare: compare )
	end

	# Gets random block size between 1 - 128 , gets random LBA , performs block_w , performs block_r_c
	# @return nil
	def timed_random_block_w_r( runtime: 15 , compare: true )

		# Select random number of blocks between 1 - 128
		number_of_blocks = Random.rand( 1 .. 128 )

		if @test_info[ :test_mode ] == 'read-only' ; compare = false ; end

		start_time = Time.now

		loop do
			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			random_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			unless @test_info[ :test_mode ] == 'read-only' ; block_w( lba: random_lba , blocks_per_io: number_of_blocks ) ; end

			block_r( lba: random_lba , blocks_per_io: number_of_blocks , compare: compare )

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end
	end

	def spl_workload( pwr_5v: 3.3 , pwr_12v: 12.0 , queue_depth: 64 , spl_on: 60 , spl_off: 30 , compare: false , command_history_depth: 500 , ttp_delay: nil )

		unless @test_info[ :enable_power_control ] == true ; return ; end

		f_log( [ 'INFO' , 'SPL START' + "\n" ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		$angel.start_spl( spl_on.to_i , spl_off.to_i , command_history_depth )

		counter = 0

		# Per Josh the transfer sizes should be split between 64K & 128K
		byte_transfer_sizes = [ 64 , 128 ]

		blocks_per_io = ( ( ( byte_transfer_sizes.sample ).to_i * 1024 ).to_i / @drive_info[ :block_size ] ).to_i

		if compare == true

			write_buffer = @test_info[ :write_buffer_id ]

			text = 'RANDOM-W-R-C'

			debug_text = 'BLOCK-R-C'
		else
			write_buffer = -1

			text = 'RANDOM-W-R'

			debug_text = 'BLOCK-R'
		end

		spl_on_start_time = Time.now ; rc = nil

		loop do
			$angel.check_instruction

			if counter == 0 ; f_log( [ 'FUNC' , 'RANDOM' , text , spl_on.to_s , blocks_per_io.to_s + "\n" ] ) ; end

			random_lba = Random.rand( 0 .. ( $drive_info.max_lba - blocks_per_io ) )

			f_log( [ 'DEBUG' , 'RANDOM' , 'BLOCK-W' , random_lba.to_s , blocks_per_io.to_s ] , -2 )

			rc = $angel.device_write( random_lba , blocks_per_io , @test_info[ :write_buffer_id ] )

			break unless rc == 0

			sleep 1

			f_log( [ 'DEBUG' , 'RANDOM' , debug_text , random_lba.to_s , blocks_per_io.to_s ] , -2 )

			rc = $angel.device_read( random_lba , blocks_per_io , @test_info[ :read_buffer_id ] , write_buffer , AngelCore::CompareMode_Full )

			break unless rc == 0

			counter += 1
		end

		$angel.check_instruction

		spl_on_end_time = Time.now ; spl_on_elapsed_time = spl_on_end_time - spl_on_start_time

		error_info = _get_error_details()

		unless error_info[ :category ] == 'command_abort_requested'

			force_failure( category: 'unexpected_error_during_spl' , data: error_info[ :category ].to_s + ' : ' + error_info[ :ioctl_rc ].to_s )
		end

		if spl_on_elapsed_time >= spl_on

			if @test_info[ :port_configuration ] == '1x4' || @test_info[ :port_configuration ] == '1x8'

				ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3]

				f_log( [ 'FUNC' , 'POWER OFF' , 'UNGRACEFUL' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s , 'SSD LOG ID ' + @test_info[ :drive_log_counter ].to_s + "\n" ] )

			elsif @test_info[ :port_configuration ] == '2x2'

				ctrl_id_a = ( $angel.get_device_name( 'port_a' ).to_s )[ 0..-3 ]
				ctrl_id_b = ( $angel.get_device_name( 'port_b' ).to_s )[ 0..-3 ]

				f_log( [ 'FUNC' , 'POWER OFF' , 'UNGRACEFUL' , ctrl_id_a.to_s + ' : ' + @drive_info[ :bus_id ][0].to_s + ' & ' + ctrl_id_b.to_s + ' : ' + @drive_info[ :bus_id ][1].to_s + "\n" ] )
			end
		else
			force_failure( category: 'unexpected_error_during_spl' , data: 'SPL_ON DURATION NOT REACHED : ' + spl_on.to_s + ' : ' + spl_on_elapsed_time.to_s )
		end

		spl_off_start_time = Time.now

		disable_queuing( log: false )

		rc = $angel.nvme_device_cleanup

		unless rc == 0 ; force_failure( category: 'nvme_device_cleanup_failure' , data: rc.inspect ) ; end

		loop do
			$angel.check_instruction

			if ( Time.now - spl_off_start_time ) >= spl_off

				power_on( pwr_5v: pwr_5v , pwr_12v: pwr_12v , ungraceful: true )

				break
			end

			sleep 1
		end

		sleep ttp_delay.to_i

		if compare == true ; f_log( [ 'FUNC' , 'BLOCK-R-C' , ( command_history_depth.to_i * blocks_per_io.to_i ).to_s + "\n" ] ) ; end

		rc = $angel.finish_spl( compare )

		unless rc == 0 ; force_failure( category: 'finish_spl_failure' , data: rc.inspect ) ; end

		f_log( [ 'INFO' , 'SPL END' , 'UNSAFE SHUTDOWNS' , @drive_info[ :unsafe_shutdowns ].to_s + "\n" ] )
	end

	# Performs full sequential write / read with optional compare
	# @return nil
	def precondition( compare: true , queue_depth: 32 , sync: true , set_temp: nil )

		unless @test_info[ :precondition ] == true ; return ; end

		unless set_temp == nil ; set_chamber_temp( temp: set_temp , time_limit: 0 , sync: sync ) ; end

		if @test_info[ :test_mode ] == 'read-only' ; compare = false ; end

		io_tracker( tag: 'PRECONDITION' )

		$angel.buffer.set_repeated_value( 1 , 0x0F0F0F0F , 4 )

		enable_queuing( queue_depth: queue_depth , log: false )

		1.upto( @drive_info[ :number_of_active_namespaces ].to_i ) do |nsid|

			select_namespace( nsid: nsid , log: true )

			if	@namespace_info[ nsid ][ :type ] == 'conv'

				start_lba = 0

				end_lba = @namespace_info[ nsid ][ :ncap ]

				f_log( [ 'FUNC' , 'SEQ-W' , 'NSID-' + nsid.to_s , '0 - ' + end_lba.to_s + "\n" ] )

				io_tracker( tag: 'SEQ-W-NSID-' + nsid.to_s )

				seq_w( start_lba: start_lba , end_lba: ( end_lba - @test_info[ :max_blocks_per_io ] ) )

				io_tracker( tag: 'SEQ-W-NSID-' + nsid.to_s )

				f_log( [ 'FUNC' , 'SEQ-R' , 'NSID-' + nsid.to_s , '0 - ' + end_lba.to_s + "\n" ] )

				io_tracker( tag: 'SEQ-R-NSID-' + nsid.to_s )

				seq_r( start_lba: start_lba , end_lba: ( end_lba - @test_info[ :max_blocks_per_io ] ) , compare: compare )

				io_tracker( tag: 'SEQ-R-NSID-' + nsid.to_s )

			elsif	@namespace_info[ nsid ][ :type ] == 'zoned'

				zone_func( func: 'reset-all' , log: false )

				io_tracker( tag: 'ZONED-SEQ-W-R-C-NSID-' + nsid.to_s )

				@zone_info[ nsid ].each_key do |zone_id|

					disable_queuing( log: false )

					zoned_seq_w( zone_id: zone_id )

					enable_queuing( queue_depth: queue_depth , log: false )

					zoned_seq_r( zone_id: zone_id , compare: compare )

					disable_queuing( log: false )

					zone_func( zone_id: zone_id , func: 'close' , log: false )

					zone_func( zone_id: zone_id , func: 'finish' , log: false )
				end

				io_tracker( tag: 'ZONED-SEQ-W-R-C-NSID-' + nsid.to_s )

				zone_func( func: 'reset-all' , log: true )
			end
		end

		io_tracker( tag: 'PRECONDITION' )

		if sync == true ; sync( func: 'drives' ) ; end
	end

	def ms_latency_profile_0( runtime: 60 )

		disable_queuing()

		start_time = Time.now

		io_tracker( tag: 'profile_0' )

		loop do
			number_of_blocks = 1

			transfer_sizes = [ 4 , 8 , 16 , 32 , 64 ]

			counter = 0

			1.upto( 50 ) do

				bytes = transfer_sizes[ counter ] * 1024

				blocks_per_io = ( bytes / @drive_info[ :block_size ] ).to_i

				lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

				block_r( lba: lba , blocks_per_io: blocks_per_io , compare: false )

				if counter >= ( transfer_sizes.length - 1 ) ; counter = 0 ; else ; counter += 1 ; end
			end

			break if Time.now >= ( start_time + runtime )

			transfer_sizes = [ 128 , 256 , 512 , 1024 ]

			counter = 0

			1.upto( 13 ) do

				bytes = transfer_sizes[ counter ] * 1024

				blocks_per_io = ( bytes / @drive_info[ :block_size ] ).to_i

				lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

				block_r( lba: lba , blocks_per_io: blocks_per_io , compare: false )

				if counter >= ( transfer_sizes.length - 1 ) ; counter = 0 ; else ; counter += 1 ; end
			end

			break if Time.now >= ( start_time + runtime )

			blocks_per_io = ( 65536 / @drive_info[ :block_size ] ).to_i

			1.upto( 11 ) do

				lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

				block_w( lba: lba , blocks_per_io: blocks_per_io )
			end

			break if Time.now >= ( start_time + runtime )

			transfer_sizes = [ 128 , 256 , 512 ]

			counter = 0

			1.upto( 26 ) do

				bytes = transfer_sizes[ counter ] * 1024

				blocks_per_io = ( bytes / @drive_info[ :block_size ] ).to_i

				lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

				block_w( lba: lba , blocks_per_io: blocks_per_io )

				if counter >= ( transfer_sizes.length - 1 ) ; counter = 0 ; else ; counter += 1 ; end
			end

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'profile_0' )
	end

	def new_tvs_workload_1( runtime: 300 , queue_depth: 32 , compare: true )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-1' )

		start_time = Time.now

		loop do
			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			start_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

			# calculate end lba
			end_lba = start_lba + number_of_blocks

			seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( start_time + runtime )

			seq_r( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io , compare: compare )

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-1' )

		disable_queuing( log: false )
	end

	def new_tvs_workload_2( runtime: 300 , queue_depth: 32 , compare: true )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: true )

		io_tracker( tag: 'TVS-WL-2' )

		start_time = Time.now

		loop_counter = 1

		loop do
			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			start_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

			# calculate end lba
			end_lba = start_lba + number_of_blocks

			seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( start_time + runtime )

			sleep 1

			1.upto( 500 ) do

				random_lba = Random.rand( start_lba .. ( end_lba - blocks_per_io ) )

				block_r( lba: random_lba , blocks_per_io: blocks_per_io , compare: compare )
			end

			break if Time.now >= ( start_time + runtime )

			loop_counter += 1
		end

		io_tracker( tag: 'TVS-WL-2' )

		disable_queuing( log: false )
	end

	def new_tvs_workload_3( runtime: 300 , queue_depth: 32 , compare: true )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-3' )

		start_time = Time.now

		loop do
			lba = Random.rand( 0 .. ( $drive_info.max_lba - @test_info[ :max_blocks_per_io ] ) )

			1.upto( 10 ) do

				block_w( lba: lba , blocks_per_io: @test_info[ :max_blocks_per_io ] )
			end

			sleep 1

			block_r( lba: lba , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: compare )

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-3' )

		disable_queuing( log: false )
	end

	def new_tvs_workload_4( runtime: 300 , queue_depth: 32 , compare: true )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-4' )

		start_time = Time.now

		loop do
			lba = Random.rand( 0 .. ( $drive_info.max_lba - @test_info[ :max_blocks_per_io ] ) )

			block_w( lba: lba , blocks_per_io: @test_info[ :max_blocks_per_io ] )

			sleep 1

			1.upto( 10 ) do

				block_r( lba: lba , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: compare )
			end

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-4' )

		disable_queuing( log: false )
	end

	def new_tvs_workload_6( queue_depth: 32 )

		enable_queuing( queue_depth: queue_depth , log: false )

		last_usable_lba = ( ( @drive_info[ :max_lba ].to_i * @drive_info[ :block_size ] ).to_i - 1000000000000 ) / @drive_info[ :block_size ]

		start_lba = Random.rand( 0 ..( @drive_info[ :max_lba ].to_i - last_usable_lba ) )

		end_lba = ( start_lba + ( 1000000000000 / @drive_info[ :block_size ] ) )

		io_tracker( tag: 'TVS-WL-6-SEQ-W-1TB' )

		seq_w( start_lba: start_lba , end_lba: end_lba )

		io_tracker( tag: 'TVS-WL-6-SEQ-W-1TB' )

		return start_lba , end_lba
	end

	def new_tvs_workload_7( start_lba: nil , end_lba: nil , queue_depth: 32 , compare: true )

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-7-SEQ-R-C-1TB' )

		seq_r( start_lba: start_lba , end_lba: end_lba , compare: compare )

		io_tracker( tag: 'TVS-WL-7-SEQ-R-C-1TB' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_01( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		blocks_per_io = [ 256 , @test_info[ :max_blocks_per_io ].to_i ].min

		io_tracker( tag: 'TVS-WL-01' )

		start_time = Time.now

		loop do
			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			random_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			# calculate end lba
			end_lba = random_lba + number_of_blocks 

			seq_w( start_lba: random_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( start_time + runtime )

			seq_r( start_lba: random_lba , end_lba: end_lba , blocks_per_io: blocks_per_io , compare: false )

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-01' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_02( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-02' )

		start_time = Time.now

		counter = 0

		loop do
			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN LOOP' , counter.to_s ] , -2 )

			if counter.even? == true
				# set blocks_per_io ( block length per command ) to max
				blocks_per_io = @test_info[ :max_blocks_per_io ]
			else
				# set blocks_per_io , randomly between 1 - max
				blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )
			end

			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )
	
			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			random_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			# calculate end lba
			end_lba = random_lba + number_of_blocks

			seq_w( start_lba: random_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( start_time + runtime )

			# DELAY TO ALLOW WRITES TO COMPLETE
			sleep 1

			seq_r( start_lba: random_lba , end_lba: end_lba , blocks_per_io: blocks_per_io , compare: true )

			break if Time.now >= ( start_time + runtime )

			counter += 1
		end

		io_tracker( tag: 'TVS-WL-02' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_03( runtime: 300 , sleep: 10 , ttr: 0 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-03' )

		counter = 0

		main_timed_loop_start_time = Time.now

		loop do
			counter += 1

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN LOOP ' + counter.to_s ] , -2 )

			# set blocks_per_io to max
			blocks_per_io = @test_info[ :max_blocks_per_io ]

			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			start_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			# calculate end lba
			end_lba = start_lba + number_of_blocks

			# perform sequential write
			seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			# DELAY TO ALLOW WRITES TO COMPLETE
			sleep 1

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			( 1 ).upto( 1000 ) do

				_blocks_per_io = 1

				_random_lba_in_range = Random.rand( start_lba .. ( end_lba - _blocks_per_io - 1 ) )

				# read / compare data
				block_r( lba: _random_lba_in_range , blocks_per_io: _blocks_per_io , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			timed_loop2_start = Time.now

			# perform timed loop 2
			loop do
				max_blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

				io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: start_lba , end_lba: end_lba , max_blocks_per_io: max_blocks_per_io )

				random_lba_in_range = io_data[0]

				blocks_per_io = io_data[1]

				block_w( lba: random_lba_in_range , blocks_per_io: blocks_per_io )

				break if ( Time.now >= ( timed_loop2_start + ( runtime / 10 ) ) ) || ( Time.now >= ( main_timed_loop_start_time + runtime ) )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			( 1 ).upto( 5 ) do

				power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			# sequential read / compare
			seq_r( start_lba: start_lba , end_lba: end_lba , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: true )

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-03' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_04( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-04' )

		band1_min_lba = 0
		band1_max_lba = $drive_info.max_lba / 4

		f_log( [ 'INFO' , 'BAND 1' , 'START' , band1_min_lba.to_s ] , 2 )
		f_log( [ 'INFO' , 'BAND 1' , 'END' , band1_max_lba.to_s ] , 2 )

		band2_min_lba = ( $drive_info.max_lba / 4 ) + 1
		band2_max_lba = $drive_info.max_lba / 2

		f_log( [ 'INFO' , 'BAND 2' , 'START' , band2_min_lba.to_s ] , 2 )
		f_log( [ 'INFO' , 'BAND 2' , 'END' , band2_max_lba.to_s ] , 2 )

		band3_min_lba = ( $drive_info.max_lba / 2 ) + 1
		band3_max_lba = ( $drive_info.max_lba / 4 ) * 3

		f_log( [ 'INFO' , 'BAND 3' , 'START' + band3_min_lba.to_s ] , 2 )
		f_log( [ 'INFO' , 'BAND 3' , 'END' , band3_max_lba.to_s ] , 2 )

		band4_min_lba = ( ( $drive_info.max_lba / 4 ) * 3 ) + 1
		band4_max_lba = $drive_info.max_lba

		f_log( [ 'INFO' , 'BAND 4' , 'START' , band4_min_lba.to_s ] , 2 )
		f_log( [ 'INFO' , 'BAND 4' , 'END' , band4_max_lba.to_s ] , 2 )

		main_timed_loop_start_time = Time.now

		_max_block_tx_size = [ 512 , @test_info[ :max_blocks_per_io ].to_i ].min

		loop do
			# set blocks_per_io , randomly between 1 - 512
			blocks_per_io_band1 = Random.rand( 1 .. _max_block_tx_size )
			blocks_per_io_band2 = Random.rand( 1 .. _max_block_tx_size )
			blocks_per_io_band3 = Random.rand( 1 .. _max_block_tx_size )
			blocks_per_io_band4 = Random.rand( 1 .. _max_block_tx_size )

			number_of_blocks = 512

			# set random starting point ( band_start - ( band_end - number_of_blocks) )
			start_lba_band1 = Random.rand( band1_min_lba .. ( band1_max_lba - number_of_blocks ) )
			start_lba_band2 = Random.rand( band2_min_lba .. ( band2_max_lba - number_of_blocks ) )
			start_lba_band3 = Random.rand( band3_min_lba .. ( band3_max_lba - number_of_blocks ) )
			start_lba_band4 = Random.rand( band4_min_lba .. ( band4_max_lba - number_of_blocks ) )

			# set band end point
			end_lba_band1 = start_lba_band1 + number_of_blocks
			end_lba_band2 = start_lba_band2 + number_of_blocks
			end_lba_band3 = start_lba_band3 + number_of_blocks
			end_lba_band4 = start_lba_band4 + number_of_blocks

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'SECTION 1' ] , -2 )

			# perform sequential writes in sub-bands
			seq_w( start_lba: start_lba_band1 , end_lba: end_lba_band1 , blocks_per_io: blocks_per_io_band1 )

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			seq_w( start_lba: start_lba_band2 , end_lba: end_lba_band2 , blocks_per_io: blocks_per_io_band2 )

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			seq_w( start_lba: start_lba_band3 , end_lba: end_lba_band3 , blocks_per_io: blocks_per_io_band3 )

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			seq_w( start_lba: start_lba_band4 , end_lba: end_lba_band4 , blocks_per_io: blocks_per_io_band4 )

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'SECTION 2' ] , -2 )

			# perform 500 random block reads, no compare ( 0 .. ( $drive_info.max_lba - blocks_per_io ) )
			( 500 ).downto( 1 ) do

				max_blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

				io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: max_blocks_per_io )

				random_lba_in_range = io_data[0]

				blocks_per_io = io_data[1]

				block_r( lba: random_lba_in_range , blocks_per_io: blocks_per_io , compare: false )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'SECTION 3' ] , -2 )

			# perform 100 sequential read / compare of bands
			( 100 ).downto( 1 ) do

				seq_r( start_lba: start_lba_band1 , end_lba: end_lba_band1 , blocks_per_io: _max_block_tx_size , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )

				seq_r( start_lba: start_lba_band2 , end_lba: end_lba_band2 , blocks_per_io: _max_block_tx_size , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )

				seq_r( start_lba: start_lba_band3 , end_lba: end_lba_band3 , blocks_per_io: _max_block_tx_size , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )

				seq_r( start_lba: start_lba_band4 , end_lba: end_lba_band4 , blocks_per_io: _max_block_tx_size , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-04' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_05( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-05' )

		main_timed_loop_start_time = Time.now

		counter = 0

		loop do
			counter += 1

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN TIMED LOOP' , counter.to_s ] , -2 )

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'COUNT LOOP 1' ] , -2 )

			# perform write / read / compare of 500 random lbas with defined block transfer sizes
			# Odd main loop iterations will use random block_transfer size , even main loop iterations will use max blocks_per_io
			( 500 ).downto( 1 ) do |x|

				if counter.even? == true
					max_blocks_per_io = @test_info[ :max_blocks_per_io ]
				else
					max_blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )
				end

				io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: max_blocks_per_io )

				random_lba_in_range = io_data[0]

				blocks_per_io = io_data[1]

				block_w( lba: random_lba_in_range , blocks_per_io: blocks_per_io )

				break if Time.now >= ( main_timed_loop_start_time + runtime )

				# DELAY TO ALLOW WRITES TO COMPLETE
				sleep 1

				block_r( lba: random_lba_in_range , blocks_per_io: blocks_per_io , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: @test_info[ :max_blocks_per_io ] )

			random_lba_in_range = io_data[0]

			blocks_per_io = io_data[1]

			# perform read at random lba with max block transfer size , no compare
			block_r( lba: random_lba_in_range , blocks_per_io: blocks_per_io , compare: false )

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-05' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_06( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-06' )

		counter = 0

		main_timed_loop_start_time = Time.now

		loop do
			counter += 1

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN TIMED LOOP' , counter.to_s ] , -2 )

			( 1 ).upto( 1000 ) do |x|

				f_log( [ 'DEBUG' , __method__.to_s.upcase , 'COUNT LOOP ' + x.to_s ] , -2 )

				max_blocks_per_io = 1

				io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: max_blocks_per_io )

				random_lba_in_range = io_data[0]

				blocks_per_io = io_data[1]

				# perform 1 block device write at random lba
				block_w( lba: random_lba_in_range , blocks_per_io: blocks_per_io )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			if counter.even? == true

				blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )
			else
				blocks_per_io = @test_info[ :max_blocks_per_io ]
			end

			# set number_of_blocks to read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			end_lba = lba + number_of_blocks

			loop do
				block_r( lba: lba , blocks_per_io: blocks_per_io , compare: false )

				lba = lba + blocks_per_io

				break if Time.now >= ( main_timed_loop_start_time + runtime ) || lba + blocks_per_io > end_lba
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-06' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_07( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-07' )

		main_timed_loop_start_time = Time.now

		loop do
			# set random block transfer size
			blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

			# set number_of_blocks to write / read , randomly between 1000 - 100000
			number_of_blocks = Random.rand( 1000 .. 100000 )

			# set random starting point ( 0 - ( max lba - number_of_blocks) )
			start_lba = Random.rand( 0 .. ( $drive_info.max_lba - number_of_blocks ) )

			# calculate end lba
			end_lba = start_lba + number_of_blocks 

			seq_w( start_lba: start_lba , end_lba: end_lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			# DELAY TO ALLOW WRITES TO COMPLETE
			sleep 1

			( 1 ).upto( 1000 ) do

				_blocks_per_io = 1

				_random_lba_in_range = Random.rand( start_lba .. ( end_lba - _blocks_per_io ) )

				# perform block read / compare in lba range written
				block_r( lba: _random_lba_in_range , blocks_per_io: _blocks_per_io , compare: true )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-07' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_08( runtime: 300 , queue_depth: 32 )

		return if runtime == 0

		enable_queuing( queue_depth: queue_depth , log: false )

		io_tracker( tag: 'TVS-WL-08' )

		counter = 0

		main_timed_loop_start_time = Time.now

		loop do
			counter += 1

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN LOOP' , counter.to_s ] , -2 )

			if @test_info[ :max_blocks_per_io ] < 128

				max_blocks_per_io = @test_info[ :max_blocks_per_io ]
			else
				max_blocks_per_io = 128
			end

			io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: max_blocks_per_io )

			random_lba_in_range = io_data[0]

			blocks_per_io = io_data[1]

			# perform block write with a block transfer size of 128 at random lba
			block_w( lba: random_lba_in_range , blocks_per_io: blocks_per_io )

			# DELAY TO ALLOW WRITES TO COMPLETE
			sleep 1

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'COUNT LOOP 1' ] , -2 )

			( 6 ).downto( 1 ) do |x|

				f_log( [ 'DEBUG' , __method__.to_s.upcase , 'COUNT LOOP 1' , x.to_s ] , -2 )

				# set random block transfer size
				_blocks_per_io = Random.rand( 1 .. @test_info[ :max_blocks_per_io ] )

				io_data = _get_random_lba_in_range_and_random_blocks_per_io( start_lba: 0 , end_lba: $drive_info.max_lba , max_blocks_per_io: _blocks_per_io )

				_random_lba_in_range = io_data[0]

				_blocks_per_io = io_data[1]

				# perform block read , no compare
				block_r( lba: _random_lba_in_range , blocks_per_io: _blocks_per_io , compare: false )

				break if Time.now >= ( main_timed_loop_start_time + runtime )
			end

			break if Time.now >= ( main_timed_loop_start_time + runtime )

			# perform block read with a block transfer size of 128 with compare of data previously written
			block_r( lba: random_lba_in_range , blocks_per_io: blocks_per_io , compare: true )

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-08' )

		disable_queuing( log: false )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_workload_09( runtime: 300 , write_percentage: 60 , start_lba: 0 , end_lba: $drive_info.max_lba , loop_count: 100 )

		return if runtime == 0

		io_tracker( tag: 'TVS-WL-09' )

		counter = 0

		main_timed_loop_start_time = Time.now

		loop do
			counter += 1

			f_log( [ 'DEBUG' , __method__.to_s.upcase , 'MAIN LOOP' , counter.to_s ] , -2 )

			jedec_w_r( write_percentage: write_percentage , min_lba: start_lba , max_lba: end_lba , loop_count: loop_count )

			break if Time.now >= ( main_timed_loop_start_time + runtime )
		end

		io_tracker( tag: 'TVS-WL-09' )
	end

	# Calls Functions::power_cycle 'count' times
	# @return nil
	def tvs_power_cycle( count: 5 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: 10 , ttr: 0 , unsafe: false )

		return if count == 0

		( count ).downto( 1 ) do ; power_cycle( pwr_5v: pwr_5v , pwr_12v: pwr_12v , sleep: sleep , ttr: ttr , unsafe: unsafe ) ; end
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_io_soak( runtime_wl01: 3600 , runtime_wl02: 720 , runtime_wl03: 1800 , runtime_wl04: 720 , runtime_wl05: 720 , pc_01: 5 , runtime_wl06: 720 , runtime_wl07: 720 , pc_02: 5 , runtime_wl08: 3600 , pc_03: 10 , sleep: 10 , ttr: 0 )

		io_tracker( tag: 'TVS-IO-SOAK' )

		tvs_workload_01( runtime: runtime_wl01 )
		tvs_workload_02( runtime: runtime_wl02 )
		tvs_workload_03( runtime: runtime_wl03 , ttr: ttr )
		tvs_workload_04( runtime: runtime_wl04 )
		tvs_workload_05( runtime: runtime_wl05 )
		tvs_power_cycle( count: pc_01 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr , unsafe: true )
		tvs_workload_06( runtime: runtime_wl06 )
		tvs_workload_07( runtime: runtime_wl07 )
		tvs_power_cycle( count: pc_02 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr , unsafe: true )
		tvs_workload_08( runtime: runtime_wl08 )
		tvs_power_cycle( count: pc_03 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr , unsafe: false )

		io_tracker( tag: 'TVS-IO-SOAK' )
	end

	# See PTL Workloads flowchart for details
	# @return nil
	def tvs_io_ramp( runtime_wl08: 300 , pc_01: 2 , runtime_wl06: 300 , pc_02: 2 , runtime_wl07: 300 , pc_03: 2 , runtime_wl09: 300 , pc_04: 5 , runtime_wl03: 1200 , pc_05: 2 , runtime_wl05: 300 , sleep: 10 , ttr: 0 )

		io_tracker( tag: 'TVS-IO-RAMP' )

		tvs_workload_08( runtime: runtime_wl08 )
		tvs_power_cycle( count: pc_01 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )
		tvs_workload_06( runtime: runtime_wl06 )
		tvs_power_cycle( count: pc_02 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )
		tvs_workload_07( runtime: runtime_wl07 )
		tvs_power_cycle( count: pc_03 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )
		tvs_workload_09( runtime: runtime_wl09 )
		tvs_power_cycle( count: pc_04 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )
		tvs_workload_03( runtime: runtime_wl03 , ttr: ttr )
		tvs_power_cycle( count: pc_05 , pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , sleep: sleep , ttr: ttr )
		tvs_workload_05( runtime: runtime_wl05 )

		io_tracker( tag: 'TVS-IO-RAMP' )
	end

	def timed_seq_w( runtime: nil , queue_depth: 64 , start_lba: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] , end_lba_action: 'repeat' )

		enable_queuing( queue_depth: queue_depth , log: false )

		block_count = 1000

		start_time = Time.now

		loop do
			if start_lba + block_count > @drive_info[ :max_lba ] && end_lba_action == 'repeat' ; start_lba = 0 ; else ; break ; end

			seq_w( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io )

			start_lba = start_lba + block_count

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end

		disable_queuing( log: false )
	end

	def timed_seq_r( runtime: nil , queue_depth: 64 , start_lba: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false , end_lba_action: 'repeat' )

		enable_queuing( queue_depth: queue_depth , log: false )

		block_count = 1000

		start_time = Time.now

		loop do
			if start_lba + block_count > @drive_info[ :max_lba ] && end_lba_action == 'repeat' ; start_lba = 0 ; else ; break ; end

			seq_r( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io , compare: compare )

			start_lba = start_lba + block_count

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end

		disable_queuing( log: false )
	end

	def timed_seq_w_r( runtime: nil , queue_depth: 32 , compare: true , start_lba: 0 , blocks_per_io: @test_info[ :max_blocks_per_io ] , end_lba_action: 'repeat' )

		enable_queuing( queue_depth: queue_depth , log: false )

		block_count = 10000

		start_time = Time.now

		loop do
			if start_lba + block_count > @drive_info[ :max_lba ] && end_lba_action == 'repeat' ; start_lba = 0 ; end

			seq_w( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io )

			# DELAY TO ALLOW WRITES TO COMPLETE
			sleep 1

			seq_r( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io , compare: compare )

			start_lba = start_lba + block_count

			break if Time.now >= ( start_time + runtime )

			$angel.check_instruction
		end

		disable_queuing( log: false )
	end

	def baseline()

		unless @test_info[ :baseline ] == true ; return ; end

		f_log( [ 'INFO' , 'BASELINE START' + "\n" ] )

		inspector_upload()

		1.upto( 15 ) do |counter|

			f_log( [ 'INFO' , 'BASELINE SECTION A' , 'LOOP-' + counter.to_s + "\n" ] )

			baseline_workload( workload: 1 )
			baseline_workload( workload: 2 )
			baseline_workload( workload: 3 )
			baseline_workload( workload: 4 )

			$angel.wait( 'Seconds' , 10 )

			sync( type: 'drives' )

			baseline_workload( workload: 0 )

			power_cycle()

			$angel.wait( 'Seconds' , 15 )

			sync( type: 'drives' )
		end

		inspector_upload()

		sync( type: 'drives' )

		1.upto( 15 ) do |counter|

			f_log( [ 'INFO' , 'BASELINE SECTION B' , 'LOOP-' + counter.to_s + "\n" ] )

			baseline_workload( workload: 5 )
			baseline_workload( workload: 6 )
			baseline_workload( workload: 7 )
			baseline_workload( workload: 8 )
			baseline_workload( workload: 9 )
			baseline_workload( workload: 10 )

			sync( type: 'drives' )

			baseline_workload( workload: 0 )

			power_cycle()

			$angel.wait( 'Seconds' , 15 )

			sync( type: 'drives' )
		end

		inspector_upload()

		baseline_workload( workload: 11 )
		baseline_workload( workload: 12 )

		sync( type: 'drives' )

		inspector_upload()

		f_log( [ 'INFO' , 'BASELINE END' + "\n" ] )
	end

	def baseline_workload( runtime: 900 , queue_depth: 64 , compare: false , workload: nil )

		case workload

			when 0	; baseline_workload_0()
			when 1	; baseline_workload_1( runtime: runtime , queue_depth: queue_depth , compare: compare )
			when 2	; baseline_workload_2( runtime: runtime , queue_depth: queue_depth , compare: compare ) 
			when 3	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 80 , random: 20  , block_size: 32   )
			when 4	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 0  , random: 0   , block_size: 8    )
			when 5	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 95 , random: 75  , block_size: 4    )
			when 6	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 95 , random: 75  , block_size: 64   )
			when 7	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 67 , random: 100 , block_size: 4    )
			when 8	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 90 , random: 75  , block_size: 8    )
			when 9	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 80 , random: 80  , block_size: 32   )
			when 10	; baseline_workload_x( workload: workload , runtime: runtime , queue_depth: queue_depth , read: 70 , random: 0   , block_size: 1024 )
			when 11	; baseline_workload_11( queue_depth: queue_depth )
			when 12	; baseline_workload_12( queue_depth: queue_depth , compare: compare )
			else	; f_log( [ 'INFO' , 'INVALID WORKLOAD ID' ] )
		end
	end

	def baseline_workload_x( workload: nil , block_count: 1000 , runtime: nil , queue_depth: nil , read: nil , random: nil , block_size: nil )

		sequential_percentage = ( 100 - random ).to_i ; read_percentage = ( read.to_f / 100 ).to_f

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		unless block_size == 'random' ; blocks_per_io = ( ( block_size * 1024 ) / @drive_info[ :block_size ] ).to_i ; end

		io_tracker( tag: 'BASELINE-WL-' + workload.to_s )

		# sequential section

		unless random == 100

			sequential_runtime = ( runtime * ( sequential_percentage.to_f / 100 ) ).to_i

			sequential_read_runtime = ( sequential_runtime * read_percentage ).to_i

			sequential_write_runtime = ( sequential_runtime - sequential_read_runtime ).to_i

			unless read == 0

				sequential_read_start_time = Time.now

				loop do
					if block_size == 'random' ; blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] ).to_i ; end

					start_lba = rand( 0..( @drive_info[ :max_lba ] - block_count ) )

					seq_r( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io )

					break if Time.now >= ( sequential_read_start_time + sequential_read_runtime )
				end
			end

			unless read == 100

				sequential_write_start_time = Time.now

				loop do
					if block_size == 'random' ; blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] ).to_i ; end

					start_lba = rand( 0..( @drive_info[ :max_lba ] - block_count ) )

					seq_w( start_lba: start_lba , end_lba: start_lba + block_count , blocks_per_io: blocks_per_io )

					break if Time.now >= ( sequential_write_start_time + sequential_write_runtime )
				end
			end
		end

		# random section

		unless random == 0

			random_runtime = ( runtime - ( runtime * ( sequential_percentage.to_f / 100 ) ).to_i )

			random_read_runtime = ( random_runtime * read_percentage ).to_i

			random_write_runtime = ( random_runtime - random_read_runtime ).to_i

			unless read == 0

				random_read_start_time = Time.now

				loop do
					if block_size == 'random' ; blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] ).to_i ; end

					lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

					block_r( lba: lba , blocks_per_io: blocks_per_io )

					break if Time.now >= ( random_read_start_time + random_read_runtime )
				end
			end

			unless read == 100

				random_write_start_time = Time.now

				loop do
					if block_size == 'random' ; blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] ).to_i ; end

					lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

					block_w( lba: lba , blocks_per_io: blocks_per_io )

					break if Time.now >= ( random_write_start_time + random_write_runtime )
				end
			end
		end

		io_tracker( tag: 'BASELINE-WL-' + workload.to_s )

		disable_queuing( log: false )
	end

	def baseline_workload_0( runtime: 5 , queue_depth: 64 )

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		blocks_per_io = ( 64 * 1024 / @drive_info[ :block_size ] ).to_i

		io_tracker( tag: 'BASELINE-WL-0' )

		start_time = Time.now

		loop do
			lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

			block_w( lba: lba , blocks_per_io: blocks_per_io )

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'BASELINE-WL-0' )

		disable_queuing( log: false )
	end

	def baseline_workload_1( runtime: 900 , compare: false , queue_depth: 64 )

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_lba = 0

		blocks_per_io = ( 64 * 1024 / @drive_info[ :block_size ] ).to_i

		io_tracker( tag: 'BASELINE-WL-1' )

		start_time = Time.now

		loop do
			seq_w_r( start_lba: start_lba , end_lba: start_lba + 1000 , blocks_per_io: blocks_per_io , compare: compare )

			start_lba = start_lba + 1000

			if start_lba >= @drive_info[ :max_lba ] || Time.now >= ( start_time + runtime ) ; break ; end
		end

		io_tracker( tag: 'BASELINE-WL-1' )

		disable_queuing( log: false )
	end

	def baseline_workload_2( runtime: 900 , compare: false , queue_depth: 64 )

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		transfer_sizes = [ 4 , 8 , 16 , 32 , 64 , 128 , 256 , 512 , 1024 ]

		loop_counter = 0

		io_tracker( tag: 'BASELINE-WL-2' )

		start_time = Time.now

		loop do
			if loop_counter % 9 == 0 && loop_counter != 0 ; loop_counter = 0 ; end

			bytes = transfer_sizes[ loop_counter ] * 1024

			blocks_per_io = ( bytes / @drive_info[ :block_size ] ).to_i

			lba = rand( 0..( @drive_info[ :max_lba ] - blocks_per_io ) )

			block_w( lba: lba , blocks_per_io: blocks_per_io )

			block_r( lba: lba , blocks_per_io: blocks_per_io , compare: compare )

			loop_counter += 1

			break if Time.now >= ( start_time + runtime )
		end

		io_tracker( tag: 'BASELINE-WL-2' )

		disable_queuing( log: false )
	end

	def baseline_workload_11( queue_depth: 64 )

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		blocks_per_io = ( ( 64 * 1024 ) / @drive_info[ :block_size ] ).to_i

		io_tracker( tag: 'BASELINE-WL-11' )

		seq_w( blocks_per_io: blocks_per_io )

		io_tracker( tag: 'BASELINE-WL-11' )

		disable_queuing( log: false )
	end

	def baseline_workload_12( queue_depth: 64 , compare: false )

		data_pattern( pattern: '0000FFFF' , log: false )

		enable_queuing( queue_depth: queue_depth , log: false )

		blocks_per_io = ( ( 64 * 1024 ) / @drive_info[ :block_size ] ).to_i

		io_tracker( tag: 'BASELINE-WL-12' )

		seq_r( blocks_per_io: blocks_per_io , compare: compare )

		io_tracker( tag: 'BASELINE-WL-12' )

		disable_queuing( log: false )
	end

	# CNS workload used in ZNS testing
	def cns_workload_1( nsid: @drive_info[ :conv_namespace ] , runtime: 15 , blocks_per_io: nil , compare: false , queue_depth: 64 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_time = Time.now

		loop do
			if blocks_per_io == nil

				_blocks_per_io = rand( 1..128 )
			else
				_blocks_per_io = blocks_per_io
			end

			random_lba = rand( 0..( @namespace_info[ nsid ][ :ncap ] - _blocks_per_io ) )

			block_w( lba: random_lba , blocks_per_io: _blocks_per_io )

			block_r( lba: random_lba , blocks_per_io: _blocks_per_io , compare: compare )

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )
	end

	# CNS workload used in ZNS testing
	def cns_workload_2( nsid: @drive_info[ :conv_namespace ] , runtime: 180 , queue_depth: 64 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_time = Time.now

		loop_counter = 0

		loop do
			1.upto( 500 ) do |loop_counter|

				break if Time.now >= ( start_time + runtime )

				if loop_counter.even?

					blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] )
				else
					blocks_per_io = @test_info[ :max_blocks_per_io ]
				end

				start_lba = rand( 0..( @namespace_info[ nsid ][ :ncap ] - blocks_per_io ) )

				block_w( lba: start_lba , blocks_per_io: blocks_per_io )

				block_r( lba: start_lba , blocks_per_io: blocks_per_io , compare: true )
			end

			break if Time.now >= ( start_time + runtime )

			start_lba = rand( 0..( @namespace_info[ nsid ][ :ncap ] - @test_info[ :max_blocks_per_io ] ) )

			block_r( lba: start_lba , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: false )

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )
	end

	# CNS workload used in ZNS testing
	def cns_workload_3( nsid: @drive_info[ :conv_namespace ] , runtime: 180 , queue_depth: 64 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		blocks_per_io = 128

		start_time = Time.now

		loop do
			start_lba = rand( 0..( @namespace_info[ nsid ][ :ncap ] - blocks_per_io ) )

			block_w( lba: start_lba , blocks_per_io: blocks_per_io )

			1.upto( 6 ) do

				break if Time.now >= ( start_time + runtime )

				block_r( lba: start_lba , blocks_per_io: blocks_per_io , compare: false )
			end

			break if Time.now >= ( start_time + runtime )

			block_r( lba: start_lba , blocks_per_io: blocks_per_io , compare: true )
		end

		disable_queuing( log: false )
	end

	# CNS workload used in ZNS testing
	def cns_workload_4( nsid: @drive_info[ :conv_namespace ] , runtime: 720 , queue_depth: 64 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_time = Time.now

		count = 1

		loop do
			if count <= 5 ; bytes = 16 ; elsif count <= 10 ; bytes = 32 ; elsif count <= 30 ; bytes = 64 ; elsif count <= 80 ; bytes = 128 ; elsif count <= 100 ; bytes = 256 ; end

			bytes = bytes * 1024

			blocks_per_io = ( bytes / @drive_info[ :block_size ] ).to_i

			start_lba = rand( 0..( @namespace_info[ nsid ][ :ncap ] - blocks_per_io ) )

			block_w( lba: start_lba , blocks_per_io: blocks_per_io )

			block_r( lba: start_lba , blocks_per_io: blocks_per_io , compare: true )

			count += 1 ; if count > 100 ; count = 1 ; end

			break if Time.now >= ( start_time + 720 )
		end

		end_lba = @namespace_info[ nsid ][ :ncap ] - @test_info[ :max_blocks_per_io ]

		seq_r( start_lba: 0 , end_lba: end_lba )
	end

	def zns_workload_1( nsid: @drive_info[ :zoned_namespace ] , runtime: 15 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones = array_of_zones.sample( @drive_info[ :max_open_zones ] )

		min_blocks_per_io = 128

		enable_queuing( queue_depth: queue_depth , log: false )

		# Need to get the max_blocks_per_io with queuing enabled to ensure that write transfer size is the same as read transfer size
		max_blocks_per_io = @test_info[ :max_blocks_per_io ]

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			if zones.length == 0 ; zones = array_of_zones.sample( @drive_info[ :max_open_zones ] ) ; end

			zones.each do |zone_id|

				$angel.check_instruction

				refresh_zone_info( nsid: nsid )

				zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ] 
				write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ] 

				if zone_state == 'full'

					enable_queuing( queue_depth: queue_depth , log: false )

					zoned_seq_r( zone_id: zone_id , blocks_per_io: @test_info[ :max_blocks_per_io ] , compare: true )

					disable_queuing( log: false )

					zones.delete( zone_id ) ; array_of_zones.delete( zone_id )
				else
					blocks_per_io = rand( min_blocks_per_io..max_blocks_per_io )

					zoned_block_w( zone_id: zone_id , blocks_per_io: blocks_per_io )

					enable_queuing( queue_depth: queue_depth , log: false )

					zoned_block_r( zone_id: zone_id , lba: write_pointer , blocks_per_io: blocks_per_io , compare: true )

					disable_queuing( log: false )

					break if Time.now >= ( start_time + runtime )
				end

				break if Time.now >= ( start_time + runtime )
			end

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_2( nsid: @drive_info[ :zoned_namespace ] , runtime: 3600 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		start_zone = rand( 0..( total_number_of_zones ).to_i )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_time = Time.now

		loop do
			start_zone.upto( total_number_of_zones.to_i - 1 ) do |zone_id|

				$angel.check_instruction

				zoned_seq_r( zone_id: zone_id , compare: false )

				break if Time.now >= ( start_time + runtime )
			end

			start_zone = 0

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	# If blocks_per_io == nil method will select a random blocks_per_io rand( 1000..200000 )
	def zns_workload_3( nsid: @drive_info[ :zoned_namespace ] , runtime: 3600 , queue_depth: 32 , blocks_per_io: nil )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones = array_of_zones.sample( @drive_info[ :max_open_zones ] )

		enable_queuing( queue_depth: queue_depth , log: false )

		# Need to get the max_blocks_per_io with queuing enabled to ensure that write transfer size is the same as read transfer size
		max_blocks_per_io = @test_info[ :max_blocks_per_io ]

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			if zones.length == 0 ; zones = array_of_zones.sample( @drive_info[ :max_open_zones ] ) ; end

			zones.each do |zone_id|

				$angel.check_instruction

				break if Time.now >= ( start_time + runtime )

				refresh_zone_info( nsid: nsid )

				write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ] 
				zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ] 

				if zone_state == 'full'

					f_log( [ 'DEBUG' , zone_id.to_s , zone_state.to_s ] , -2 )

					zones.delete( zone_id ) ; array_of_zones.delete( zone_id )
				else
					if blocks_per_io == nil

						_blocks_per_io = rand( 1..max_blocks_per_io )
					else
						_blocks_per_io = blocks_per_io
					end

					number_of_blocks = rand( 1000..200000 )

					zoned_seq_w( zone_id: zone_id , end_lba: write_pointer + number_of_blocks , blocks_per_io: _blocks_per_io )

					enable_queuing( queue_depth: queue_depth , log: false )

					zoned_seq_r( zone_id: zone_id , start_lba: write_pointer , end_lba: write_pointer + number_of_blocks , blocks_per_io: _blocks_per_io , compare: true )

					disable_queuing( log: false )
				end
			end

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_4( nsid: @drive_info[ :zoned_namespace ] , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones = array_of_zones.sample( @drive_info[ :max_open_zones ] )

		disable_queuing( log: false )

		zones.each do |zone_id|

			$angel.check_instruction

			refresh_zone_info( nsid: nsid )

			end_lba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + ( @zone_info[ nsid ][ zone_id ][ :zone_cap ] * 0.95 ).floor.to_i

			zoned_seq_w( zone_id: zone_id , end_lba: end_lba )
		end

		enable_queuing( queue_depth: queue_depth , log: false )

		loop_start_time = Time.now

		loop do
			$angel.check_instruction

			zone_id = zones.sample

			lba = rand( @zone_info[ nsid ][ zone_id ][ :zone_start_lba ]..( ( @zone_info[ nsid ][ zone_id ][ :zone_end_lba ] * 0.95 ).floor.to_i - 1 ) )

			zoned_block_r( zone_id: zone_id , lba: lba , blocks_per_io: 1 , compare: true )

			break if Time.now >= ( loop_start_time + 180 )
		end

		1.upto( 5 ) do $angel.check_instruction ; power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting ) ; end

		zones.each do |zone_id|

			$angel.check_instruction

			refresh_zone_info( nsid: nsid )

			unless @zone_info[ nsid ][ zone_id ][ :zone_state ] == 'closed' || @test_info[ :power_control ] == false

				force_failure( category: 'user_force_failure' , data: 'zone ' + zone_id.to_s + ' open after power cycle' )
			end

			end_lba = @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + ( @zone_info[ nsid ][ zone_id ][ :zone_cap ] * 0.95 ).floor.to_i

			zoned_seq_r( zone_id: zone_id , end_lba: end_lba , compare: true )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_5( nsid: @drive_info[ :zoned_namespace ] , runtime: 720 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		blocks_per_io = @test_info[ :max_blocks_per_io ]

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones_write = zones_read = array_of_zones.sample( 4 )

		disable_queuing( log: false )

		start_time = Time.now

		loop_counter = 0

		loop do
			break if Time.now >= ( start_time + runtime )

			if zones_write.length == 0 ; zones_write = zones_read = array_of_zones.sample( 4 ) ; loop_counter = 0 ; end

			zones_write.each do |zone_id|

				$angel.check_instruction

				array_of_zones.delete( zone_id )

				refresh_zone_info( nsid: nsid )

				write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ] 
				zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ] 

				if zone_state == 'full'

					f_log( [ 'DEBUG' , zone_id.to_s , zone_state.to_s ] , -2 )

					zone_write.delete( zone_id )
				else
					blocks_per_io = rand( 1..512 )

					zoned_seq_w( zone_id: zone_id , end_lba: write_pointer + 512 , blocks_per_io: blocks_per_io )
				end

				break if Time.now >= ( start_time + runtime )
			end

			break if Time.now >= ( start_time + runtime )

			enable_queuing( queue_depth: queue_depth , log: false )

			1.upto( 500 ) do

				$angel.check_instruction

				zone_id = array_of_zones.sample

				blocks_per_io = rand( 1..512 )

				offset = rand( 0..( @zone_info[ nsid ][ zone_id ][ :zone_cap ] - blocks_per_io ).to_i )

				zoned_block_r( zone_id: zone_id , offset: offset , blocks_per_io: blocks_per_io , compare: false )

				break if Time.now >= ( start_time + runtime )
			end

			break if Time.now >= ( start_time + runtime )

			offset = ( loop_counter * 512 ).to_i

			zones_read.each do |zone_id|

				1.upto( 100 ) do

					$angel.check_instruction

					zoned_block_r( zone_id: zone_id , offset: offset , blocks_per_io: 512 , compare: true )

					break if Time.now >= ( start_time + runtime )
				end

				break if Time.now >= ( start_time + runtime )
			end

			loop_counter += 1
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_6( nsid: @drive_info[ :zoned_namespace ] , runtime: 720 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones = array_of_zones.sample( @drive_info[ :max_open_zones ] )

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			break if Time.now >= ( start_time + runtime )

			zone_func( func: 'reset-all' , log: false )

			zones.each do |zone_id|

				$angel.check_instruction

				zoned_seq_w( zone_id: zone_id , end_lba: @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + 1000 , blocks_per_io: 1 )

				array_of_zones.delete( zone_id )

				break if Time.now >= ( start_time + runtime )
			end

			break if Time.now >= ( start_time + runtime )

			zone_id = array_of_zones.sample

			enable_queuing( queue_depth: queue_depth , log: false )

			zoned_seq_r( zone_id: zone_id )

			blocks_per_io = rand( 1..1000 )

			zones.each do |zone_id|

				$angel.check_instruction

				zoned_seq_r( zone_id: zone_id , end_lba: @zone_info[ nsid ][ zone_id ][ :zone_start_lba ] + 1000 , blocks_per_io: blocks_per_io , compare: true )

				break if Time.now >= ( start_time + runtime )
			end

			disable_queuing( log: false )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_7( nsid: @drive_info[ :zoned_namespace ] , runtime: 720 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			zone_id = array_of_zones.sample ; array_of_zones.delete( zone_id )

			disable_queuing( log: false )

			loop do
				$angel.check_instruction

				refresh_zone_info( nsid: nsid )

				write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ]
				zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ]

				break if Time.now >= ( start_time + runtime ) || zone_state == 'full'

				number_of_blocks = rand( 1000..200000 )

				blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] )

				zoned_seq_w( zone_id: zone_id , end_lba: write_pointer + number_of_blocks , blocks_per_io: blocks_per_io )
			end

			break if Time.now >= ( start_time + runtime )

			enable_queuing( queue_depth: queue_depth , log: false )

			1.upto( 1000 ) do

				$angel.check_instruction

				offset = rand( 0..( @zone_info[ nsid ][ zone_id ][ :zone_cap ] - 1 ).to_i )

				zoned_block_r( zone_id: zone_id , offset: offset , blocks_per_io: 1 , compare: true )

				break if Time.now >= ( start_time + runtime )
			end

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_8( nsid: @drive_info[ :zoned_namespace ] , runtime: 720 , queue_depth: 32 , explicit_commit: false )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		overwrite_percentage = 2

		zone_id = array_of_zones.sample

		zone_func( nsid: nsid , func: 'open-zrwaa' , zone_id: zone_id , log: false )

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			$angel.check_instruction

			refresh_zone_info( nsid: nsid )

			zone_max_lba	= @zone_info[ nsid ][ zone_id ][ :zone_max_lba ]
			write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ]
			zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ]

			break if Time.now >= ( start_time + runtime ) || zone_state == 'full'

			blocks_per_io = ( ( 16 * 1024 ) / @drive_info[ :block_size ] ).to_i

			zoned_block_w( zone_id: zone_id , blocks_per_io: blocks_per_io )

			zrwa = rand( 0..99 )

			# This must be block_w ( not zoned_block_w ) because we are writing the same area again
			if zrwa < overwrite_percentage ; block_w( lba: write_pointer , blocks_per_io: blocks_per_io ) ; end

			#FIXME - explicit_commit is not working properly
			if explicit_commit == true ; zone_func( nsid: nsid , func: 'commit' , zone_id: zone_id , commit_lba: write_pointer + blocks_per_io , log: true ) ; end

			enable_queuing( queue_depth: queue_depth , log: false )

			zoned_block_r( zone_id: zone_id , lba: write_pointer , blocks_per_io: blocks_per_io , compare: true )

			disable_queuing( log: false )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_9( nsid: @drive_info[ :zoned_namespace ] , runtime: 300 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		enable_queuing( queue_depth: queue_depth , log: false )

		start_time = Time.now

		loop do
			$angel.check_instruction

			break if Time.now >= ( start_time + runtime )

			zone_id = array_of_zones.sample

			zone_cap = @zone_info[ nsid ][ zone_id ][ :zone_cap ]

			blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] )

			offset = rand( 0..( zone_cap - blocks_per_io ).to_i )

			zoned_block_r( zone_id: zone_id , offset: offset , blocks_per_io: blocks_per_io , compare: false )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	def zns_workload_10( nsid: @drive_info[ :zoned_namespace ] , runtime: 1500 , queue_depth: 32 )

		unless @test_info[ :selected_namespace ] == nsid ; select_namespace( nsid: nsid , log: false ) ; end

		zone_func( func: 'reset-all' , log: false )

		data_pattern( @zns_data_patterns[ ( rand( 0..4 ) ) ] )

		total_number_of_zones = get_number_of_zones( nsid: nsid )

		array_of_zones = *( 0..( total_number_of_zones - 1 ).to_i )

		zones = array_of_zones.sample( @drive_info[ :max_open_zones ] )

		disable_queuing( log: false )

		start_time = Time.now

		loop do
			if zones.length == 0 ; zones = array_of_zones.sample( @drive_info[ :max_open_zones ] ) ; end

			zones.each do |zone_id|

				$angel.check_instruction

				refresh_zone_info( nsid: nsid )

				write_pointer	= @zone_info[ nsid ][ zone_id ][ :write_pointer ]
				zone_state	= @zone_info[ nsid ][ zone_id ][ :zone_state ]

				break if Time.now >= ( start_time + runtime )

				if zone_state == 'full'

					f_log( [ 'DEBUG' , zone_id.to_s , zone_state.to_s ] , -2 )

					enable_queuing( queue_depth: queue_depth , log: false )

					zoned_seq_r( zone_id: zone_id , compare: true )

					disable_queuing( log: false )

					zones.delete( zone_id ) ; array_of_zones.delete( zone_id )
				else
					blocks_per_io = rand( 1..@test_info[ :max_blocks_per_io ] )

					zoned_block_w( zone_id: zone_id , blocks_per_io: blocks_per_io )
				end
			end

			break if Time.now >= ( start_time + runtime )
		end

		disable_queuing( log: false )

		zone_func( func: 'reset-all' , log: false )
	end

	private

	# Calculates a usable random LBA & blocks_per_io based on user provided start_lba , end_lba & max_blocks_per_io
	# @return random_lba_in_range & blocks_per_io
	def _get_random_lba_in_range_and_random_blocks_per_io( start_lba: nil , end_lba: nil , max_blocks_per_io: nil )

		blocks_per_io = max_blocks_per_io

		begin
			# this can occasionally fails , because ( end_lba - blocks_per_io ) can be less than start_lba
			random_lba_in_range = Random.rand( start_lba .. ( end_lba - blocks_per_io ) )

			if random_lba_in_range < 1 ; raise 'lba_out_of_range' ; end

		rescue StandardError => error

			# if ( end_lba - blocks_per_io ) < start_lba , reduce blocks_per_io by 10 % and try again
			blocks_per_io = ( blocks_per_io * 0.9 ).round

			retry
		end

		return( [ random_lba_in_range , blocks_per_io ] )
	end

	def _check_blocks_per_io( blocks_per_io: blocks_per_io )

		if blocks_per_io.to_i > @test_info[ :max_blocks_per_io ].to_i

			_warning_counter( category: '_max_blocks_per_io_exceeded' , data: 'REDUCING BLOCKS_PER_IO FROM ' + blocks_per_io.to_s + ' TO ' + @test_info[ :max_blocks_per_io ].to_s )

			return @test_info[ :max_blocks_per_io ]
		else
			return blocks_per_io
		end
	end

	def _get_error_details()

		error_info = {}

                angel_error_info = $angel.shared.p_latest_error_info_

                unless angel_error_info == nil

			error_info[ :os_rc ] = angel_error_info.errno_.to_s

			unless error_info[ :os_rc ].to_i == 0

				# /usr/bin/perror
				cmd = 'perror ' + error_info[ :os_rc ].to_s

				os_rc_desc = ( %x( #{ cmd.to_s } ).chomp ).split( /\:/ )[-1].strip

				error_info[ :os_rc ] += ' : ' + os_rc_desc.to_s
			end

			error_info[ :category ] = angel_error_info.category_.to_s
			error_info[ :ioctl_rc ] = angel_error_info.ioctl_return_code_.to_s
			error_info[ :nvme_rc  ] = angel_error_info.nvme_ioctl_rc_.to_s(16)
			error_info[ :cmd_time ] = ( angel_error_info.command_elapsed_time_ / 1000000 ).to_s
			error_info[ :nvme_cmd ] = angel_error_info.get_error_command_string
			error_info[ :pfcode   ] = angel_error_info.pf_code_.to_s
		end

		return error_info
	end
end
