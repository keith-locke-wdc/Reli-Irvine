
VERSION = 5.0

def main()

	$ANGEL.pre_script_handler()

	firmware = 'LC703002'

	block_size = 4096

	# Wait time for dev-prep to complete ( use 300 if dev-prep process time is unknown )
	wait = 390

	# angel ( sends custom nvme commands via library ) or nvme-cli ( uses nvme-cli )
	method = 'nvme-cli'

	# This is only required if changing fw_customer_id ( i.e. MS to MT )
	fw_customer_id = 'NQ'

	$ANGEL.get_log_page_03h()

	if method == 'angel'

		$ANGEL.dev_prep_p( firmware: firmware , fw_customer_id: fw_customer_id , format: block_size , wait: wait )
	else
		$ANGEL.dev_prep_p_nvme_cli( firmware: firmware , fw_customer_id: fw_customer_id , format: block_size , wait: wait )
	end

	$ANGEL.get_log_page_03h()

	$ANGEL.post_script_handler
end

main()
