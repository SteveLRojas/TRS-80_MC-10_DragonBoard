module MC10(
		input logic RST,
		input logic Clk,
		input logic TAPE_IN,
		input logic[3:0] button,
		output logic TAPE_OUT,
		output logic[3:0] LED,
		output logic[1:0]  R, G, B,
		output logic HSYNC, VSYNC,
		output logic audio,
		input logic ps2_clk_d, ps2_data_d,
		output logic ps2_clk_q, ps2_data_q,
		input logic RXD,
		output logic TXD,
		output CP2102_TXD,
		
		output wire SDRAM_CLK,
		output wire SDRAM_CKE,
		output wire SDRAM_CSn,
		output wire SDRAM_WREn,
		output wire SDRAM_CASn,
		output wire SDRAM_RASn,
		output wire[10:0] SDRAM_A,
		output wire SDRAM_BA,
		output wire SDRAM_DQM,
		inout wire[7:0] SDRAM_DQ);

logic reset, TAPE_S;
logic vdg_clk_25, clk_50, cpu_clk;
logic[7:0] DATA_IN, DATA_OUT, DD, PORT_A_OUT;
logic[4:0] PORT_B_OUT;
logic[12:0] DA;
logic[5:0] VDG_control;
logic[3:0] button_s;

always_ff @ (posedge clk_50)
begin
	reset <= ~RST;
	TAPE_S <= TAPE_IN;
	button_s <= button;
end

assign audio = VDG_control[5];
assign LED[3]=TAPE_S;
assign LED[2] = TAPE_OUT;
//assign LED[1] = audio;
//assign LED[0] = 1'b1;
//assign CP2102_TXD = TXD;
assign TAPE_OUT = PORT_B_OUT[0];
	
PLL0 PLL_inst(.inclk0(Clk), .c0(cpu_clk), .c1(vdg_clk_25), .c2(clk_50), .c3(SDRAM_CLK));

//************MEMORY SUBSYSTEM***************************************************************************************************************************
logic E_CLK;
logic[15:0] CPU_address;
logic rw;
logic[7:0] A_data_out, B_data_out;
logic[7:0] ROM_data;
logic RAM_W, ROM_E, RAM_E, VDG_E, KBD_E;
assign RAM_W = (~rw & E_CLK)&((CPU_address[14]&(~CPU_address[15]))|(CPU_address[15]&(~CPU_address[14])&(~CPU_address[13])&(~CPU_address[12])));
assign ROM_E = E_CLK & CPU_address[14] & CPU_address[15];
assign RAM_E = E_CLK & ((CPU_address[14]&(~CPU_address[15]))|(CPU_address[15]&(~CPU_address[14])&(~CPU_address[13])&(~CPU_address[12])));
assign VDG_E = E_CLK & CPU_address[15]&(~CPU_address[14])&(CPU_address[13]|CPU_address[12])&(~rw);
assign KBD_E = E_CLK & CPU_address[15]&(~CPU_address[14])&(CPU_address[13]|CPU_address[12])&rw;

ROM ROM_inst(.address(CPU_address[12:0]), .clock(clk_50), .q(ROM_data));

always_ff @(posedge clk_50)
begin
	if(VDG_E)
		VDG_control <= DATA_OUT[7:2];
end

always_comb
begin
	if(RAM_E)
		DATA_IN = A_data_out[7:0];
	else if(ROM_E)
		DATA_IN = ROM_data;
	else if(KBD_E)
		DATA_IN = {2'b11, key_out[5:0]};
	else
		DATA_IN = CPU_address[7:0];
end

SDRAM_controller SDRAM_inst(
			.clk(clk_50),
			.reset,
			.HSYNC,
			.A_address({6'h0, ~CPU_address[14], CPU_address[13:0]}),
			.A_write(RAM_W),
			.A_data_out,
			.A_data_in(DATA_OUT),
			.B_address({8'h00, DA}),
			.B_data_out,
			.SDRAM_CKE,
			.SDRAM_CSn,
			.SDRAM_WREn,
			.SDRAM_CASn,
			.SDRAM_RASn,
			.SDRAM_A,
			.SDRAM_BA,
			.SDRAM_DQM,
			.SDRAM_DQ);
assign DD = B_data_out[7:0];
//*******************************************************************************************************************************************************
logic[7:0] key_code;
logic[6:0] key_out;
logic[7:0] kb_data;
logic kb_ready;
logic printer_busy;
PS2_keyboard keyboard(.clk(clk_50), .reset(reset | (~button_s[1])), .ps2_clk_d, .ps2_data_d, .ps2_clk_q, .ps2_data_q, .key_code, .kb_ready, .kb_data, .ctrl(LED[1]), .alt(LED[0]));
KEY_MATRIX MATRIX(.row_select(PORT_A_OUT), .key_code, .key_out);
UART UART0(.clk(clk_50), .reset, .tx_req(kb_ready), .tx_data(kb_data), .tx(TXD), .rx(RXD), .rx_data(), .tx_ready(), .rx_ready());
printer TP10_inst(.clk(clk_50), .reset, .rx(TAPE_OUT), .tx(CP2102_TXD), .busy(printer_busy));

MC6803_gen2 CPU0(
		.clk(cpu_clk),
		.RST(reset | (~button_s[3])),
		.hold(~button_s[2]),
		.halt(1'b0),
		.nmi(~button_s[0]),
		.PORT_A_IN(PORT_A_OUT),
		.PORT_B_IN({TAPE_S, printer_busy, 1'b0, key_out[6], 1'b1}),
		.DATA_IN,
		.PORT_A_OUT,
		.PORT_B_OUT,
		.ADDRESS(CPU_address),
		.DATA_OUT,
		.E_CLK,
		.rw,
		.irq(1'b0));

MC6847_gen3 VDG(.DD, .DA, .clk_25(vdg_clk_25), .reset, .R, .G, .B, .HSYNC, .VSYNC, .AG(VDG_control[3]), .SA(DD[7]), .INV(DD[6]));
endmodule
