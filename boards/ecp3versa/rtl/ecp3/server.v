`default_nettype none
module server (
	// System
	input pcie_clk,
	input sys_rst,
	// Phy FIFO
	output [8:0]  phy_din,
	input phy_full,
	output reg  phy_wr_en,
	input [8:0] phy_dout,
	input phy_empty,
	output reg phy_rd_en,
	// Master BUS FIFO
	output [17:0]  mst_din,
	input mst_full,
	output reg  mst_wr_en,
	input [17:0] mst_dout,
	input mst_empty,
	output reg mst_rd_en,
	// LED and Switches
	input [7:0] dipsw,
	output [7:0] led,
	output [13:0] segled,
	input btn
);

reg [7:0] txd;
reg tx_en;
reg [11:0] counter;
reg [47:0] eth_dest;
reg [47:0] eth_src;
reg [15:0] eth_type;
reg [3:0] ip_hdrlen;
reg [7:0]  ipv4_tos;
reg [7:0]  ipv4_ttl;
reg [15:0] ipv4_sum;
reg [7:0]  ipv4_protocol;
reg [31:0] ipv4_src_ip, ipv4_dest_ip;
reg [15:0] ipv4_src_port, ipv4_dest_port;
reg [15:0] ipv4_udp_len;
reg [15:0] ipv4_udp_sum;
reg [31:0] magic_code;
always @(posedge pcie_clk) begin
	if (sys_rst) begin
		counter <= 12'h0;
		eth_dest <= 48'h0;
		eth_src <= 48'h0;
		eth_type <= 16'h0;
		ip_hdrlen <= 4'h0;
		ipv4_tos <= 8'h0;
		ipv4_ttl <= 8'h0;
		ipv4_sum <= 16'h0;
		ipv4_protocol <= 8'h0;
		ipv4_src_ip <= 32'h0;
		ipv4_dest_ip <= 32'h0;
		ipv4_src_port <= 16'h0;
		ipv4_dest_port <= 16'h0;
		ipv4_udp_len <= 16'h0;
		ipv4_udp_sum <= 16'h0;
		magic_code <= 32'h0;
		phy_rd_en <= 1'b0;
//		port0_wr_en <= 1'b0;
	end else begin
              	phy_rd_en  <= ~phy_empty;
//		port0_wr_en <= 1'b0;
		if ( phy_rd_en == 1'b1 ) begin
			counter <= counter + 12'h1;
			if (phy_dout[8] == 1'b1) begin
				case (counter)
					12'h00: eth_dest[47:40]       <= phy_dout[7:0];
					12'h01: eth_dest[39:32]       <= phy_dout[7:0];
					12'h02: eth_dest[31:24]       <= phy_dout[7:0];
					12'h03: eth_dest[23:16]       <= phy_dout[7:0];
					12'h04: eth_dest[15: 8]       <= phy_dout[7:0];
					12'h05: eth_dest[ 7: 0]       <= phy_dout[7:0];
					12'h06: eth_src[47:40]        <= phy_dout[7:0];
					12'h07: eth_src[39:32]        <= phy_dout[7:0];
					12'h08: eth_src[31:24]        <= phy_dout[7:0];
					12'h09: eth_src[23:16]        <= phy_dout[7:0];
					12'h0a: eth_src[15: 8]        <= phy_dout[7:0];
					12'h0b: eth_src[ 7: 0]        <= phy_dout[7:0];
					12'h0c: eth_type[15:8]        <= phy_dout[7:0];
					12'h0d: eth_type[7:0]         <= phy_dout[7:0];
					12'h0e: ip_hdrlen[3:0]        <= phy_dout[3:0];
					12'h0f: ipv4_tos[7:0]         <= phy_dout[7:0];
					12'h16: ipv4_ttl[7:0]         <= phy_dout[7:0];
					12'h17: ipv4_protocol[7:0]    <= phy_dout[7:0];
					12'h18: ipv4_sum[15:8]        <= phy_dout[7:0];
					12'h19: ipv4_sum[7:0]         <= phy_dout[7:0];
					12'h1a: ipv4_src_ip[31:24]    <= phy_dout[7:0];
					12'h1b: ipv4_src_ip[23:16]    <= phy_dout[7:0];
					12'h1c: ipv4_src_ip[15: 8]    <= phy_dout[7:0];
					12'h1d: ipv4_src_ip[ 7: 0]    <= phy_dout[7:0];
					12'h1e: ipv4_dest_ip[31:24]   <= phy_dout[7:0];
					12'h1f: ipv4_dest_ip[23:16]   <= phy_dout[7:0];
					12'h20: ipv4_dest_ip[15: 8]   <= phy_dout[7:0];
					12'h21: ipv4_dest_ip[ 7: 0]   <= phy_dout[7:0];
					12'h22: ipv4_src_port[15: 8]  <= phy_dout[7:0];
					12'h23: ipv4_src_port[ 7: 0]  <= phy_dout[7:0];
					12'h24: ipv4_dest_port[15: 8] <= phy_dout[7:0];
					12'h25: ipv4_dest_port[ 7: 0] <= phy_dout[7:0];
					12'h26: ipv4_udp_len[15: 8]   <= phy_dout[7:0]; // UDP header(0c)+data_length
					12'h27: ipv4_udp_len[ 7: 0]   <= phy_dout[7:0];
					12'h28: ipv4_udp_sum[15: 8]   <= phy_dout[7:0];
					12'h29: ipv4_udp_sum[ 7: 0]   <= phy_dout[7:0];
					12'h2a: magic_code[31:24]     <= phy_dout[7:0];
					12'h2b: magic_code[23:16]     <= phy_dout[7:0];
					12'h2c: magic_code[15: 8]     <= phy_dout[7:0];
					12'h2d: magic_code[ 7: 0]     <= phy_dout[7:0];
				endcase
			end else begin
				counter <= 12'h0;
			end
		end
	end
end

assign led[7:0] = ~eth_dest[7:0];

endmodule
`default_nettype wire
