set_property SRC_FILE_INFO {cfile:c:/Users/lenovo/Desktop/blue/blue.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../blue.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:instance_name/inst} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/lenovo/Desktop/blue/blue.srcs/constrs_1/new/uart_top.xdc rfile:../blue.srcs/constrs_1/new/uart_top.xdc id:2} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
set_property src_info {type:XDC file:2 line:28 export:INPUT save:INPUT read:READ} [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
