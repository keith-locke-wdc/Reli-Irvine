
VERSION = 3.3

def pre( pwr_5v_nominal: nil , pwr_5v_high: nil , pwr_5v_low: nil , pwr_12v_nominal: nil , pwr_12v_high: nil , pwr_12v_low: nil , temp: nil , ramp_time: nil , ttr: 0 )

	$ANGEL.set_chamber_temp( temp: 25 , time_limit: 0 , sync: true )

	$ANGEL.precondition()

	$ANGEL.baseline()

	$ANGEL.f_log( [ 'INFO' , 'TEST PHASE PRE-1' , 'SOAK-1' + "\n" ] )

	soak( pwr_5v: pwr_5v_nominal , pwr_12v: pwr_12v_nominal , runtime: 3600 , ttr: ttr )

	$ANGEL.f_log( [ 'INFO' , 'TEST PHASE PRE-2' , 'SOAK-2' + "\n" ] )

	soak( pwr_5v: pwr_5v_high , pwr_12v: pwr_12v_high , runtime: 3600 , ttr: ttr )

	$ANGEL.f_log( [ 'INFO' , 'TEST PHASE PRE-3' , 'SOAK-3' + "\n" ] )

	soak( pwr_5v: pwr_5v_low , pwr_12v: pwr_12v_low , runtime: 3600 , ttr: ttr )

	$ANGEL.f_log( [ 'INFO' , 'TEST PHASE PRE-4' , 'HALF-RAMP' , temp.to_s + "\n" ] )

	$ANGEL.set_chamber_temp( temp: temp , time_limit: ramp_time , sync: true )
end

def soak( pwr_5v: nil , pwr_12v: nil , runtime: 3600 , ttr: 0 , workload: 'jedec' )

	$ANGEL.sync( type: 'drives' )

	soak_start_time = Time.now

	loop do
		$ANGEL.power_cycle( pwr_5v: pwr_5v , pwr_12v: pwr_12v , ttr: ttr , unsafe: false , sync: true )

		break if Time.now >= ( soak_start_time + runtime )

		$ANGEL.rgt_workload_1()

		break if Time.now >= ( soak_start_time + runtime )

		$ANGEL.rgt_workload_2()

		break if Time.now >= ( soak_start_time + runtime )

		$ANGEL.rgt_workload_3()

		break if Time.now >= ( soak_start_time + runtime )

		$ANGEL.rgt_workload_4()

		break if Time.now >= ( soak_start_time + runtime )

		$ANGEL.power_cycle( pwr_5v: pwr_5v , pwr_12v: pwr_12v , ttr: ttr , unsafe: true , sync: true )

		break if Time.now >= ( soak_start_time + runtime )

		jedec_start_time = Time.now

		$ANGEL.io_tracker( tag: 'WL-5' )

		loop do
			if workload == 'jedec'

				$ANGEL.timed_jedec_219_workload( runtime: 300 , write_percentage: 50 , queue_depth: 32 )

			elsif workload == 'random'

				$ANGEL.timed_aligned_random_w_r( runtime: 300 , compare: true , alignment: 16384 )
			end

			break if Time.now >= ( ( soak_start_time + runtime ) || ( jedec_start_time + 1700 ) )
		end

		$ANGEL.io_tracker( tag: 'WL-5' )

		break if Time.now >= ( soak_start_time + runtime )
	end

	$ANGEL.sync( type: 'drives' )

	$ANGEL.inspector_upload()
end

def ramp( pwr_5v: 3.3 , pwr_12v: 12.0 , temp: nil , ramp_time: nil , ttr: 0 )

	$ANGEL.power_cycle( pwr_5v: pwr_5v , pwr_12v: pwr_12v , ttr: ttr , unsafe: false , sync: true )

	( start_lba , end_lba ) = $ANGEL.rgt_workload_6()

	$ANGEL.set_chamber_temp( temp: temp , time_limit: ramp_time , sync: true )

	$ANGEL.rgt_workload_7( start_lba: start_lba , end_lba: end_lba )

	$ANGEL.sync( type: 'drives' )

	$ANGEL.inspector_upload()
end

def main()

	$ANGEL.pre_script_handler()

	# USER DEFINED - DRIVE SPECIFIC - START

	runtime = 1000

	# jedec or random ( for 16K UI )
	workload = 'jedec'

	drive_spec_temp_low = 0

	drive_spec_temp_high = 70

	drive_to_amnbient_delta_low = 5
	drive_to_amnbient_delta_high = 15

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

	chamber_temp_hot = ( drive_spec_temp_high - drive_to_amnbient_delta_high ) 

	chamber_temp_cold = ( drive_spec_temp_low  - drive_to_amnbient_delta_low )

	pwr_12v_nominal	= 12.0
	pwr_12v_low	= ( pwr_12v_nominal + ( pwr_12v_nominal * drive_spec_12v_low_percent  ) ).round(2)
	pwr_12v_high	= ( pwr_12v_nominal + ( pwr_12v_nominal * drive_spec_12v_high_percent ) ).round(2)

	pwr_5v_nominal	= 3.3
	pwr_5v_low	= ( pwr_5v_nominal + ( pwr_5v_nominal * drive_spec_3v_low_percent  ) ).round(2)
	pwr_5v_high	= ( pwr_5v_nominal + ( pwr_5v_nominal * drive_spec_3v_high_percent ) ).round(2)

	pre( pwr_5v_nominal: pwr_5v_nominal , pwr_5v_high: pwr_5v_high , pwr_5v_low: pwr_5v_low , pwr_12v_nominal: pwr_12v_nominal , pwr_12v_high: pwr_12v_high , pwr_12v_low: pwr_12v_low , temp: chamber_temp_cold , ramp_time: ( ( chamber_temp_ambient - chamber_temp_cold ) * 60 ).to_i , ttr: ttr )

	ramp_time = ( ( chamber_temp_hot - chamber_temp_cold ) * 60 ).to_i

	$ANGEL.f_log( [ 'INFO' , 'RAMP TIME' , ramp_time.to_s + "\n" ] )

	io_runtime = 720 * 60

	start_time = Time.now

	loop_counter = 0

	phase_counter = 0

	loop do
		loop_counter += 1

		$ANGEL.io_tracker( tag: 'LOOP-' + loop_counter.to_s )

		1.upto( 4 ) do |soak_counter|

			phase_counter += 1

			if phase_counter.odd? ; pwr_5v = pwr_5v_high ; pwr_12v = pwr_12v_high ; else ; pwr_5v = pwr_5v_low ; pwr_12v = pwr_12v_low ; end

			$ANGEL.f_log( [ 'INFO' , 'TEST PHASE ' + phase_counter.to_s , 'SOAK-' + soak_counter.to_s , io_runtime.to_s , pwr_5v.to_s , pwr_12v.to_s + "\n" ] )

			soak( pwr_5v: pwr_5v , pwr_12v: pwr_12v , runtime: io_runtime , ttr: ttr , workload: workload )

			$angel.check_instruction

			if Time.now >= ( start_time + ( runtime * 3600 ) ) ; break ; end
		end

		phase_counter += 1

		if Time.now >= ( start_time + ( runtime * 3600 ) ) ; break ; end

		if loop_counter.odd? ; temp = chamber_temp_hot ; temp_text = 'HOT' ; else ; temp = chamber_temp_cold ; temp_text = 'COLD' ; end

		$ANGEL.log( 'TEMP : ' + temp.to_s + "\n" )

		$ANGEL.f_log( [ 'INFO' , 'TEST PHASE ' + phase_counter.to_s , 'RAMP-' + loop_counter.to_s , temp_text.to_s + "\n" ] )

		ramp( pwr_5v: pwr_5v_nominal , pwr_12v: pwr_12v_nominal , temp: temp , ramp_time: ramp_time , ttr: ttr )

		if Time.now >= ( start_time + ( runtime * 3600 ) ) ; break ; end

		$ANGEL.io_tracker( tag: 'LOOP-' + loop_counter.to_s )

		$angel.check_instruction
	end

	$ANGEL.set_chamber_temp( temp: 25 , time_limit: 0 , sync: true )

	$ANGEL.post_script_handler
end

main()
