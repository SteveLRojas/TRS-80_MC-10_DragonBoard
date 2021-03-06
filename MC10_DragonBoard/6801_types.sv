`ifndef TYPES6801
`define TYPES6801
localparam SBIT = 7;
localparam XBIT = 6;
localparam HBIT = 5;
localparam IBIT = 4;
localparam NBIT = 3;
localparam ZBIT = 2;
localparam VBIT = 1;
localparam CBIT = 0;

typedef enum logic[5:0] {reset_state, fetch_state, decode_state,
                       extended_state, indexed_state, read8_state, read16_state, immediate16_state,
	                    write8_state, write16_state,
						     execute_state, halt_state, error_state,
						     mul_state, mulea_state, muld_state,
						     mul0_state, mul1_state, mul2_state, mul3_state,
						     mul4_state, mul5_state, mul6_state, mul7_state,
							  jmp_state, jsr_state, jsr1_state,
						     branch_state, bsr_state, bsr1_state, 
							  rts_hi_state, rts_lo_state,
							  int_pcl_state, int_pch_state,
						     int_ixl_state, int_ixh_state,
						     int_cc_state, int_acca_state, int_accb_state,
						     int_wai_state, int_mask_state,
						     rti_state, rti_cc_state, rti_acca_state, rti_accb_state,
						     rti_ixl_state, rti_ixh_state,
						     rti_pcl_state, rti_pch_state,
							  pula_state, psha_state, pulb_state, pshb_state,
						     pulx_lo_state, pulx_hi_state, pshx_lo_state, pshx_hi_state,
							  vect_lo_state, vect_hi_state } state_type;
typedef enum logic[5:0] {idle_ad, fetch_ad, read_ad, write_ad, push_ad, pull_ad, int_hi_ad, int_lo_ad } addr_type;
typedef enum logic[5:0] {md_lo_dout, md_hi_dout, acca_dout, accb_dout, ix_lo_dout, ix_hi_dout, cc_dout, pc_lo_dout, pc_hi_dout} dout_type;
typedef enum logic[2:0] {reset_op, fetch_op, latch_op } op_type;
typedef enum logic[5:0] {reset_acca, load_acca, load_hi_acca, pull_acca, latch_acca } acca_type;
typedef enum logic[5:0] {reset_accb, load_accb, pull_accb, latch_accb } accb_type;
typedef enum logic[5:0] {reset_cc, load_cc, pull_cc, latch_cc } cc_type;
typedef enum logic[5:0] {reset_ix, load_ix, pull_lo_ix, pull_hi_ix, latch_ix } ix_type;
typedef enum logic[5:0] {latch_sp, load_sp} sp_type;
typedef enum logic[5:0] {reset_pc, latch_pc, load_ea_pc, add_ea_pc, pull_lo_pc, pull_hi_pc, inc_pc } pc_type;
typedef enum logic[5:0] {reset_md, latch_md, load_md, fetch_first_md, fetch_next_md, shiftl_md } md_type;
typedef enum logic[5:0] {reset_ea, latch_ea, add_ix_ea, load_accb_ea, inc_ea, fetch_first_ea, fetch_next_ea } ea_type;
typedef enum logic[5:0] {reset_iv, latch_iv, swi_iv, nmi_iv, irq_iv, icf_iv, ocf_iv, tof_iv, sci_iv } iv_type;
typedef enum logic[5:0] {reset_nmi, set_nmi, latch_nmi } nmi_type;
typedef enum logic[5:0] {acca_left, accb_left, accd_left, md_left, ix_left, sp_left } left_type;
typedef enum logic[5:0] {md_right, zero_right, plus_one_right, accb_right } right_type;
typedef enum logic[5:0] {alu_add8, alu_sub8, alu_add16, alu_sub16, alu_adc, alu_sbc, 
                       alu_and, alu_ora, alu_eor,
                       alu_tst, alu_inc, alu_dec, alu_clr, alu_neg, alu_com,
							  alu_inx, alu_dex,
						     alu_lsr16, alu_lsl16,
						     alu_ror8, alu_rol8,
						     alu_asr8, alu_asl8, alu_lsr8,
						     alu_sei, alu_cli, alu_sec, alu_clc, alu_sev, alu_clv, alu_tpa, alu_tap,
						     alu_ld8, alu_st8, alu_ld16, alu_st16, alu_nop, alu_daa } alu_type;
`endif