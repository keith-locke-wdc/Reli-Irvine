
VERSION = 1.0

def pre( temp: 25 , ramp_time: 0 , ttr: 0 )

	$ANGEL.sync( type: 'drives' )

	$ANGEL.precondition( set_temp: temp )

	$ANGEL.baseline()

	$ANGEL.sync( type: 'drives' )

	$ANGEL.set_chamber_temp( temp: temp , time_limit: ramp_time , sync: true )

	iops_limit = $ANGEL.get_iops_limit( runtime: 3600 )

	$ANGEL.sync( type: 'drives' )

	return iops_limit
end

# MS requires PC every hour , pc_per_hour is used to control PCs Per Hour
def run_io( ttr: 0 , pcs_per_hour: 0.5 , iops_limit: nil , workload: nil )

	$ANGEL.data_pattern( pattern: AngelCore::DataPattern_Random , log: true )

	$ANGEL.io_tracker( tag: 'SEQ-W-R-C' )
	
	$ANGEL.io_tracker( tag: 'SEQ-W-R-C-1' )

	# Reduced to 45 mins to keep cycle at 24 hours
	$ANGEL.timed_seq_w_r( runtime: 2940 , compare: true )

	$ANGEL.io_tracker( tag: 'SEQ-W-R-C-1' )

	if pcs_per_hour == 1 ; $ANGEL.power_cycle( pwr_5v: 3.3 , pwr_12v: 12.0 , ttr: ttr , unsafe: false , sync: true ) ; end

	$ANGEL.io_tracker( tag: 'SEQ-W-R-C-2' )

	# Reduced to 45 mins to keep cycle at 24 hours
	$ANGEL.timed_seq_w_r( runtime: 2940 , compare: true )

	$ANGEL.io_tracker( tag: 'SEQ-W-R-C-2' )

	$ANGEL.io_tracker( tag: 'SEQ-W-R-C' )

	$ANGEL.power_cycle( pwr_5v: 3.3 , pwr_12v: 12.0 , ttr: ttr , unsafe: false , sync: true )

	$ANGEL.enable_iops_control( limit: iops_limit , log: true )

	$ANGEL.io_tracker( tag: 'JEDEC' )

	pc_counter = 0

	1.upto( 22 ) do |loop_counter|

		if	workload == 'jedec'

			$ANGEL.io_tracker( tag: 'JEDEC-' + loop_counter.to_s )

			$ANGEL.timed_jedec_219_workload( runtime: 3600 , write_percentage: 50 , queue_depth: 32 , compare: false )

			$ANGEL.io_tracker( tag: 'JEDEC-' + loop_counter.to_s )

		elsif	workload == 'random'

			$ANGEL.io_tracker( tag: 'RANDOM-' + loop_counter.to_s )

			# KAL - Need to implement reduced max capacity
			$ANGEL.timed_aligned_random_w_r( runtime: 3600 , compare: true , alignment: 16384 )

			$ANGEL.io_tracker( tag: 'RANDOM-' + loop_counter.to_s )
		end

		if	loop_counter.even? || pcs_per_hour == 1

			pc_counter += 1

			if	pc_counter % 2 == 1

				$ANGEL.power_cycle( pwr_5v: 3.3 , pwr_12v: 12.0 , ttr: ttr , unsafe: false , sync: true )

			elsif	pc_counter % 2 == 0

				$ANGEL.power_cycle( pwr_5v: 3.3 , pwr_12v: 12.0 , ttr: ttr , unsafe: true , sync: true )
			end
		end
	end

	$ANGEL.io_tracker( tag: 'JEDEC' )

	$ANGEL.disable_iops_control( log: true )
end

def main()

	$ANGEL.pre_script_handler()

	# USER DEFINED - DRIVE SPECIFIC - START

	#jedec or random ( for 16K UI )
	workload = 'jedec'

	chamber_temp = 25

	# Runtime in days
	runtime = 3

	# USER DEFINED - DRIVE SPECIFIC - END

	# This is used to allow drive to reach ttr & ttp to avoid F2D failures in NetApp drives
	if ( $ANGEL.get_drive_info_hash( key: 'customer' ) ).to_s.upcase == 'NETAPP' ; ttr = 60 ; else ; ttr = 0 ; end

	# This is used to control the extra power cycles required by MS
	if ( $ANGEL.get_drive_info_hash( key: 'customer' ) ).to_s.upcase == 'MSFT' ; pcs_per_hour = 1.0 ; else ; pcs_per_hour = 0.5 ; end

	$ANGEL.f_log( [ 'INFO' , 'TTR SET TO ' , ttr.to_s + "\n" ] )

	iops_limit = pre( temp: chamber_temp , ramp_time: 0 , ttr: ttr )

	1.upto( runtime ) do |loop_counter|

		$ANGEL.io_tracker( tag: 'RDT-' + loop_counter.to_s , dwpd: true )

		run_io( ttr: ttr , pcs_per_hour: pcs_per_hour , iops_limit: iops_limit , workload: workload )

		$ANGEL.io_tracker( tag: 'RDT-' + loop_counter.to_s , dwpd: true )
	end

	$ANGEL.set_chamber_temp( temp: 25 , time_limit: 0 , sync: true )

	$ANGEL.post_script_handler
end

main()
