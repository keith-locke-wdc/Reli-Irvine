VERSION = 10.5

def main()

	$ANGEL.pre_script_handler()

	# USER DEFINED - DRIVE SPECIFIC - START

	format_block_size = 4096

	# USER DEFINED - DRIVE SPECIFIC - END

	$ANGEL.set_chamber_temp( temp: 25 , time_limit: 0 , sync: true )

	case $test_info.port.to_i

		when 1 , 6  ; $ANGEL.nvme_format( block_size: format_block_size , power_cycle: false )
		when 2 , 7  ; $ANGEL.baseline_workload_x( workload: 'IDLE-2' , runtime: 14400 , queue_depth: 64 , read: 50 , random: 100 , block_size: 64 )
		when 3 , 8  ; $ANGEL.f_log( [ 'INFO' , 'WL-IDLE-3' + "\n" ] ) ; $ANGEL.timed_jedec_219_workload( runtime: 14400 ) 
		when 4 , 9  ; $ANGEL.baseline_workload_x( workload: 'IDLE-4' , runtime: 14400 , queue_depth: 128 , read: 50 , random: 100 , block_size: 'random' )
		when 5 , 10 ; $ANGEL.f_log( [ 'INFO' , 'WL-IDLE-4' + "\n" ] ) ; $ANGEL.seq_w() ; $ANGEL.seq_w()
	end

	$ANGEL.sync( type: 'drives' )

	1.upto( 28 ) do |day|

		$ANGEL.f_log( [ 'INFO' , 'IDLE LOOP ' + day.to_s + "\n" ] )

		$ANGEL.get_parametric_data( log: true )

		$ANGEL.inspector_upload()

		$angel.wait( 'Hours' , 24 )
	end

	$ANGEL.sync( type: 'drives' )

	loop_count = 1

	0.step( 400 , 2 ) do |wait|

		$ANGEL.f_log( [ 'INFO' , 'POWER CYCLE LOOP ' + loop_count.to_s + "\n" ] )

		$ANGEL.power_off( check_status: false )

		$ANGEL.sync( type: 'drives' )

		$ANGEL.power_on()

		$ANGEL.f_log( [ 'INFO' , 'WAIT' , wait.to_s + " SECONDS\n" ] )

		$angel.wait( 'Seconds' , wait.to_i )

		$ANGEL.power_off( check_status: false )

		$ANGEL.sync( type: 'drives' )

		$ANGEL.power_on()

		$ANGEL.inspector_upload()

		$ANGEL.f_log( [ 'INFO' , 'WAIT' , "1 MINUTE\n" ] )

		$angel.wait( 'Minutes' , 1 )

		loop_count += 1
	end

	$ANGEL.post_script_handler
end

main()
