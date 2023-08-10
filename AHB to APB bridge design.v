 `define IDLE 3'b000
`define READ 3'b001
`define WWAIT 3'b010
`define WRITE 3'b011
`define WRITEP 3'b100
`define WENABLE 3'b101
`define WENABLEP 3'b110
`define RENABLE 3'b111
`timescale 1ns/1ps
module ahb2apb(HCLK, HRESETn, HSELAPB, HADDR, HWRITE, HTRANS,
HWDATA, HRESP, HRDATA, HREADY, PRDATA, PSEL, PENABLE,
PADDR, PWRITE, PWDATA);
//----------------------AHB Slave Interface---------------------
input wire HCLK, HRESETn, HSELAPB, HWRITE;
input wire [1:0]HTRANS;
input wire [31:0]HADDR, HWDATA;
output reg HRESP, HREADY;
output reg [31:0]HRDATA;
//-----------------------APB Output Signals---------------------
input wire [31:0]PRDATA;
output reg PSEL, PENABLE, PWRITE;
output reg [31:0]PADDR, PWDATA;
//---------------------Implementation signals-------------------
reg [31:0]TMP_HADDR, TMP_HWDATA;
reg [2:0] ps,ns;
reg valid, HWrite;
always @(*)
begin
//------------------Valid logic--------------------
if (HSELAPB==1'b1 && (HTRANS==2'b10 || HTRANS==2'b11))
valid=1'b1;
else
valid=1'b0;
if(HRESETn==1'b0) //Asynchronous Active-low Reset
ns=`IDLE;
HRESP=1'b0; //Always OKAY Response
end
always @(posedge HCLK)
begin
ps=ns;
endPage 30 of 45
always @(ps)
begin
case(ps)
`IDLE :
begin
PSEL=1'b0;
PENABLE=1'b0;
HREADY=1'b1;
if(valid==1'b0)
ns=`IDLE;
else if(valid==1'b1 && HWRITE==1'b0)
ns=`READ;
else if(valid==1'b1 && HWRITE==1'b1)
ns=`WWAIT;
end
`READ :
begin
PSEL=1'b1;
PADDR=HADDR;
PWRITE=1'b0;
PENABLE=1'b0;
HREADY=1'b0;
ns=`RENABLE;
end
`WWAIT :
begin
PENABLE=1'b0;
TMP_HADDR=HADDR;
HWrite=HWRITE;
if(valid==1'b0)
ns=`WRITE;
else if(valid==1'b1)
ns=`WRITEP;
end
`WRITE :
begin
PSEL=1'b1;
PADDR=TMP_HADDR;
PWDATA=HWDATA;
PWRITE=1'b1;
PENABLE=1'b0;
HREADY=1'b0;
if(valid==1'b0)
ns=`WENABLE;
else if(valid==1'b1)
ns=`WENABLEP;
end
`WRITEP :
begin
PSEL=1'b1;
PADDR=TMP_HADDR;
PWDATA=HWDATA;
PWRITE=1'b1;
PENABLE=1'b0;
HREADY=1'b0;
TMP_HADDR=HADDR;
HWrite=HWRITE;
ns=`WENABLEP;
end
`WENABLE :
begin
PENABLE=1'b1;
HREADY=1'b1;
if(valid==1'b1 && HWRITE==1'b0)
ns=`READ;
else if(valid==1'b1 && HWRITE==1'b1)
ns=`WWAIT;
else if(valid==1'b0)
ns=`IDLE;
end
`WENABLEP :
begin
PENABLE=1'b1;
HREADY=1'b1;
if(valid==1'b0 && HWrite==1'b1)
ns=`WRITE;
else if(valid==1'b1 && HWrite==1'b1)
ns=`WRITEP;
else if(HWrite==1'b0)
ns=`READ;
end
`RENABLE :
begin
PENABLE=1'b1;
HRDATA=PRDATA;
HREADY=1'b1;
if(valid==1'b1 && HWRITE==1'b0)
ns=`READ;
else if(valid==1'b1 && HWRITE==1'b1)
ns=`WWAIT;
else if(valid==1'b0)
ns=`IDLE;
end
endcase
end
endmodule
