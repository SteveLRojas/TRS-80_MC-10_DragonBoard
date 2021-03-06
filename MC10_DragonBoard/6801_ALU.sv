module ALU6801(
			input alu_type alu_ctrl,
			input logic[7:0] cc,
			output logic[7:0] cc_out,
			input logic[15:0] left, right,
			output logic[15:0] out_alu);
logic valid_lo, valid_hi;
logic carry_in;
logic[7:0] daa_reg;
always_comb
begin

  case (alu_ctrl)
  	 alu_adc, alu_sbc,
  	      alu_rol8, alu_ror8:
	   carry_in = cc[CBIT];
  	 default:
	   carry_in = 1'b0;
  endcase

  valid_lo = (left[3:0] <= 9);
  valid_hi = (left[7:4] <= 9);

if (cc[CBIT] == 1'b0)
begin
	if( cc[HBIT] == 1'b1 )
	begin
		if (valid_hi)
			daa_reg = 8'b00000110;
		else
			daa_reg = 8'b01100110;
	end
	else
	begin
		if (valid_lo)
		begin
			if (valid_hi)
				daa_reg = 8'b00000000;
			else
				daa_reg = 8'b01100000;
		end
		else
		begin
			if( left[7:4] <= 8 )
				daa_reg = 8'b00000110;
			else
				daa_reg = 8'b01100110;
		end
	end
end
else
begin
	if ( cc[HBIT] == 1'b1 )
		daa_reg = 8'b01100110;
	else
		if (valid_lo)
			daa_reg = 8'b01100000;
	   else
			daa_reg = 8'b01100110;
end

  case (alu_ctrl)
  	 alu_add8, alu_inc, alu_add16, alu_inx, alu_adc:
		out_alu = left + right + {15'b000000000000000, carry_in};
  	 alu_sub8, alu_dec, alu_sub16, alu_dex, alu_sbc:
	   out_alu = left - right - {15'b000000000000000, carry_in};
  	 alu_and:
	   out_alu   = left & right; 	// and/bit
  	 alu_ora:
	   out_alu   = left | right; 	// or
  	 alu_eor:
	   out_alu   = left ^ right; 	// eor/xor
  	 alu_lsl16, alu_asl8, alu_rol8:
	   out_alu   = {left[14:0], carry_in}; 	// rol8/asl8/lsl16
  	 alu_lsr16, alu_lsr8:
	   out_alu   = {carry_in, left[15:1]}; 	// lsr
  	 alu_ror8:
	   out_alu   = {8'b00000000, carry_in, left[7:1]}; 	// ror
  	 alu_asr8:
	   out_alu   = {8'b00000000, left[7], left[7:1]}; 	// asr
  	 alu_neg:
	   out_alu   = right - left; 	// neg (right=0)
  	 alu_com:
	   out_alu   = ~left;
  	 alu_clr, alu_ld8, alu_ld16:
	   out_alu   = right; 	         // clr, ld
	 alu_st8, alu_tst, alu_st16:
	   out_alu   = left;
	 alu_daa:
	   out_alu   = left + {8'b00000000, daa_reg};
	 alu_tpa:
	   out_alu = {8'b00000000, cc};
  	 default:
	   out_alu = left; // nop
    endcase

	 //
	 // carry bit
	 //
    case (alu_ctrl)
  	 alu_add8, alu_adc:
      cc_out[CBIT] = (left[7] & right[7]) | (left[7] & ~out_alu[7]) | (right[7] & ~out_alu[7]);
  	 alu_sub8, alu_sbc:
      cc_out[CBIT] = ((~left[7]) & right[7]) | ((~left[7]) & out_alu[7]) | (right[7] & out_alu[7]);
  	 alu_add16:
      cc_out[CBIT] = (left[15] & right[15]) | (left[15] & ~out_alu[15]) | (right[15] & ~out_alu[15]);
  	 alu_sub16:
      cc_out[CBIT] = ((~left[15]) & right[15]) | ((~left[15]) & out_alu[15]) | (right[15] & out_alu[15]);
	 alu_ror8 , alu_lsr16, alu_lsr8, alu_asr8:
	   cc_out[CBIT] = left[0];
	 alu_rol8, alu_asl8:
	   cc_out[CBIT] = left[7];
	 alu_lsl16:
	   cc_out[CBIT] = left[15];
	 alu_com:
	   cc_out[CBIT] = 1'b1;
	 alu_neg, alu_clr:
	   cc_out[CBIT] = out_alu[7] | out_alu[6] | out_alu[5] | out_alu[4] | out_alu[3] | out_alu[2] | out_alu[1] | out_alu[0]; 
    alu_daa:
		begin
			if ( daa_reg[7:4] == 4'b0110 )
				cc_out[CBIT] = 1'b1;
			else
				cc_out[CBIT] = 1'b0;
	   end
  	 alu_sec:
      cc_out[CBIT] = 1'b1;
  	 alu_clc, alu_tst:
      cc_out[CBIT] = 1'b0;
    alu_tap:
      cc_out[CBIT] = left[CBIT];
  	 default:
      cc_out[CBIT] = cc[CBIT];
    endcase
	 //
	 // Zero flag
	 //
    case (alu_ctrl)
  	 alu_add8 , alu_sub8 ,
	      alu_adc , alu_sbc ,
  	      alu_and , alu_ora , alu_eor ,
  	      alu_inc , alu_dec , 
			alu_neg , alu_com , alu_clr ,
			alu_rol8 , alu_ror8 , alu_asr8 , alu_asl8 , alu_lsr8 ,
		   alu_ld8  , alu_st8, alu_tst:
      cc_out[ZBIT] = ~( out_alu[7]  | out_alu[6]  | out_alu[5]  | out_alu[4]  |
	                        out_alu[3]  | out_alu[2]  | out_alu[1]  | out_alu[0] );
  	 alu_add16, alu_sub16,
  	      alu_lsl16, alu_lsr16,
  	      alu_inx, alu_dex,
		   alu_ld16, alu_st16:
      cc_out[ZBIT] = ~( out_alu[15] | out_alu[14] | out_alu[13] | out_alu[12] |
	                        out_alu[11] | out_alu[10] | out_alu[9]  | out_alu[8]  |
  	                        out_alu[7]  | out_alu[6]  | out_alu[5]  | out_alu[4]  |
	                        out_alu[3]  | out_alu[2]  | out_alu[1]  | out_alu[0] );
    alu_tap:
      cc_out[ZBIT] = left[ZBIT];
  	 default:
      cc_out[ZBIT] = cc[ZBIT];
    endcase

    //
	 // negative flag
	 //
    case (alu_ctrl)
  	 alu_add8, alu_sub8,
	      alu_adc, alu_sbc,
	      alu_and, alu_ora, alu_eor,
  	      alu_rol8, alu_ror8, alu_asr8, alu_asl8, alu_lsr8,
  	      alu_inc, alu_dec, alu_neg, alu_com, alu_clr,
			alu_ld8 , alu_st8, alu_tst:
      cc_out[NBIT] = out_alu[7];
	 alu_add16, alu_sub16,
	      alu_lsl16, alu_lsr16,
			alu_ld16, alu_st16:
		cc_out[NBIT] = out_alu[15];
    alu_tap:
      cc_out[NBIT] = left[NBIT];
  	 default:
      cc_out[NBIT] = cc[NBIT];
    endcase

    //
	 // Interrupt mask flag
    //
    case (alu_ctrl)
  	 alu_sei:
		cc_out[IBIT] = 1'b1;               // set interrupt mask
  	 alu_cli:
		cc_out[IBIT] = 1'b0;               // clear interrupt mask
	 alu_tap:
      cc_out[IBIT] = left[IBIT];
  	 default:
		cc_out[IBIT] = cc[IBIT];             // interrupt mask
    endcase

    //
    // Half Carry flag
	 //
    case (alu_ctrl)
  	 alu_add8, alu_adc:
      cc_out[HBIT] = (left[3] & right[3]) |
                     (right[3] & ~out_alu[3]) | 
                      (left[3] & ~out_alu[3]);
    alu_tap:
      cc_out[HBIT] = left[HBIT];
  	 default:
		cc_out[HBIT] = cc[HBIT];
    endcase

    //
    // Overflow flag
	 //
    case (alu_ctrl)
  	 alu_add8, alu_adc:
      cc_out[VBIT] = (left[7]  &      right[7]  & (~out_alu[7])) |
                 ((~left[7]) & (~right[7]) &      out_alu[7]);
	 alu_sub8, alu_sbc:
      cc_out[VBIT] = (left[7]  & (~right[7]) & (~out_alu[7])) |
                 ((~left[7]) &      right[7]  &      out_alu[7]);
  	 alu_add16:
      cc_out[VBIT] = (left[15]  &      right[15]  & (~out_alu[15])) |
                 ((~left[15]) & (~right[15]) &      out_alu[15]);
	 alu_sub16:
      cc_out[VBIT] = (left[15]  & (~right[15]) & (~out_alu[15])) |
                 ((~left[15]) &      right[15] &       out_alu[15]);
	 alu_inc:
	   cc_out[VBIT] = ((~left[7]) & left[6] & left[5] & left[4] &
		                      left[3]  & left[2] & left[1] & left[0]);
	 alu_dec, alu_neg:
	   cc_out[VBIT] = (left[7]  & (~left[6]) & (~left[5]) & (~left[4]) &
		            (~left[3]) & (~left[2]) & (~left[1]) & (~left[0]));
	 alu_asr8:
	   cc_out[VBIT] = left[0] ^ left[7];
	 alu_lsr8, alu_lsr16:
	   cc_out[VBIT] = left[0];
	 alu_ror8:
      cc_out[VBIT] = left[0] ^ cc[CBIT];
    alu_lsl16:
      cc_out[VBIT] = left[15] ^ left[14];
	 alu_rol8, alu_asl8:
      cc_out[VBIT] = left[7] ^ left[6];
    alu_tap:
      cc_out[VBIT] = left[VBIT];
	 alu_and, alu_ora, alu_eor, alu_com,
	      alu_st8, alu_tst, alu_st16, alu_ld8, alu_ld16,
		   alu_clv:
      cc_out[VBIT] = 1'b0;
    alu_sev:
	   cc_out[VBIT] = 1'b1;
  	 default:
		cc_out[VBIT] = cc[VBIT];
    endcase

	 case (alu_ctrl)
	 alu_tap:
	 begin
      cc_out[XBIT] = cc[XBIT] & left[XBIT];
      cc_out[SBIT] = left[SBIT];
	 end
	 default:
	 begin
      cc_out[XBIT] = cc[XBIT] & left[XBIT];
	   cc_out[SBIT] = cc[SBIT];
	 end
	 endcase
end
endmodule

module CC_6801(input logic clk, hold, input cc_type cc_ctrl, input logic[7:0] data_in, cc_out, output logic[7:0] cc);
always_ff @(posedge clk)
begin
    if (hold == 1'b1)
	   cc <= cc;
	 else
    case (cc_ctrl)
	 reset_cc:
	   cc <= 8'b11000000;
	 load_cc:
	   cc <= cc_out;
  	 pull_cc:
      cc <= data_in;
	 default:
//  latch_cc:
      cc <= cc;
    endcase
end
endmodule
