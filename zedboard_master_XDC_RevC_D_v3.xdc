#  Notes:
# 
#  10 August 2012
#     IO standards based upon Bank 34 and Bank 35 Vcco supply options of 1.8V, 
#     2.5V, or 3.3V are possible based upon the Vadj jumper (J18) settings.  
#     By default, Vadj is expected to be set to 1.8V but if a different 
#     voltage is used for a particular design, then the corresponding IO 
#     standard within this UCF should also be updated to reflect the actual 
#     Vadj jumper selection.
# 
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {CLK}]; 
create_clock -period 20.000 -name CLK -waveform {0.000 10.000} [get_ports CLK]

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN T22 [get_ports {outpt[0]}];  
set_property PACKAGE_PIN T21 [get_ports {outpt[1]}];  
set_property PACKAGE_PIN U22 [get_ports {outpt[2]}];  
set_property PACKAGE_PIN U21 [get_ports {outpt[3]}];  
set_property PACKAGE_PIN V22 [get_ports {outpt[4]}];  
set_property PACKAGE_PIN W22 [get_ports {outpt[5]}]; 
set_property PACKAGE_PIN U19 [get_ports {outpt[6]}];  
set_property PACKAGE_PIN U14 [get_ports {RDY_outpt}];  

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN P16 [get_ports {RST_N}];  


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
