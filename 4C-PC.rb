
VERSION = 2.2

def _spl_power_cycles( power_cycle_count: nil , voltage_5v: 3.3 , voltage_12v: 12.0 , compare: true , ttr: 0 )

	return if power_cycle_count == 0 || power_cycle_count == nil || $ANGEL.get_test_info_hash( key: 'enable_power_control' ) == false

	1.upto( power_cycle_count ) do |power_cycles_completed|

		$ANGEL.spl_workload( pwr_5v: voltage_5v , pwr_12v: voltage_12v , ttr: ttr , spl_on: 60 , spl_off: 30 , compare: compare )

		if power_cycles_completed % 10 == 0 ; $ANGEL.inspector_upload() ; end
	end
end

def _graceful_power_cycles( power_cycle_count: nil , voltage_5v: 3.3 , voltage_12v: 12.0 , sleep: 10 , io_runtime: 10 , ttr: 0 )

	return if power_cycle_count == 0 || power_cycle_count == nil || $ANGEL.get_test_info_hash( key: 'enable_power_control' ) == false

	1.upto( power_cycle_count ) do |power_cycles_completed|

		$ANGEL.link_check()

		$ANGEL.assert( func: 'check' , log: false )

		$ANGEL.write_drive_log( data: 'POWER OFF : GRACEFUL' )

		$ANGEL.remove_device()

		$ANGEL.f_log( [ 'FUNC' , 'POWER OFF' , 'GRACEFUL' + "\n" ] )

		$power.off

		$ANGEL.sync( type: 'drives' )

		$angel.check_instruction

		$angel.wait( 'seconds' , sleep )

		$angel.check_instruction

		$ANGEL.power_on( pwr_5v: voltage_5v.to_f , pwr_12v: voltage_12v.to_f )

		sleep ttr.to_i

		$ANGEL.f_log( [ 'FUNC' , 'RANDOM' , 'BLOCK-W-R-C' , io_runtime.to_s + "\n" ] )

		$ANGEL.timed_random_block_w_r( runtime: io_runtime )

		$angel.check_instruction

		if power_cycles_completed % 10 == 0 ; $ANGEL.inspector_upload() ; end
	end
end

def pre()

	$ANGEL.sync( type: 'drives' )

	$ANGEL.precondition( set_temp: 25 )

	$ANGEL.baseline()

	$ANGEL.sync( type: 'drives' )
end

def start_test_phase( hash )

	if	hash[ :phase ] == 'ramp'

		$ANGEL.set_chamber_temp( temp: hash[ :temp ] , time_limit: hash[ :ramp_time ] , sync: true )

		_graceful_power_cycles( power_cycle_count: hash[ :safe_pc_count ] , voltage_5v: hash[ :voltage_5v ] , voltage_12v: hash[ :voltage_12v ] , ttr: hash[ :ttr ] )

		$ANGEL.sync( type: 'drives' )

		_spl_power_cycles( power_cycle_count: hash[ :unsafe_pc_count ] , voltage_5v: hash[ :voltage_5v ] , voltage_12v: hash[ :voltage_12v ] , ttr: hash[ :ttr ] )

		$ANGEL.sync( type: 'both' )

	elsif	hash[ :phase ] == 'soak'

		_graceful_power_cycles( power_cycle_count: hash[ :safe_pc_count ] , voltage_5v: hash[ :voltage_5v ] , voltage_12v: hash[ :voltage_12v ] , ttr: hash[ :ttr ] )

		$ANGEL.sync( type: 'drives' )

		_spl_power_cycles( power_cycle_count: hash[ :unsafe_pc_count ] , voltage_5v: hash[ :voltage_5v ] , voltage_12v: hash[ :voltage_12v ] , ttr: hash[ :ttr ] )

		$ANGEL.sync( type: 'drives' )
	end
end

def main()

	$ANGEL.pre_script_handler()

	# USER DEFINED - DRIVE SPECIFIC - START

	start_loop = 4

	drive_spec_temp_low = 0

	drive_spec_temp_high = 70

	drive_to_amnbient_delta_low = 5
	drive_to_amnbient_delta_high = 20

	# USER DEFINED - DRIVE SPECIFIC - END

	# This is used to allow drive to reach ttr & ttp to avoid F2D failures in NetApp drives
	if ( $ANGEL.get_drive_info_hash( key: 'customer' ) ).to_s.upcase == 'NETAPP' ; ttr = 60 ; else ; ttr = 0 ; end

	$ANGEL.f_log( [ 'INFO' , 'TTR SET TO ' , ttr.to_s + "\n" ] )

	voltage_margin_percentage = 10

	chamber_temp_ambient = 25

	drive_spec_3v_low_percent = -( voltage_margin_percentage.to_f * 0.01 )
	drive_spec_3v_high_percent = voltage_margin_percentage.to_f * 0.01

	drive_spec_12v_low_percent = -( voltage_margin_percentage.to_f * 0.01 )
	drive_spec_12v_high_percent = voltage_margin_percentage.to_f * 0.01

	chamber_temp_hot_level_1 = ( drive_spec_temp_high - drive_to_amnbient_delta_high ) 
	chamber_temp_hot_level_2 = ( drive_spec_temp_high - drive_to_amnbient_delta_high + 5 )

	chamber_temp_cold_level_1 = ( drive_spec_temp_low  - drive_to_amnbient_delta_low )
	chamber_temp_cold_level_2 = ( drive_spec_temp_low  - drive_to_amnbient_delta_low - 5 )

	voltage_12v_nominal	= 12.0
	voltage_12v_low		= ( voltage_12v_nominal + ( voltage_12v_nominal * drive_spec_12v_low_percent  ) ).round(2)
	voltage_12v_high	= ( voltage_12v_nominal + ( voltage_12v_nominal * drive_spec_12v_high_percent ) ).round(2)

	voltage_5v_nominal	= 3.3
	voltage_5v_low		= ( voltage_5v_nominal + ( voltage_5v_nominal * drive_spec_3v_low_percent  ) ).round(2)
	voltage_5v_high		= ( voltage_5v_nominal + ( voltage_5v_nominal * drive_spec_3v_high_percent ) ).round(2)

	ramp_time_1 = ( ( chamber_temp_hot_level_1 - chamber_temp_ambient ) * 60 ).to_i
	ramp_time_2 = ( ( chamber_temp_hot_level_1 - chamber_temp_cold_level_1 ) * 60 ).to_i
	ramp_time_3 = ( ( chamber_temp_hot_level_2 - chamber_temp_cold_level_1 ) * 60 ).to_i
	ramp_time_4 = ( ( chamber_temp_hot_level_2 - chamber_temp_cold_level_2 ) * 60 ).to_i
	ramp_time_5 = ( ( chamber_temp_ambient - chamber_temp_cold_level_2 ) * 60 ).to_i

	$ANGEL.f_log( [ 'INFO' , 'RAMP-1' , chamber_temp_ambient.to_s	   , chamber_temp_hot_level_1.to_s  , ramp_time_1.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-2' , chamber_temp_hot_level_1.to_s  , chamber_temp_cold_level_1.to_s , ramp_time_2.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-3' , chamber_temp_cold_level_1.to_s , chamber_temp_hot_level_2.to_s  , ramp_time_3.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-4' , chamber_temp_hot_level_2.to_s  , chamber_temp_cold_level_2.to_s , ramp_time_4.to_s ] )
	$ANGEL.f_log( [ 'INFO' , 'RAMP-5' , chamber_temp_cold_level_2.to_s , chamber_temp_ambient.to_s      , ramp_time_5.to_s ] )

	$ANGEL.log()

	pre()

	test_data = []

	test_data[ 1  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 350 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :temp => chamber_temp_ambient	, ttr: ttr }
	test_data[ 2  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 350 , :voltage_5v => voltage_5v_high    , :voltage_12v => voltage_12v_high	, :temp => chamber_temp_ambient	, ttr: ttr }
	test_data[ 3  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 350 , :voltage_5v => voltage_5v_low	   , :voltage_12v => voltage_12v_low	, :temp => chamber_temp_ambient	, ttr: ttr }
	test_data[ 4  ] = { :phase => 'ramp' , :safe_pc_count => 3   , :unsafe_pc_count => 3   , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :ramp_time => ramp_time_1 , :temp => chamber_temp_hot_level_1 , ttr: ttr }
	test_data[ 5  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :temp => chamber_temp_hot_level_1 , ttr: ttr }
	test_data[ 6  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_high	   , :voltage_12v => voltage_12v_high	, :temp => chamber_temp_hot_level_1 , ttr: ttr }
	test_data[ 7  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_low	   , :voltage_12v => voltage_12v_low	, :temp => chamber_temp_hot_level_1 , ttr: ttr }
	test_data[ 8  ] = { :phase => 'ramp' , :safe_pc_count => 15  , :unsafe_pc_count => 15  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :ramp_time => ramp_time_2 , :temp => chamber_temp_cold_level_1 , ttr: ttr }
	test_data[ 9  ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :temp => chamber_temp_cold_level_1 , ttr: ttr }
	test_data[ 10 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_high    , :voltage_12v => voltage_12v_high	, :temp => chamber_temp_cold_level_1 , ttr: ttr }
	test_data[ 11 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_low	   , :voltage_12v => voltage_12v_low	, :temp => chamber_temp_cold_level_1 , ttr: ttr }
	test_data[ 12 ] = { :phase => 'ramp' , :safe_pc_count => 15  , :unsafe_pc_count => 15  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :ramp_time => ramp_time_3 , :temp => chamber_temp_hot_level_2 , ttr: ttr }
	test_data[ 13 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :temp => chamber_temp_hot_level_2 , ttr: ttr }
	test_data[ 14 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_high	   , :voltage_12v => voltage_12v_high	, :temp => chamber_temp_hot_level_2 , ttr: ttr }
	test_data[ 15 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_low     , :voltage_12v => voltage_12v_low	, :temp => chamber_temp_hot_level_2 , ttr: ttr }
	test_data[ 16 ] = { :phase => 'ramp' , :safe_pc_count => 15  , :unsafe_pc_count => 15  , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :ramp_time => ramp_time_4 , :temp => chamber_temp_cold_level_2 , ttr: ttr }
	test_data[ 17 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :temp => chamber_temp_cold_level_2 , ttr: ttr }
	test_data[ 18 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_high	   , :voltage_12v => voltage_12v_high	, :temp => chamber_temp_cold_level_2 , ttr: ttr }
	test_data[ 19 ] = { :phase => 'soak' , :safe_pc_count => 350 , :unsafe_pc_count => 250 , :voltage_5v => voltage_5v_low     , :voltage_12v => voltage_12v_low	, :temp => chamber_temp_cold_level_2 , ttr: ttr }
	test_data[ 20 ] = { :phase => 'ramp' , :safe_pc_count => 5   , :unsafe_pc_count => 5   , :voltage_5v => voltage_5v_nominal , :voltage_12v => voltage_12v_nominal, :ramp_time => ramp_time_5 , :temp => chamber_temp_ambient , ttr: ttr }

	start_loop.upto( ( test_data.count - 1 ) ) do |loop_counter|

		next unless loop_counter >= start_loop

		$test_status.current_test_case=test_data[ loop_counter ][ :phase ].to_s.upcase + '-' + loop_counter.to_s

		pc_count = test_data[ loop_counter ][ :safe_pc_count ] + test_data[ loop_counter ][ :unsafe_pc_count ]

		$ANGEL.f_log( [ 'INFO' , 'TEST PHASE ' + loop_counter.to_s , test_data[ loop_counter ][ :phase ].to_s.upcase , pc_count.to_s + "\n" ] )

		start_test_phase( test_data[ loop_counter ] )

		$ANGEL.inspector_upload()
	end

	$ANGEL.post_script_handler
end

main()
