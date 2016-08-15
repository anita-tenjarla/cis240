#include "ctrl.h" 
#include "lc4.h" 
#include "object_files.h" 

void decode (control_signals* control, unsigned short int I) {

        unsigned short int opcode, opelev, opthree, opfour, opseven, opnine ;

        //opcodes and subopcodes needed
        opcode = I >> 12 ; //first 4 bits
        opelev = I >> 11 ; //first 5 bits
	opthree = (I >> 3) & 7 ; //bits 3 to 5 
	opfour = (I >> 4) & 3 ; //bits 4 to 5
	opseven = (I >> 7) & 3 ;  //bits 7 to 8
	opnine = I >> 9 ; //first 7 bits 

	//WRITE ENABLE ON : arithmetic, jsr, jsrr, logical, hiconst, trap
	if (opcode == 1 || opelev == 8 || opelev == 9 ||
 			opcode == 5 || opcode == 13 || opcode == 15) {
		control -> reg_file_we = 1 ; 
	//WRITE ENABLE OFF : otherwise
	} else {
		control -> reg_file_we = 0 ; 
	} 

	//ARITH_CTL 
	if (opcode == 1 && opthree == 0) {
		control -> arith_ctl = 0 ; 
	} else if (opcode == 1 && opthree == 1) {
		control -> arith_ctl = 1 ; 
	} else if (opcode == 1 && opthree == 2) {
		control -> arith_ctl = 2 ;
	} else if (opcode == 1 && opthree == 3) {
		control -> arith_ctl = 3 ;
	} else if (opcode == 10 && opthree >= 6) {
		control -> arith_ctl = 4 ;
	} 

	//LOGIC_CTL
	if ((opcode == 5 && opthree == 0) || (opcode == 5 && opthree >= 4)) {
		control -> logic_ctl = 0 ;
	} else if (opcode == 5 && opthree == 1) {
		control -> logic_ctl = 1 ; 
	} else if (opcode == 5 && opthree == 2) {
		control -> logic_ctl = 2 ;
	} else if (opcode == 5 && opthree == 3) {
		control -> logic_ctl = 3 ; 
	} ; 

	//SHIFT_CTL 
	if (opcode == 10 && opfour == 0) {
		control -> shift_ctl = 0 ; 
	} else if (opcode == 10 && opfour == 1) {
		control -> shift_ctl = 1 ; 
	} else if (opcode == 10 && opfour == 2) {
		control -> shift_ctl = 2 ;
	} ; 

	//CONST_CTL 
	if (opcode == 9) {
		control -> const_ctl = 0 ; 
	} else if (opcode == 13) {
		control -> const_ctl = 1 ; 
	} ; 

	//CMP_CTL
	if (opcode == 2 && opseven == 0) {
		control -> cmp_ctl = 0 ; 
	} else if (opcode == 2 && opseven == 1) {
		control -> cmp_ctl = 1 ; 
	} else if (opcode == 2 && opseven == 2) {
		control -> cmp_ctl = 2 ; 
	} else if (opcode == 2 && opseven == 3) {
		control -> cmp_ctl = 3 ; 
	} ; 

	//NZP_WE is 0 for 
	if (opcode == 0 || opcode == 7 || opcode == 8 || opelev == 24 || opelev == 25) {
		control -> nzp_we = 0 ; 
	} else {
		control -> nzp_we = 1 ; 
	} 

	//DATA_WE
	if (opcode == 7) {
		control -> data_we = 1 ; 
	} else {
		control -> data_we = 0 ; 
	}  

	//PC_MUX_CTL 
	if (opnine == 0) { //NOP
		control -> muxes.pc_mux_ctl = 1 ; 
	} else if (opnine >= 1 && opnine <= 7) {   //branch
		control -> muxes.pc_mux_ctl = 0 ; 
	} else if (opelev == 25) {
		control -> muxes.pc_mux_ctl = 2 ; 	
	} else if (opelev == 8 || opelev == 24) {
		control -> muxes.pc_mux_ctl = 3 ; 
	} else if (opcode == 15) {
		control -> muxes.pc_mux_ctl = 4 ; 
	} else if (opelev == 9) {
		control -> muxes.pc_mux_ctl = 5 ; 
	} else {
		control -> muxes.pc_mux_ctl = 1 ; 
	} 

	//RS_MUX_CTL 
	//arithmetic operations, logical operators, ldr, store, shift are 0
        if (opcode == 1 || opcode == 5 || opcode == 6 || opcode == 7 || opcode == 10) {
                control -> muxes.rs_mux_ctl = 0 ;

        //comparators are 2
        } else if (opcode == 2) {
                control -> muxes.rs_mux_ctl = 2 ;

        //NOT SURE IF RIGHT trap, jsr are 1
        } else if (opcode == 15 || opcode == 4) {
                control -> muxes.rs_mux_ctl = 1 ;
        }

        //jmpr and jsrr are 0
        //check opcodes of bit size 5
        else if (opelev == 8 || opelev == 24) {
                control -> muxes.rs_mux_ctl = 0 ;
	} ; 

	//RT_MUX_CTL 
	//arithmetic outputs
        if (opcode == 1 && opthree < 4) {
                control -> muxes.rt_mux_ctl = 0 ;

        //comparators (cmp and cmpu)
        } else if (opcode == 2 && opseven < 2) {
                control -> muxes.rt_mux_ctl = 0 ;

        //logical operators and or xor
        } else if (opcode == 5 && (opthree == 0 || opthree == 2 || opthree == 3)) {
                control -> muxes.rt_mux_ctl = 0 ;

        //mod operator
        } else if (opcode == 10 && opfour == 3) {
                control -> muxes.rt_mux_ctl = 0 ;

        //store
        } else if (opcode == 7) {
                control -> muxes.rt_mux_ctl = 1 ;
	} ; 

	//RD_MUX = 1 for trap, jsr
	if (opcode == 1 || opcode == 5 || opcode == 6 || opcode == 9 || opcode == 10 || 
			opcode == 13) {
		control -> muxes.rd_mux_ctl = 0 ; 
	} else if (opcode == 15 || opelev == 9) {
		control -> muxes.rd_mux_ctl = 1 ; 	
	} ; 

	//REG_INPUT_MUX
	if (opcode == 1 || opcode == 2 || opcode == 5 || opcode == 9 || opcode == 10 || 
			opcode == 13) {
        	control -> muxes.reg_input_mux_ctl = 0 ;

        //output of data memory (ldr)
        } else if (opcode == 7) {
                control -> muxes.reg_input_mux_ctl = 1 ;

        //jsr, jsrr, trap
        } else if (opcode == 15 || opelev == 8 || opelev == 9) {
                control -> muxes.reg_input_mux_ctl = 2 ;
	} ; 

	//ARITH_MUX_CTL
	if (opcode == 1 && (opthree >= 0 && opthree <= 3)) {
                control -> muxes.arith_mux_ctl = 0 ;
	} else if ((opcode == 1 && opthree >= 4) || (opcode == 5 && opthree >= 4)) {
		control -> muxes.arith_mux_ctl = 1 ;
	} else if (opcode == 6 || opcode == 7) {
		control -> muxes.arith_mux_ctl = 2 ; 
	} ; 

	//LOGIC_MUX_CTL
	if (opcode == 5 && (opthree >= 0 && opthree <= 3)) {
		control -> muxes.logic_mux_ctl = 0 ; 
	} else if (opcode == 5 && opthree >= 4) {
		control -> muxes.logic_mux_ctl = 1 ; 
	} ; 

	//ALU_MUX_CTL
	if (opcode == 1) {
		control -> muxes.alu_mux_ctl = 0 ; 
	} else if (opcode == 5) {
		control -> muxes.alu_mux_ctl = 1 ; 
	} else if (opcode == 10 && (opfour >= 0 && opfour <= 2)) {
		control -> muxes.alu_mux_ctl = 2 ; 
	} else if (opcode == 9 || opcode == 13) {
		control -> muxes.alu_mux_ctl = 3 ; 
	} else if (opcode == 2) {
		control -> muxes.alu_mux_ctl = 4 ; 
	} ;  	
}

void clear_signals(control_signals* control) {
	control -> reg_file_we = 0 ; 
	control -> arith_ctl = 0 ; 
	control -> logic_ctl = 0 ; 
	control -> shift_ctl = 0; 
	control -> const_ctl = 0; 
	control -> cmp_ctl = 0; 
	control -> nzp_we = 0;
	control -> data_we = 0 ; 
	
	control -> muxes.pc_mux_ctl = 0 ; 
	control -> muxes.rs_mux_ctl = 0 ;
	control -> muxes.rt_mux_ctl = 0 ;
	control -> muxes.rd_mux_ctl = 0 ;
	control -> muxes.reg_input_mux_ctl = 0 ;
	control -> muxes.arith_mux_ctl = 0 ;
	control -> muxes.logic_mux_ctl = 0 ;
	control -> muxes.alu_mux_ctl = 0 ;
}
