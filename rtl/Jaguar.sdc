# Core-local timing constraints for Jaguar_MiSTer.
#
# xvclk and tlw are clock-enable strobes derived from sys_clk inside
# rtl/Rework/jaguar.v. They are not real clocks and should not be modeled with
# create_clock/create_generated_clock. Apply multicycle exceptions only to
# small islands where both launch and capture registers are gated by the same
# strobe.
#
# Verified starter island:
#   rtl/Rework/jaguar.v beam position counters
#     beam_x[*], beam_y[*], prev_hs, prev_vs
# These registers are updated in a single posedge sys_clk block guarded by
# "else if (xvclk)" and feed the lightgun overlay.

set jaguar_xvclk_beam_regs [get_registers {
	*|beam_x[*]
	*|beam_y[*]
	*|prev_hs
	*|prev_vs
}]

if {[get_collection_size $jaguar_xvclk_beam_regs] > 0} {
	set_multicycle_path -setup 4 -from $jaguar_xvclk_beam_regs -to $jaguar_xvclk_beam_regs
	set_multicycle_path -hold 3 -from $jaguar_xvclk_beam_regs -to $jaguar_xvclk_beam_regs
}

# Template for future verified xvclk islands:
# set jaguar_xvclk_some_regs [get_registers {
# 	*|some_reg[*]
# }]
# if {[get_collection_size $jaguar_xvclk_some_regs] > 0} {
# 	set_multicycle_path -setup 4 -from $jaguar_xvclk_some_regs -to $jaguar_xvclk_some_regs
# 	set_multicycle_path -hold 3 -from $jaguar_xvclk_some_regs -to $jaguar_xvclk_some_regs
# }
#
# Do not blindly apply the same exception across mixed xvclk/tlw/sys_clk logic.
# In particular:
#   xvclk -> xvclk : candidate for setup 4 / hold 3
#   tlw   -> tlw   : candidate for setup 4 / hold 3
#   xvclk -> tlw   : different phase, not the same exception
#   tlw   -> xvclk : effectively near-single-cycle, do not relax by default
