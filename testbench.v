`timescale 1ns/1ps
module tb;
//----------------------AHB Slave Interface---------------------
reg HCLK, HRESETn, HSELAPB, HWRITE;
reg [1:0]HTRANS;
reg [31:0]HADDR, HWDATA;
wire HRESP;
wire [31:0]HRDATA;
//-----------------------APB Output Signals---------------------
reg [31:0]PRDATA;
wire PSEL, PENABLE, PWRITE, HREADY;
wire [31:0]PADDR, PWDATA;
always #1 HCLK=~HCLK;
`ifdef Single_Read
initial
begin
$dumpfile("Single_Read.vcd");
$dumpvars;
end
initial
begin
//--------------------Single Read Transfer--------------------
HCLK=1'b1;
HRESETn=1'b0;
#2 HRESETn=1'b1;
HWRITE=1'b0;
HSELAPB=1'b1;
HTRANS=2'b10;
HADDR=32;
#2.1 HWRITE=1'bx;
HSELAPB=1'b0;
HTRANS=2'bxx;
HADDR=32'hxxxx_xxxx;
#1.9 PRDATA=16;
#2 $finish;
end
`endif
`ifdef Single_Write
initial
begin
$dumpfile("Single_Write.vcd");
$dumpvars;
end
initial
begin
//--------------------Single WRITE Transfer--------------------
HCLK=1'b1;
HRESETn=1'b0;
#2 HRESETn=1'b1;
HWRITE=1'b1;
HSELAPB=1'b1;
HTRANS=2'b10;
HADDR=32'h0000_0000;
#2 HWDATA=32'h0000_00ff;
HSELAPB=1'b0;
#0.1 HWRITE=1'bx;
HTRANS=2'bxx;
HADDR=32'hxxxx_xxxx;
#6 $finish;
end
`endif
`ifdef Burst_Read
initial
begin
$dumpfile("Burst_Read.vcd");
$dumpvars;
end
initial
begin
//--------------------Burst Read Transfer--------------------
HCLK=1'b1;
HRESETn=1'b0;
#2 //IDLE State
HRESETn=1'b1;
HWRITE=1'b0;
HSELAPB=1'b1;
HTRANS=2'b10;
HADDR=32'h0000_0000;
#2.1 //READ State
HTRANS=2'b11;
HADDR=32'h0000_0100;
#1.9 //RENABLE State
PRDATA=32'hFFFF_FFFF;
#2.1
HADDR=32'h0000_1000;
#1.9
PRDATA=32'hFFFF_FFFB;
#2.1
HADDR=32'h0000_1100;
#1.9
PRDATA=32'hFFFF_FFF8;
#2.1
HWRITE=1'bx;
HADDR=32'hxxxx_xxxx;
HTRANS=2'bxx;
HSELAPB=1'bx;
#1.9
PRDATA=32'hFFFF_FFF4;
#6 $finish;
end
`endif
`ifdef Burst_Write
initial
begin
$dumpfile("Burst_Write.vcd");
$dumpvars;
end
initial
begin
//--------------------Burst WRITE Transfer--------------------
HCLK=1'b1;
HRESETn=1'b0;
#2 //IDLE State
HRESETn=1'b1;
HWRITE=1'b1;
HSELAPB=1'b1;
HTRANS=2'b10;
HADDR=32'h0000_0000;
#2.1 //WWAIT State
HWDATA=32'h0000_000F;
HADDR=32'h0000_0100;
HTRANS=2'b11;
#2 //WRITEP State
HWDATA=32'h0000_00F0;
HADDR=32'h0000_1000;
#4; //WENABLE State
HWDATA=32'h0000_0F00;
HADDR=32'h0000_1100;
#4
HWDATA=32'h0000_F000;
HADDR=32'hxxxx_xxxx;
HWRITE=1'bx;
HSELAPB=1'bx;
HTRANS=2'bxx;
#4Page 
HWDATA=32'hxxxx_xxxx;
#8 $finish;
end
`endif
ahb2apb DUT(HCLK, HRESETn, HSELAPB, HADDR, HWRITE, HTRANS,
HWDATA, HRESP, HRDATA, HREADY, PRDATA, PSEL, PENABLE,
PADDR, PWRITE, PWDATA);
endmodule
