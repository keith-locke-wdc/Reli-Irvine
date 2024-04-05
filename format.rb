VERSION = 5.0

def main()

	$ANGEL.pre_script_handler()

	# angel ( sends custom nvme commands via library ) or nvme-cli ( uses nvme-cli )
	# use nvme-cli for non-standard formats ( i.e. 4K + 64 )
	method = 'angel'

	# Required if using method 'angel'
	block_size = 512

	# Required if using method 'nvme-cli' ( example '-n 0xffffffff -l 4 -f -m 1' for 4K + 64 )
	options = '-n 0xffffffff -l 4 -f -m 1'

	# optional ( default: true )
	power_cycle = false

	if method == 'angel'

		$ANGEL.nvme_format( block_size: block_size , power_cycle: power_cycle )
	else
        	$ANGEL.format_nvme_cli( options: options.to_s , power_cycle: power_cycle )
	end

	$ANGEL.post_script_handler
end

main()
