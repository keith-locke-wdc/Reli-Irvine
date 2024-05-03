
VERSION = 6.0

def main()

	$ANGEL.pre_script_handler()

	firmware = 'LH04000G'

	commit_action = 1

	# performs formmat if not nil
	block_size = nil

	# true , false , or number ( i.e. 2 )
	power_cycle = true

	# angel ( sends custom nvme commands via library ) or nvme-cli ( uses nvme-cli )
	method = 'nvme-cli'

	# Only available when using method 'nvme-cli'. Appends the user define option to the end of the nvme-cli command.
	nvme_cli_options = '-x 0x40000'

	# This is only required if changing fw_type ( i.e. MS to MT ) , otherwise set to nil
	fw_type = nil

	$ANGEL.get_log_page_03h()

	# Commit Actions
	# 0 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is not activated.
	# 1 Downloaded image replaces the existing image in the specified Firmware Slot. The newly placed image is activated at the next Controller Level Reset.
	# 2 The existing image in the specified Firmware Slot is activated at the next Controller Level Reset.
	# 3 Downloaded image replaces the existing image in the specified Firmware Slot and is then activated immediately.
	# - If there is not a newly downloaded image, then the existing image in the specified firmware slot is activated immediately.
	# DEFAULTS : firmware_slot: 1 , power_cycle: true , commit_action: 3

	if method == 'angel'

		$ANGEL.firmware_download( firmware: firmware , fw_type: fw_type , firmware_slot: nil , power_cycle: power_cycle , commit_action: commit_action )
	else
		$ANGEL.firmware_download_nvme_cli( firmware: firmware , fw_type: fw_type , firmware_slot: nil , power_cycle: power_cycle , commit_action: commit_action , options: nvme_cli_options )
	end

	$ANGEL.get_log_page_03h()

	unless block_size == nil ; $ANGEL.nvme_format( block_size: block_size ) ; end

	$ANGEL.post_script_handler
end

main()
