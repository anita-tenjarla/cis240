#include "ctrl.h"
#include "lc4.h" 
#include "object_files.h" 
#include <stdio.h> 

//take given instruction, turn into sext imm 
signed short int immediate(unsigned short int instruction, int shift) {
	unsigned short int rand, uimm ; 
	int msb ; 

	rand = 0xFFFF >> (16-shift) ;
	uimm = instruction & uimm ; 
	msb = uimm >> (shift-1) ; 
	
	if (msb == 1) {
		return (uimm | (0xFFF << shift)) ; 
	} else {
		return uimm & 0xFFF ; 
	} 
} 

//reset machien state as pennsim does
void reset(machine_state* state) {
	int i, j ; 

	state -> PC = 0x8200 ; 
	state -> PSR = 0x8002 ; 
	for (i = 0; i < 8; i++) {
		state -> R[i] = 0 ; 
	} 
	clear_signals(&(state -> control)) ; 
	for (j = 0 ; j <= 65536; j++) {
		state -> memory[i] = 0 ; 
	}
}

//update state function
int update_state(machine_state* state) {

	//define variables
	unsigned short int instruction, rdReg, opcode, psr, r7Val ; 
	signed short int imm6 ; 
	instruction = state -> memory [state -> PC] ;
        imm6 = instruction & 0x3F ;
        rdReg = (instruction >> 9) & 7 ;
        int i ; 

	//Check Error 1 : execute data section address as code
	if ((state -> PC <= 0xFFF) && (state -> PC >= 0xA000)) {
		printf("Error: Executing data section address as code") ; 
		return 1 ; 
	
	//Check Error 2 : reading or writing to code section as data
	} else if ((state -> control.muxes.reg_input_mux_ctl == 1 || 
		   state -> control.data_we == 1) && alu_mux(state) < 0x2000) {
		printf("Error: Reading or writing to code as data") ; 
		return 2 ; 

	//Check Error 3 : Privilege bit is 0 but accessing OS section address
	} else if (((state -> PSR >> 15) == 0)  && (state -> PC >= 0x8000)) {
		printf("Error: Check your privilege") ; 
		return 3 ; 
	} 

	//decode instructions
	decode(&(state -> control), instruction) ;  

	//implement store
	if (state -> control.data_we == 1) {
		state -> memory [(rs_mux(state) + imm6)] = rt_mux(state) ; 
	} 

	//implement rti
	opcode = instruction >> 12 ;
	psr = state -> PSR ; 
	r7Val = state -> R[7] ;
	if (opcode == 8) {
		state -> PSR = psr & 0x7FFF ;
		state -> PC = r7Val ; 
	} 

	//debugging code
	//printf("REG WRITE ENABLE: %x",state->control.reg_file_we) ; 
	//printf("RD REG: %d",rdReg) ; 
	//printf("reg_input_mux : %d", reg_input_mux(state, alu_mux(state)));
	
	////reg write enable (set rd)
	if (state -> control.reg_file_we == 1) {
		if (state -> control.muxes.rd_mux_ctl == 0) {
			state -> R[rdReg] = reg_input_mux(state, alu_mux(state)) ;
		} else if (state -> control.muxes.rd_mux_ctl == 1) {
			state -> R[7] = reg_input_mux(state, alu_mux(state)) ; 
		} else {
			printf("Error in reg input mux") ; 
		} 
	} 
	
	//update nzp bits
	if (state -> control.nzp_we == 1) {
		state -> PSR = state -> PSR & 0xFFF8 ; 
	} else if ((signed short int) state -> control.muxes.reg_input_mux_ctl == 0) {
		state -> PSR = state -> PSR | 0x2 ; 
	} else {
		state -> PSR = state -> PSR | 0x4 ; 	
	} 


	//update pc
	state -> PC = pc_mux(state, rs_mux(state)) ; 


	//if no errors, then just return 0
	return 0 ; 
}


unsigned short int rs_mux(machine_state* state) {
	
	unsigned short int I, opsix, opnine, regDrawer, regVal ; 
	unsigned char rsctl ;
 	
	//assign variables
	I = state -> memory[state -> PC] ; 
	opsix = (I >> 6) & 7 ; 		
	opnine = (I >> 9) & 7 ;
	rsctl = state -> control.muxes.rs_mux_ctl ; 
	
	//set rs mux ctl accordingly	
	if (rsctl == 0) {
		regDrawer = opsix ; 
		regVal = state -> R[regDrawer] ;  
	} else if (rsctl == 1) {
		regVal = 7 ; 
	} else if (rsctl == 2) {
		regDrawer = opnine ; 
		regVal = state -> R[regDrawer] ;  
	} 	
	return regVal ; 
}

unsigned short int rt_mux(machine_state* state) {
	
	unsigned short int I, optwo, opnine, regDrawer, regVal ; 
	unsigned char rtctl ; 
	
	I = state -> memory[state -> PC] ; 
	optwo = I & 7 ; 
	opnine = (I >> 9) & 7 ;
	rtctl = state -> control.muxes.rt_mux_ctl ; 
	
	if (rtctl == 0) {
		regDrawer = optwo ;
		regVal = state -> R[regDrawer] ;  
	} else if (rtctl == 1) {
		regDrawer = opnine ; 
		regVal = state -> R[regDrawer] ; 
	}  
	return regVal ; 
}

unsigned short int alu_mux(machine_state* state) {

	//define some variables
	unsigned short int I, arith_func, rsVal, rtVal, uimm4, uimm8, uimm7 ;
	unsigned char logic_ctl_val, logicmux_val, shift_val ; 
	unsigned char alu_val, arithmux_val, arith_ctl_val, const_val, cmp_val ;
	signed short int rdVal, imm5, imm9, imm7 ;  
	int i ; 

	//compute things
	alu_val = state -> control.muxes.alu_mux_ctl ; 
	I = state -> memory [state -> PC] ; 
	arith_ctl_val = state -> control.arith_ctl ; 
	arithmux_val = state -> control.muxes.arith_mux_ctl ; 
	imm5 = immediate(I, 5) ;  
	uimm4 = I & 15 ; 
	imm9 = immediate(I, 9) ;  
	uimm8 = I & 0xFF ; 
	imm7 = immediate(I, 7) ; 
	uimm7 = I & 0x7F ; 
	logic_ctl_val = state -> control.logic_ctl ; 
	logicmux_val = state -> control.muxes.logic_mux_ctl ; 	
	shift_val = state -> control.shift_ctl ; 
	const_val = state -> control.const_ctl ; 
	cmp_val = state -> control.cmp_ctl ; 

	//these are register vals
	rsVal = rs_mux(state) ; 
	rtVal = rt_mux(state) ; 

	//if arithmetic computation needed
	if (alu_val == 0) {
	
		//if arithmetic input is rt
		if (arithmux_val == 0) {
		
			//if regular add
			if (arith_ctl_val == 0) {
				rdVal = ((signed short int) rsVal) + ((signed short int) rtVal) ;
 
			//if multiplication
			} else if (arith_ctl_val == 1) {
				rdVal = rsVal * rtVal ;
 
			//if subtraction 
			} else if (arith_ctl_val == 2) {
				rdVal = ((signed short int) rsVal) - ((signed short int) rtVal) ; 

			//if division
			} else if (arith_ctl_val == 3) {
				if (rtVal == 0) {
					for (i = 0 ; i < 8 ; i++) {
						state -> R[i] = 0 ; 
					} 
				} else {
					rdVal = rsVal / rtVal ; 
				}
			//mod
			} else if (arith_func == 4) {
				if (rtVal == 0) {
					for (i = 0 ; i < 8 ; i++) {
						state -> R[i] = 0 ;
					} 
				} else {
					rdVal = rsVal % rtVal ;
				} 
			}

		//arithmetic sext imm5 input
		} else if (arithmux_val == 1) {
			
			//add imm5
			rdVal = ((signed short int) rsVal) + ((signed short int) imm5) ;
		} 

	//logical computation
	} else if (alu_val == 1) {

		//logical input is rt
		if (logicmux_val == 0) {
			
			//logical operation and
			if (logic_ctl_val == 0) {
				rdVal = rsVal & rtVal ; 
			
			//logical operation not
			} else if (logic_ctl_val == 1) {
				rdVal = ~rsVal ; 
			
			//logical or
			} else if (logic_ctl_val == 2) {	
				rdVal = rsVal | rtVal ; 
	
			//logical xor
			} else if (logic_ctl_val == 3) {
				rdVal = rsVal ^ rtVal ; 
			} 

		//logical input is sext imm5
		} else if (logicmux_val == 1) {

			//and with imm5
			rdVal = rsVal & imm5 ; 
		} 

	//shifter output
	} else if (alu_val == 2) {
		
		//SLL 
		if (shift_val == 0) {
			rdVal = rsVal << uimm4 ; 
		
		//SRA
		} else if (shift_val == 1) {
			rdVal = ((signed short int) rsVal) >> uimm4 ;
		
		//SRL 
		} else if (shift_val == 2) {	
			rdVal = rsVal >> uimm4 ; 
		} 

	//constants output
	} else if (alu_val == 3) {
	
		//const sextimm9
		if (const_val == 0) {
			rdVal = imm9 ; 

		//hiconst 
		} else if (const_val == 1) {	 
			rdVal = (rsVal & 0xFF) | (uimm8 << 8) ; 
		}

	//comparing output
	} else if (alu_val == 4) {
		
		//cmp
		if (cmp_val == 0) {
			rdVal = ((signed short int) rsVal) - ((signed short int) rtVal) ; 
			if (rdVal < 0) {
				rdVal = -1 ; 
			} else if (rdVal == 0) {
				rdVal = 0 ; 
			} else if (rdVal > 0) {
				rdVal = 1 ; 
			} 
		
		//cmpu
		} else if (cmp_val == 1) {
			rdVal = rsVal - rtVal ;
                        if (rdVal < 0) {
                                rdVal = -1 ;
                        } else if (rdVal == 0) {
                                rdVal = 0 ;
                        } else if (rdVal > 0) {
                                rdVal = 1 ;
                        }
		
		//cmpi
		} else if (cmp_val == 2) {
                        rdVal = ((signed short int)rsVal) - imm7 ;
                        if (rdVal < 0) {
                                rdVal = -1 ;
                        } else if (rdVal == 0) {
                                rdVal = 0 ;
                        } else if (rdVal > 0) {
                                rdVal = 1 ;
                        }
		//cmpiu
		} else if (cmp_val == 3) {
                        rdVal = rsVal - uimm7 ;
                        if (rdVal < 0) {
                                rdVal = -1 ;
                        } else if (rdVal == 0) {
                                rdVal = 0 ;
                        } else if (rdVal > 0) {
                                rdVal = 1 ;
                        }
		}
	}
	return rdVal ; 
}

unsigned short int reg_input_mux(machine_state* state, unsigned short int alu_out) {
	unsigned char reg_input_val ; 
	unsigned short int I, rsVal ; 
	signed short int imm6, rdVal ; 
	
	reg_input_val = state -> control.muxes.reg_input_mux_ctl ; 
	I = state -> memory [state -> PC] ;
	imm6 = 	immediate(I, 6) ;  
	rsVal = rs_mux(state) ; 

	//output alu out value
	if (reg_input_val == 0) {
		rdVal = alu_out ; 
	
	//output is data memory (ldr)
	} else if (reg_input_val == 1) {
		rdVal = state -> memory [((signed short int) rsVal) + imm6] ; 

	//output is pc + 1
	} else if (reg_input_val == 2) {
		rdVal = (state -> PC) + 1 ; 
	} 
	return rdVal ; 
}

unsigned short int pc_mux(machine_state* state, unsigned short int rs_out) {
	unsigned char pc_val ;
        unsigned short int I, returnVal, rsVal, uimm8, pc, cmpbits, psrbits ;
        signed short int imm11, imm9 ;

        pc_val = state -> control.muxes.pc_mux_ctl ;
        I = state -> memory [state -> PC] ;
	pc = state -> PC ; 
        imm11 =  immediate(I, 11) ; 
	imm9 = immediate(I, 9) ; 
	uimm8 = I & 0xFF ; 
	rsVal = rs_mux(state) ; 
	cmpbits = (I >> 9) & 7 ; 
	psrbits = (state -> PSR) & 7 ; 

	//output nzp stuff
	if (pc_val == 0) {
		if ((psrbits & cmpbits) > 0) {
			returnVal = pc + 1 + imm9 ; 
		} else if ((psrbits & cmpbits) == 0) {
			returnVal = pc + 1 ; 
		}
	
	//output is pc+1
	} else if (pc_val == 1) {
		returnVal = pc + 1 ; 
	
	//output is (pc+1)+imm11
	} else if (pc_val == 2) {
		returnVal = pc + imm11 ; 

	//output is rs
	} else if (pc_val == 3) {
		returnVal = rsVal ; 

	//output is (0x8000 | imm11 << 4) 
	} else if (pc_val == 4) {
		returnVal = (0x8000 | uimm8) ; 

	//output is (PC & 0x8000) | (imm11 << 4) 
	} else if (pc_val == 5) {
		returnVal = ((pc & 0x8000) | (imm11 << 4)) ; 
	} 
	return returnVal ; 
}

