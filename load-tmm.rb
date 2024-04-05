
VERSION = 5.0

$ANGEL.pre_script_handler()

# Requires the TMM file & TDD tmm_lut.bin to be in the launch directory
# unless overwrite_trim_file_value == 0 , requires TDD create_default_trim_reg_file.bin to be in the launch directory
# A power cycle is required to enable the new TMM
# overwrite_trim_file_value 2 is safe , overwrite_trim_file_value 1 may be necessary for some drives but will alter drive trim settings , overwrite_trim_file_value 0 skips this function
# DEFAULTS power_cycle: true , overwrite_trim_file_value: 0
$ANGEL.load_tmm( tmm: 'B5k_A.1.0' , power_cycle: true , overwrite_trim_file_value: 1 )

$ANGEL.post_script_handler()
