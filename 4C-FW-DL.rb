
VERSION = 10.5

def firmware_downloads( firmware_download_count , ttr )

	1.upto( firmware_download_count ) do

		if	@firmware_download_count.odd?

			if @download_method == 'angel'
			
				$ANGEL.firmware_download( firmware: @firmware_1 , firmware_slot: 1 , power_cycle: false , commit_action: 3 )
			else
				$ANGEL.firmware_download_nvme_cli( firmware: @firmware_1 , firmware_slot: 1 , power_cycle: false , commit_action: 3 )
			end

		elsif	@firmware_download_count.even?

			if @download_method == 'angel'

				$ANGEL.firmware_download( firmware: @firmware_2 , firmware_slot: 1 , power_cycle: false , commit_action: 3 )
			else
				$ANGEL.firmware_download_nvme_cli( firmware: @firmware_2 , firmware_slot: 1 , power_cycle: false , commit_action: 3 )
			end
		end

		@firmware_download_count += 1

		$ANGEL.f_log( [ 'FUNC' , 'RANDOM' , 'BLOCK-W-R-C' , "10\n" ] )

		$ANGEL.timed_random_block_w_r( runtime: 10 )

		$ANGEL.f_log( [ 'INFO' , 'FW-DL' , 'COUNT' , @firmware_download_count.to_s + "\n" ] )

		if @firmware_download_count % 20 == 0 

			$ANGEL.power_cycle( pwr_5v: $power.get_5v_setting , pwr_12v: $power.get_12v_setting , ttr: ttr , unsafe: false )
		end

		$angel.check_instruction
	end
end

def start_test_phase( hash )

	if	hash[ :phase ] == 'precondition'

		$ANGEL.precondition( set_temp: 25 )

		$ANGEL.baseline()

	elsif	hash[ :phase ] == 'ramp'

		$ANGEL.set_chamber_temp( temp: hash[ :temp ] , time_limit: hash[ :ramp_time ] , sync: false )

		$ANGEL.power_cycle( pwr_5v: hash[ :voltage_5v ].to_f , pwr_12v: hash[ :voltage_12v ].to_f , ttr: hash[ :ttr ].to_i )

		firmware_downloads( hash[ :download_count ] , hash[ :ttr ] )

		$ANGEL.get_parametric_data( log: true )

		$ANGEL.sync()

	elsif	hash[ :phase ] == 'soak'

		$ANGEL.power_cycle( pwr_5v: hash[ :voltage_5v ].to_f , pwr_12v: hash[ :voltage_12v ].to_f , ttr: hash[ :ttr ].to_i )

		firmware_downloads( hash[ :download_count ] , hash[ :ttr ] )

		$ANGEL.get_parametric_data( log: true )

		$ANGEL.sync( type: 'drives' )

	elsif	hash[ :phase ] == 'post'

		$ANGEL.set_chamber_temp( temp: hash[ :temp ] , time_limit: 0 , sync: false )

		$ANGEL.io_tracker( tag: 'POST-SEQ-W' )

		$ANGEL.seq_w()

		$ANGEL.io_tracker( tag: 'POST-SEQ-W' )

		$ANGEL.io_tracker( tag: 'POST-SEQ-RC' )

		$ANGEL.seq_r( compare: true )

		$ANGEL.io_tracker( tag: 'POST-SEQ-RC' )
	end
end

def main()

	$ANGEL.pre_script_handler()

	# USER DEFINED - DRIVE SPECIFIC - START

	start_loop = 0

	@firmware_1 = 'MC104003'
	@firmware_2 = 'MC104004'

	# angel ( sends custom nvme commands via library ) or nvme-cli ( uses nvme-cli )
	@download_method = 'angel'

	drive_spec_temp_low = 0

	drive_spec_temp_high = 70

	drive_to_amnbient_delta_low = 10
	drive_to_amnbient_delta_high = 15

	# USER DEFINED - DRIVE SPECIFIC - END

	# This is used to allow drive to reach ttr & ttp to avoid F2D failures in NetApp drives
	if ( $ANGEL.get_drive_info_hash( key: 'customer' ) ).to_s.upcase == 'NETAPP' ; ttr = 60 ; else ; ttr = 0 ; end

	$ANGEL.f_log( [ 'INFO' , 'TTR SET TO ' , ttr.to_s + "\n" ] )

	@firmware_download_count = 0

	voltage_margin_percentage = 10

	chamber_temp_ambient = 25

	drive_spec_3v_low_percent = -( voltage_margin_percentage.to_f * 0.01 )
	drive_spec_3v_high_percent = voltage_margin_percentage.to_f * 0.01

	drive_spec_12v_low_percent = -( voltage_margin_percentage.to_f * 0.01 )
	drive_spec_12v_high_percent = voltage_margin_percentage.to_f * 0.01

	chamber_temp_hot_level_1  = ( drive_spec_temp_high - drive_to_amnbient_delta_high )
	chamber_temp_hot_level_2  = ( drive_spec_temp_high - drive_to_amnbient_delta_high + 5 )

	chamber_temp_cold_level_1 = ( drive_spec_temp_low  - drive_to_amnbient_delta_low )
	chamber_temp_cold_level_2 = ( drive_spec_temp_low  - drive_to_amnbient_delta_low - 5 )

	voltage_12v_nominal     =  12.0
	voltage_12v_low         =  ( voltage_12v_nominal + ( voltage_12v_nominal * drive_spec_12v_low_percent  ) ).round(2)
	voltage_12v_high        =  ( voltage_12v_nominal + ( voltage_12v_nominal * drive_spec_12v_high_percent ) ).round(2)

	voltage_5v_nominal      =  3.3
	voltage_5v_low          =  ( voltage_5v_nominal + ( voltage_5v_nominal * drive_spec_3v_low_percent  ) ).round(2)
	voltage_5v_high         =  ( voltage_5v_nominal + ( voltage_5v_nominal * drive_spec_3v_high_percent ) ).round(2)

	ramp_time_1 = ( ( chamber_temp_hot_level_1 - chamber_temp_ambient ) * 60 ).to_i
	ramp_time_2 = ( ( chamber_temp_hot_level_1 - chamber_temp_cold_level_1 ) * 60 ).to_i
	ramp_time_3 = ( ( chamber_temp_hot_level_2 - chamber_temp_cold_level_1 ) * 60 ).to_i
	ramp_time_4 = ( ( chamber_temp_hot_level_2 - chamber_temp_cold_level_2 ) * 60 ).to_i
	ramp_time_5 = ( ( chamber_temp_ambient - chamber_temp_cold_level_2 ) * 60 ).to_i

	$ANGEL.f_log( [ 'INFO' , 'RAMP-1' , chamber_temp_ambient.to_s      , chamber_temp_hot_level_1.to_s  , ramp_time_1.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-2' , chamber_temp_hot_level_1.to_s  , chamber_temp_cold_level_1.to_s , ramp_time_2.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-3' , chamber_temp_cold_level_1.to_s , chamber_temp_hot_level_2.to_s  , ramp_time_3.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-4' , chamber_temp_hot_level_2.to_s  , chamber_temp_cold_level_2.to_s , ramp_time_4.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-5' , chamber_temp_cold_level_2.to_s , chamber_temp_ambient.to_s      , ramp_time_5.to_s ] )

	$ANGEL.log()

	test_data = []

	test_data[ 0  ] = { :phase => 'precondition' , :download_count => 0 , temp: chamber_temp_ambient }
	test_data[ 1  ] = { :phase => 'soak' , :download_count => 200 , :voltage_5v => voltage_5v_high	  , :voltage_12v => voltage_12v_high	, :ttr => ttr }
	test_data[ 2  ] = { :phase => 'soak' , :download_count => 200 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal , :ttr => ttr }
	test_data[ 3  ] = { :phase => 'soak' , :download_count => 200 , :voltage_5v => voltage_5v_low	  , :voltage_12v => voltage_12v_low	, :ttr => ttr }
	test_data[ 4  ] = { :phase => 'ramp' , :download_count => 40  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ramp_time => ramp_time_1 , :temp => chamber_temp_hot_level_1  , :ttr => ttr }
	test_data[ 5  ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_high	  , :voltage_12v => voltage_12v_high	, :ttr => ttr }
	test_data[ 6  ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ttr => ttr }
	test_data[ 7  ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_low	  , :voltage_12v => voltage_12v_low	, :ttr => ttr }
	test_data[ 8  ] = { :phase => 'ramp' , :download_count => 40  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ramp_time => ramp_time_2 , :temp => chamber_temp_cold_level_1 , :ttr => ttr }
	test_data[ 9  ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_high	  , :voltage_12v => voltage_12v_high	, :ttr => ttr }
	test_data[ 10 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ttr => ttr }
	test_data[ 11 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_low	  , :voltage_12v => voltage_12v_low	, :ttr => ttr }
	test_data[ 12 ] = { :phase => 'ramp' , :download_count => 40  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ramp_time => ramp_time_3 , :temp => chamber_temp_hot_level_2  , :ttr => ttr }
	test_data[ 13 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_high	  , :voltage_12v => voltage_12v_high	, :ttr => ttr }
	test_data[ 14 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ttr => ttr }
	test_data[ 15 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_low	  , :voltage_12v => voltage_12v_low	, :ttr => ttr }
	test_data[ 16 ] = { :phase => 'ramp' , :download_count => 40  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ramp_time => ramp_time_4 , :temp => chamber_temp_cold_level_2 , :ttr => ttr }
	test_data[ 17 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_high	  , :voltage_12v => voltage_12v_high	, :ttr => ttr }
	test_data[ 18 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ttr => ttr }
	test_data[ 19 ] = { :phase => 'soak' , :download_count => 100 , :voltage_5v => voltage_5v_low	  , :voltage_12v => voltage_12v_low	, :ttr => ttr }
	test_data[ 20 ] = { :phase => 'ramp' , :download_count => 40  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal	, :ramp_time => ramp_time_5 , :temp => chamber_temp_ambient , :ttr => ttr }
	test_data[ 21 ] = { :phase => 'post' , :download_count => 0 , :temp => chamber_temp_ambient }

	$ANGEL.sync( type: 'drives' )

	start_loop.upto( ( test_data.count - 1 ) ) do |loop_counter|

		next unless loop_counter >= start_loop

		$ANGEL.f_log( [ 'INFO' , 'TEST PHASE ' + loop_counter.to_s , test_data[ loop_counter ][ :phase ].to_s.upcase , test_data[ loop_counter ][ :download_count ].to_s + "\n" ] )

		start_test_phase( test_data[ loop_counter ] )

		$ANGEL.inspector_upload()
	end

	$ANGEL.post_script_handler
end

main()
