/* 
 * CIS 240 HW 9: LC4 Simulator
 * ctrl.h - defines struct and declares functions for control signals
 */


/*
 * Struct within control_signals struct representing all mux control signals
 */
typedef struct{
    unsigned char pc_mux_ctl;
    unsigned char rs_mux_ctl;
    unsigned char rt_mux_ctl;
    unsigned char rd_mux_ctl;
    unsigned char reg_input_mux_ctl;
    unsigned char arith_mux_ctl;
    unsigned char logic_mux_ctl;
    unsigned char alu_mux_ctl;
} muxes_ctl;
/*
 * Struct representing non-mux control signals, holds a struct representing all mux control signals
 */
typedef struct {
    
    muxes_ctl muxes;
    unsigned char reg_file_we;
    unsigned char arith_ctl;
    unsigned char logic_ctl;
    unsigned char shift_ctl;
    unsigned char const_ctl;
    unsigned char cmp_ctl;
    unsigned char nzp_we;
    unsigned char data_we;
    
} control_signals;


/*
 * Decodes instruction and sets control signals accordingly.
 * Params: pointer to control signals struct, instruction to decode.
 */
void decode(control_signals* control, unsigned short int I);

/*
 * Resets all control signals to 0.
 * Param: pointer to control signals struct.
 */
void clear_signals(control_signals* control);

