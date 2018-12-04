set_property display_limit 1000000000 [current_wave_config]

add_wave_group w1_RAM
add_wave -into w1_RAM {{/neuralcore_tester/w1_ram_inst}} 

add_wave_group w2_RAM
add_wave -into w2_RAM {{/neuralcore_tester/w2_ram_inst}} 

add_wave_group w3_RAM
add_wave -into w3_RAM {{/neuralcore_tester/w3_ram_inst}} 


add_wave_group b1_RAM
add_wave -into b1_RAM {{/neuralcore_tester/b1_ram_inst}} 


add_wave_group b2_RAM
add_wave -into b2_RAM {{/neuralcore_tester/b2_ram_inst}} 


add_wave_group b3_RAM
add_wave -into b3_RAM {{/neuralcore_tester/b3_ram_inst}} 
