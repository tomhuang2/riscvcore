`timescale 1ns / 1ns

// registers are 32 bits in RV32
`define REG_SIZE 31:0

// insns are 32 bits in RV32IM
`define INSN_SIZE 31:0

// RV opcodes are 7 bits
`define OPCODE_SIZE 6:0

`ifndef DIVIDER_STAGES
`define DIVIDER_STAGES 8
`endif

`ifndef SYNTHESIS
`include "../hw3-singlecycle/RvDisassembler.sv"
`endif
`include "../hw2b-cla/CarryLookaheadAdder.sv"
`include "../hw4-multicycle/DividerUnsignedPipelined.sv"
`include "../hw3-singlecycle/cycle_status.sv"

module Disasm #(
    byte PREFIX = "D"
) (
    input wire [31:0] insn,
    output wire [(8*32)-1:0] disasm
);
`ifndef SYNTHESIS
  // this code is only for simulation, not synthesis
  string disasm_string;
  always_comb begin
    disasm_string = rv_disasm(insn);
  end
  // HACK: get disasm_string to appear in GtkWave, which can apparently show only wire/logic. Also,
  // string needs to be reversed to render correctly.
  genvar i;
  for (i = 3; i < 32; i = i + 1) begin : gen_disasm
    assign disasm[((i+1-3)*8)-1-:8] = disasm_string[31-i];
  end
  assign disasm[255-:8] = PREFIX;
  assign disasm[247-:8] = ":";
  assign disasm[239-:8] = " ";
`endif
endmodule

module RegFile (
    input logic [4:0] rd,
    input logic [`REG_SIZE] rd_data,
    input logic [4:0] rs1,
    output logic [`REG_SIZE] rs1_data,
    input logic [4:0] rs2,
    output logic [`REG_SIZE] rs2_data,

    input logic clk,
    input logic we,
    input logic rst
);
  localparam int NumRegs = 32;
  logic [`REG_SIZE] regs[NumRegs];

  // TODO: your code here
  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < 32; i++) begin
        regs[i] <= 32'b0;
      end
    end else if (we) begin
      if (rd != 0) begin
        regs[rd] <= rd_data;
      end
    end
  end

  assign rs1_data = regs[rs1];
  assign rs2_data = regs[rs2];
endmodule

/** state at the start of Decode stage */
typedef struct packed {
  logic [`REG_SIZE] pc;
  logic [`INSN_SIZE] insn;
  cycle_status_e cycle_status;
} stage_decode_t;

module DatapathPipelined (
    input wire clk,
    input wire rst,
    output logic [`REG_SIZE] pc_to_imem,
    input wire [`INSN_SIZE] insn_from_imem,
    // dmem is read/write
    output logic [`REG_SIZE] addr_to_dmem,
    input wire [`REG_SIZE] load_data_from_dmem,
    output logic [`REG_SIZE] store_data_to_dmem,
    output logic [3:0] store_we_to_dmem,

    output logic halt,

    // The PC of the insn currently in Writeback. 0 if not a valid insn.
    output logic [`REG_SIZE] trace_completed_pc,
    // The bits of the insn currently in Writeback. 0 if not a valid insn.
    output logic [`INSN_SIZE] trace_completed_insn,
    // The status of the insn (or stall) currently in Writeback. See the cycle_status.sv file for valid values.
    output cycle_status_e trace_completed_cycle_status
);

  // opcodes - see section 19 of RiscV spec
  localparam bit [`OPCODE_SIZE] OpLoad = 7'b00_000_11;
  localparam bit [`OPCODE_SIZE] OpStore = 7'b01_000_11;
  localparam bit [`OPCODE_SIZE] OpBranch = 7'b11_000_11;
  localparam bit [`OPCODE_SIZE] OpJalr = 7'b11_001_11;
  localparam bit [`OPCODE_SIZE] OpMiscMem = 7'b00_011_11;
  localparam bit [`OPCODE_SIZE] OpJal = 7'b11_011_11;

  localparam bit [`OPCODE_SIZE] OpRegImm = 7'b00_100_11;
  localparam bit [`OPCODE_SIZE] OpRegReg = 7'b01_100_11;
  localparam bit [`OPCODE_SIZE] OpEnviron = 7'b11_100_11;

  localparam bit [`OPCODE_SIZE] OpAuipc = 7'b00_101_11;
  localparam bit [`OPCODE_SIZE] OpLui = 7'b01_101_11;

  // cycle counter, not really part of any stage but useful for orienting within GtkWave
  // do not rename this as the testbench uses this value
  logic [`REG_SIZE] cycles_current;
  always_ff @(posedge clk) begin
    if (rst) begin
      cycles_current <= 0;
    end else begin
      cycles_current <= cycles_current + 1;
    end
  end

  /***************/
  /* FETCH STAGE */
  /***************/

  logic [`REG_SIZE] f_pc_current;
  wire [`REG_SIZE] f_insn;
  cycle_status_e f_cycle_status;

  // program counter
  always_ff @(posedge clk) begin
    if (rst) begin
      f_pc_current   <= 32'd0;
      // NB: use CYCLE_NO_STALL since this is the value that will persist after the last reset cycle
      f_cycle_status <= CYCLE_NO_STALL;
    end else if (load_use_stall) begin //do not move program counter at stall
      
    end else begin
      f_cycle_status <= CYCLE_NO_STALL;
      f_pc_current   <= branch_taken ? branch_target : f_pc_current + 4;
    end
  end
  // send PC to imem
  assign pc_to_imem = f_pc_current;
  assign f_insn = insn_from_imem;

  // Here's how to disassemble an insn into a string you can view in GtkWave.
  // Use PREFIX to provide a 1-character tag to identify which stage the insn comes from.
  wire [255:0] f_disasm;
  Disasm #(
      .PREFIX("F")
  ) disasm_0fetch (
      .insn  (f_insn),
      .disasm(f_disasm)
  );

  /****************/
  /* DECODE STAGE */
  /****************/

  // this shows how to package up state in a `struct packed`, and how to pass it between stages
  stage_decode_t decode_state;
  always_ff @(posedge clk) begin
    if (rst) begin
      decode_state <= '{pc: 0, insn: 0, cycle_status: CYCLE_RESET};
    end else if (branch_taken) begin
      decode_state <= '{default: 0, cycle_status: CYCLE_TAKEN_BRANCH};
    end else if (load_use_stall) begin //do not update on load use stall

    end else begin
      begin
        decode_state <= '{pc: f_pc_current, insn: f_insn, cycle_status: f_cycle_status};
      end
    end
  end
  wire [255:0] d_disasm;
  Disasm #(
      .PREFIX("D")
  ) disasm_1decode (
      .insn  (decode_state.insn),
      .disasm(d_disasm)
  );

  // TODO: your code here, though you will also need to modify some of the code above
  // TODO: the testbench requires that your register file instance is named `rf`

  // components of the instruction
  wire [6:0] insn_funct7;
  wire [4:0] insn_rs2;
  wire [4:0] insn_rs1;
  wire [2:0] insn_funct3;
  wire [4:0] insn_rd;
  wire [`OPCODE_SIZE] insn_opcode;

  // split R-type instruction - see section 2.2 of RiscV spec
  assign {insn_funct7, insn_rs2, insn_rs1, insn_funct3, insn_rd, insn_opcode} = decode_state.insn;

  // setup for I, S, B & J type instructions
  // I - short immediates and loads
  wire [11:0] imm_i;
  assign imm_i = decode_state.insn[31:20];
  wire [ 4:0] imm_shamt = decode_state.insn[24:20];

  // S - stores
  wire [11:0] imm_s;
  assign imm_s[11:5] = insn_funct7, imm_s[4:0] = insn_rd;

  // B - conditionals
  wire [12:0] imm_b;
  assign {imm_b[12], imm_b[10:5]} = insn_funct7, {imm_b[4:1], imm_b[11]} = insn_rd, imm_b[0] = 1'b0;

  // J - unconditional jumps
  wire [20:0] imm_j;
  assign {imm_j[20], imm_j[10:1], imm_j[11], imm_j[19:12], imm_j[0]} = {
    decode_state.insn[31:12], 1'b0
  };

  wire [`REG_SIZE] imm_i_sext = {{20{imm_i[11]}}, imm_i[11:0]};
  wire [`REG_SIZE] imm_s_sext = {{20{imm_s[11]}}, imm_s[11:0]};
  wire [`REG_SIZE] imm_b_sext = {{19{imm_b[12]}}, imm_b[12:0]};
  wire [`REG_SIZE] imm_j_sext = {{11{imm_j[20]}}, imm_j[20:0]};

  wire [`REG_SIZE] rs1_data;
  wire [`REG_SIZE] rs2_data;

  RegFile rf (
      .clk(clk),
      .rst(rst),
      .we(writeback_state.we),
      .rd(writeback_state.rd),
      .rd_data(writeback_state.rd_data),
      .rs1(insn_rs1),
      .rs2(insn_rs2),
      .rs1_data(rs1_data),
      .rs2_data(rs2_data)
  );

  wire [`REG_SIZE] rs1_data_wd = (writeback_state.we && writeback_state.rd != 0 && writeback_state.rd == insn_rs1) ? writeback_state.rd_data : rs1_data; //WD bypass
  wire [`REG_SIZE] rs2_data_wd = (writeback_state.we && writeback_state.rd != 0 && writeback_state.rd == insn_rs2) ? writeback_state.rd_data : rs2_data;
  
  wire load_use_stall = (execute_state.insn[6:0] == OpLoad) && (execute_state.rd != 0) && (execute_state.rd == insn_rs2 || ((execute_state.rd == insn_rs1) && insn_opcode != OpStore)); 

  /****************/
  /*EXECUTE STAGE**/
  /****************/

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    logic [`REG_SIZE] rs1_data;
    logic [`REG_SIZE] rs2_data;
    logic [`REG_SIZE] imm_i_sext;
    logic [`REG_SIZE] imm_s_sext;
    logic [`REG_SIZE] imm_b_sext;
    logic [`REG_SIZE] imm_j_sext;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    cycle_status_e cycle_status;
  } stage_execute_t;

  stage_execute_t execute_state;
  always_ff @(posedge clk) begin
    if (rst) begin
      execute_state <= '{default: 0, cycle_status: CYCLE_RESET};
    end else if (branch_taken) begin
      execute_state <= '{default: 0, cycle_status: CYCLE_TAKEN_BRANCH};
    end else if (load_use_stall) begin
      execute_state <= '{default: 0, cycle_status: CYCLE_LOAD2USE};
    end else begin
      execute_state <= '{
          pc: decode_state.pc,
          insn: decode_state.insn,
          rs1_data: rs1_data_wd,
          rs2_data: rs2_data_wd,
          imm_i_sext: imm_i_sext,
          imm_s_sext: imm_s_sext,
          imm_b_sext: imm_b_sext,
          imm_j_sext: imm_j_sext,
          rd: insn_rd,
          rs1: insn_rs1,
          rs2: insn_rs2,
          cycle_status: decode_state.cycle_status
      };
    end
  end
  wire [255:0] x_disasm;
  Disasm #(
      .PREFIX("X")
  ) disasm_2execute (
      .insn  (execute_state.insn),
      .disasm(x_disasm)
  );

  wire [6:0] x_insn_funct7;
  wire [4:0] x_insn_rs2;
  wire [4:0] x_insn_rs1;
  wire [2:0] x_insn_funct3;
  wire [4:0] x_insn_rd;
  wire [`OPCODE_SIZE] x_insn_opcode;

  // split R-type instruction - see section 2.2 of RiscV spec
  assign {x_insn_funct7, x_insn_rs2, x_insn_rs1, x_insn_funct3, x_insn_rd, x_insn_opcode} = execute_state.insn;

  wire x_insn_lui = x_insn_opcode == OpLui;
  wire x_insn_auipc = x_insn_opcode == OpAuipc;
  wire x_insn_jal = x_insn_opcode == OpJal;
  wire x_insn_jalr = x_insn_opcode == OpJalr;

  wire x_insn_beq = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b000;
  wire x_insn_bne = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b001;
  wire x_insn_blt = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b100;
  wire x_insn_bge = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b101;
  wire x_insn_bltu = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b110;
  wire x_insn_bgeu = x_insn_opcode == OpBranch && execute_state.insn[14:12] == 3'b111;

  wire x_insn_lb = x_insn_opcode == OpLoad && execute_state.insn[14:12] == 3'b000;
  wire x_insn_lh = x_insn_opcode == OpLoad && execute_state.insn[14:12] == 3'b001;
  wire x_insn_lw = x_insn_opcode == OpLoad && execute_state.insn[14:12] == 3'b010;
  wire x_insn_lbu = x_insn_opcode == OpLoad && execute_state.insn[14:12] == 3'b100;
  wire x_insn_lhu = x_insn_opcode == OpLoad && execute_state.insn[14:12] == 3'b101;

  wire x_insn_sb = x_insn_opcode == OpStore && execute_state.insn[14:12] == 3'b000;
  wire x_insn_sh = x_insn_opcode == OpStore && execute_state.insn[14:12] == 3'b001;
  wire x_insn_sw = x_insn_opcode == OpStore && execute_state.insn[14:12] == 3'b010;

  wire x_insn_addi = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b000;
  wire x_insn_slti = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b010;
  wire x_insn_sltiu = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b011;
  wire x_insn_xori = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b100;
  wire x_insn_ori = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b110;
  wire x_insn_andi = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b111;

  wire x_insn_slli = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b001 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_srli = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b101 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_srai = x_insn_opcode == OpRegImm && execute_state.insn[14:12] == 3'b101 && execute_state.insn[31:25] == 7'b0100000;

  wire x_insn_add  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b000 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_sub  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b000 && execute_state.insn[31:25] == 7'b0100000;
  wire x_insn_sll  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b001 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_slt  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b010 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_sltu = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b011 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_xor  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b100 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_srl  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b101 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_sra  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b101 && execute_state.insn[31:25] == 7'b0100000;
  wire x_insn_or   = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b110 && execute_state.insn[31:25] == 7'd0;
  wire x_insn_and  = x_insn_opcode == OpRegReg && execute_state.insn[14:12] == 3'b111 && execute_state.insn[31:25] == 7'd0;

  wire x_insn_mul    = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b000;
  wire x_insn_mulh   = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b001;
  wire x_insn_mulhsu = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b010;
  wire x_insn_mulhu  = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b011;
  wire x_insn_div    = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b100;
  wire x_insn_divu   = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b101;
  wire x_insn_rem    = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b110;
  wire x_insn_remu   = x_insn_opcode == OpRegReg && execute_state.insn[31:25] == 7'd1 && execute_state.insn[14:12] == 3'b111;

  wire x_insn_ecall = x_insn_opcode == OpEnviron && execute_state.insn[31:7] == 25'd0;
  wire x_insn_fence = x_insn_opcode == OpMiscMem;

  logic illegal_insn;

  logic [`REG_SIZE] cla_result;
  logic [`REG_SIZE] cla_operand_a;
  logic [`REG_SIZE] cla_operand_b;
  logic cla_carry_in;
  logic [7:0] b;
  logic [15:0] h;
  logic [63:0] prod;
  logic [31:0] div_a;
  logic [31:0] div_b;

  logic [`REG_SIZE] div_dividend;
  logic [`REG_SIZE] div_divisor;
  logic [`REG_SIZE] div_remainder;
  logic [`REG_SIZE] div_quotient;
  logic [3:0] div_counter;
  logic [`REG_SIZE] alu_result;
  logic [`REG_SIZE] x_rs1_data;
  logic [`REG_SIZE] x_rs2_data;
  logic insn_writes_rd;
  logic branch_taken;
  logic [`REG_SIZE] branch_target;

  CarryLookaheadAdder cla (
      .a  (cla_operand_a),
      .b  (cla_operand_b),
      .cin(cla_carry_in),
      .sum(cla_result)
  );

  DividerUnsignedPipelined div (
      .clk(clk),
      .rst(rst),
      .stall(1'b0),
      .i_dividend(div_dividend),
      .i_divisor(div_divisor),
      .o_remainder(div_remainder),
      .o_quotient(div_quotient)
  );

  // MX bypass
  assign x_rs1_data = (memory_state.we && memory_state.rd != 0 && memory_state.rd == execute_state.rs1) ? memory_state.rd_data :
                    (writeback_state.we && writeback_state.rd != 0 && writeback_state.rd == execute_state.rs1) ? writeback_state.rd_data :
                    execute_state.rs1_data;
  // WX bypass
  assign x_rs2_data = (memory_state.we && memory_state.rd != 0 && memory_state.rd == execute_state.rs2) ? memory_state.rd_data :
                    (writeback_state.we && writeback_state.rd != 0 && writeback_state.rd == execute_state.rs2) ? writeback_state.rd_data :
                    execute_state.rs2_data;

  always_comb begin
    illegal_insn = 1'b0;
    insn_writes_rd = 0;  // write enable 

    alu_result = 32'b0;
    branch_taken = 1'b0;
    branch_target = 32'b0;
    prod = 64'b0;

    // defaults for CLA (it defaults to addi)
    cla_operand_a = x_rs1_data;
    cla_operand_b = execute_state.imm_i_sext;
    cla_carry_in = 1'b0;

    //defaults for DIV
    div_dividend = 32'b0;
    div_divisor = 32'b0;
    div_a = 32'b0;
    div_b = 32'b0;

    case (x_insn_opcode)
      OpLui: begin
        insn_writes_rd = 1'b1;
        alu_result = {execute_state.insn[31:12], 12'b0};
      end

      OpRegImm: begin
        // enable write
        insn_writes_rd = 1'b1;
        if (x_insn_addi) begin
          alu_result = cla_result;
        end else if (x_insn_slti) begin
          alu_result = {31'b0, $signed(x_rs1_data) < $signed(execute_state.imm_i_sext)};
        end else if (x_insn_sltiu) begin
          alu_result = {31'b0, x_rs1_data < execute_state.imm_i_sext};
        end else if (x_insn_xori) begin
          alu_result = x_rs1_data ^ execute_state.imm_i_sext;
        end else if (x_insn_ori) begin
          alu_result = x_rs1_data | execute_state.imm_i_sext;
        end else if (x_insn_andi) begin
          alu_result = x_rs1_data & execute_state.imm_i_sext;
        end else if (x_insn_slli) begin
          alu_result = x_rs1_data << execute_state.insn[24:20];
        end else if (x_insn_srli) begin
          alu_result = x_rs1_data >> execute_state.insn[24:20];
        end else if (x_insn_srai) begin
          alu_result = $signed(x_rs1_data) >>> execute_state.insn[24:20];
        end
      end

      OpRegReg: begin
        // enable write
        insn_writes_rd = 1'b1;

        if (x_insn_add) begin
          cla_operand_b = x_rs2_data;
          alu_result = cla_result;
        end else if (x_insn_sub) begin
          cla_operand_b = ~x_rs2_data;
          cla_carry_in = 1'b1;
          alu_result = cla_result;
        end else if (x_insn_sll) begin
          alu_result = x_rs1_data << x_rs2_data[4:0];
        end else if (x_insn_slt) begin
          alu_result = {31'b0, $signed(x_rs1_data) < $signed(x_rs2_data)};
        end else if (x_insn_sltu) begin
          alu_result = {31'b0, x_rs1_data < x_rs2_data};
        end else if (x_insn_xor) begin
          alu_result = x_rs1_data ^ x_rs2_data;
        end else if (x_insn_srl) begin
          alu_result = x_rs1_data >> x_rs2_data[4:0];
        end else if (x_insn_sra) begin
          alu_result = $signed(x_rs1_data) >>> x_rs2_data[4:0];
        end else if (x_insn_or) begin
          alu_result = x_rs1_data | x_rs2_data;
        end else if (x_insn_and) begin
          alu_result = x_rs1_data & x_rs2_data;
        end else if (x_insn_mul) begin
          prod = x_rs1_data * x_rs2_data;
          alu_result = prod[31:0];
        end else if (x_insn_mulh) begin
          prod = $signed(x_rs1_data) * $signed(x_rs2_data);
          alu_result = prod[63:32];
        end else if (x_insn_mulhsu) begin
          prod = $signed({{32{x_rs1_data[31]}}, x_rs1_data}) * $signed({32'b0, x_rs2_data});
          alu_result = prod[63:32];
        end else if (x_insn_mulhu) begin
          prod = $unsigned(x_rs1_data) * $unsigned(x_rs2_data);
          alu_result = prod[63:32];
        end else if (x_insn_div) begin
          if (x_rs2_data == 32'b0) begin
            alu_result = 32'hFFFFFFFF;
          end else if (x_rs1_data == 32'h80000000 && x_rs2_data == 32'hFFFFFFFF) begin
            alu_result = 32'h80000000;
          end else begin
            div_a = x_rs1_data[31] ? (~x_rs1_data + 1) : x_rs1_data;
            div_b = x_rs2_data[31] ? (~x_rs2_data + 1) : x_rs2_data;

            div_dividend = div_a;
            div_divisor = div_b;

            if (x_rs1_data[31] != x_rs2_data[31]) begin
              alu_result = ~div_quotient + 1;
            end else begin
              alu_result = div_quotient;
            end
          end
        end else if (x_insn_divu) begin
          div_dividend = x_rs1_data;
          div_divisor  = $unsigned(x_rs2_data);
          alu_result   = div_quotient;
        end else if (x_insn_rem) begin
          if (x_rs2_data == 32'b0) begin
            alu_result = x_rs1_data;
          end else if (x_rs1_data == 32'h80000000 && x_rs2_data == 32'hFFFFFFFF) begin
            alu_result = 0;
          end else begin
            div_a = x_rs1_data[31] ? (~x_rs1_data + 1) : x_rs1_data;
            div_b = x_rs2_data[31] ? (~x_rs2_data + 1) : x_rs2_data;

            div_dividend = div_a;
            div_divisor = div_b;

            if (x_rs1_data[31]) begin
              alu_result = ~div_remainder + 1;
            end else begin
              alu_result = div_remainder;
            end
          end
        end else if (x_insn_remu) begin
          div_dividend = x_rs1_data;
          div_divisor  = $unsigned(x_rs2_data);
          alu_result   = div_remainder;
        end
      end

      OpBranch: begin
        if (x_insn_beq) begin
          if (x_rs1_data == x_rs2_data) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end else if (x_insn_bne) begin
          if (x_rs1_data != x_rs2_data) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end else if (x_insn_blt) begin
          if ($signed(x_rs1_data) < $signed(x_rs2_data)) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end else if (x_insn_bge) begin
          if ($signed(x_rs1_data) >= $signed(x_rs2_data)) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end else if (x_insn_bltu) begin
          if (x_rs1_data < x_rs2_data) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end else if (x_insn_bgeu) begin
          if (x_rs1_data >= x_rs2_data) begin
            branch_taken  = 1'b1;
            branch_target = execute_state.pc + execute_state.imm_b_sext;
          end
        end
      end

      OpEnviron: begin
        // halt handled outside always_comb
      end

      OpAuipc: begin
        insn_writes_rd = 1'b1;
        alu_result = execute_state.pc + {execute_state.insn[31:12], 12'b0};
      end

      OpLoad: begin
        insn_writes_rd = 1'b1;
        cla_operand_a = x_rs1_data;
        cla_operand_b = execute_state.imm_i_sext;
        alu_result = cla_result;
      end

      OpStore: begin
        cla_operand_a = x_rs1_data;
        cla_operand_b = execute_state.imm_s_sext;
        alu_result = cla_result;
      end

      OpJal: begin
        insn_writes_rd = 1;
        alu_result = execute_state.pc + 4;
        branch_taken = 1'b1;
        branch_target = execute_state.pc + execute_state.imm_j_sext;
      end

      OpJalr: begin
        insn_writes_rd = 1;
        alu_result = execute_state.pc + 4;
        branch_taken = 1'b1;
        branch_target = (x_rs1_data + execute_state.imm_i_sext) & {{31{1'b1}}, 1'b0};
      end

      default: begin
        illegal_insn = 1'b1;
      end
    endcase
  end

  /****************/
  /*MEMORY STAGE**/
  /****************/

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    logic [`REG_SIZE] rd_data;
    logic [`REG_SIZE] rs2_data;
    logic [`REG_SIZE] addr;
    logic [4:0] rd;
    logic [1:0] byte_offset;
    logic we;
    cycle_status_e cycle_status;
  } stage_memory_t;

  stage_memory_t memory_state;

  always_ff @(posedge clk) begin
    if (rst) begin
      memory_state <= '{default: 0, cycle_status: CYCLE_RESET};
    end else begin
      memory_state <= '{
          pc: execute_state.pc,
          insn: execute_state.insn,
          rd_data: alu_result,
          rs2_data: x_rs2_data,
          addr: {alu_result[31:2], 2'b0},
          rd: execute_state.rd,
          byte_offset: alu_result[1:0],
          we: insn_writes_rd,
          cycle_status: execute_state.cycle_status
      };
    end
  end

  wire [255:0] m_disasm;
  Disasm #(
      .PREFIX("M")
  ) disasm_3memory (
      .insn  (memory_state.insn),
      .disasm(m_disasm)
  );

  wire [6:0] m_insn_funct7;
  wire [4:0] m_insn_rs2;
  wire [4:0] m_insn_rs1;
  wire [2:0] m_insn_funct3;
  wire [4:0] m_insn_rd;
  wire [`OPCODE_SIZE] m_insn_opcode;

  assign {m_insn_funct7, m_insn_rs2, m_insn_rs1, m_insn_funct3, m_insn_rd, m_insn_opcode} = memory_state.insn;

  wire m_insn_lb = m_insn_opcode == OpLoad && memory_state.insn[14:12] == 3'b000;
  wire m_insn_lh = m_insn_opcode == OpLoad && memory_state.insn[14:12] == 3'b001;
  wire m_insn_lw = m_insn_opcode == OpLoad && memory_state.insn[14:12] == 3'b010;
  wire m_insn_lbu = m_insn_opcode == OpLoad && memory_state.insn[14:12] == 3'b100;
  wire m_insn_lhu = m_insn_opcode == OpLoad && memory_state.insn[14:12] == 3'b101;

  wire m_insn_sb = m_insn_opcode == OpStore && memory_state.insn[14:12] == 3'b000;
  wire m_insn_sh = m_insn_opcode == OpStore && memory_state.insn[14:12] == 3'b001;
  wire m_insn_sw = m_insn_opcode == OpStore && memory_state.insn[14:12] == 3'b010;

  wire is_writeback_load = (writeback_state.insn[6:0] == OpLoad);
  wire [`REG_SIZE] m_store_data = (is_writeback_load && writeback_state.rd != 0 && writeback_state.rd == m_insn_rs2) ? writeback_state.rd_data : memory_state.rs2_data; //WM bypass
  logic  [`REG_SIZE] m_load_data;

  always_comb begin
    addr_to_dmem = memory_state.addr;
    b = 8'b0;
    h = 16'b0;
    store_data_to_dmem = 32'b0;
    store_we_to_dmem = 4'b0;
    m_load_data = 32'b0;

    case (m_insn_opcode)
     OpLoad: begin 
          if (m_insn_lb) begin
            case (memory_state.byte_offset[1:0])
              2'b00: begin
                b = load_data_from_dmem[7:0];
              end

              2'b01: begin
                b = load_data_from_dmem[15:8];
              end

              2'b10: begin
                b = load_data_from_dmem[23:16];
              end

              2'b11: begin
                b = load_data_from_dmem[31:24];
              end
            endcase

            m_load_data = {{24{b[7]}},b};

          end else if(m_insn_lbu) begin
            case (memory_state.byte_offset[1:0])
              2'b00: begin
                b = load_data_from_dmem[7:0];
              end

              2'b01: begin
                b = load_data_from_dmem[15:8];
              end

              2'b10: begin
                b = load_data_from_dmem[23:16];
              end

              2'b11: begin
                b = load_data_from_dmem[31:24];
              end
            endcase

            m_load_data = {{24{1'b0}},b};

          end else if (m_insn_lh) begin
            case (memory_state.byte_offset[1])
              1'b0: begin
                h = load_data_from_dmem[15:0];
              end

              1'b1: begin
                h = load_data_from_dmem[31:16];
              end
            endcase

            m_load_data = {{16{h[15]}},h};
          end else if (m_insn_lhu) begin
            case (memory_state.byte_offset[1])
              1'b0: begin
                h = load_data_from_dmem[15:0];
              end

              1'b1: begin
                h = load_data_from_dmem[31:16];
              end
            endcase

            m_load_data = {{16{1'b0}},h};
          end else if (m_insn_lw) begin
            m_load_data = load_data_from_dmem;
          end


        end

        OpStore: begin
          if (m_insn_sb) begin
            case (memory_state.byte_offset[1:0])
              2'b00: begin
                store_data_to_dmem[7:0] = m_store_data[7:0];
                store_we_to_dmem = 4'b0001;
              end 

              2'b01: begin
                store_data_to_dmem[15:8] = m_store_data[7:0];
                store_we_to_dmem = 4'b0010;
              end 

              2'b10: begin
                store_data_to_dmem[23:16] = m_store_data[7:0];
                store_we_to_dmem = 4'b0100;
              end 

              2'b11: begin
                store_data_to_dmem[31:24] = m_store_data[7:0];
                store_we_to_dmem = 4'b1000;
              end 
            endcase
          end else if (m_insn_sh) begin
            case (memory_state.byte_offset[1])
              1'b0: begin
                store_data_to_dmem[15:0] = m_store_data[15:0];
                store_we_to_dmem = 4'b0011;
              end 

              1'b1: begin
                store_data_to_dmem[31:16] = m_store_data[15:0];
                store_we_to_dmem = 4'b1100;
              end 
            endcase
          end else if (m_insn_sw) begin
            store_data_to_dmem[31:0] = m_store_data[31:0];
            store_we_to_dmem = 4'b1111;
          end
        end

        default: begin 

        end
    endcase
  end


  /****************/
  /*WRITEBACK STAGE**/
  /****************/

  typedef struct packed {
    logic [`REG_SIZE] pc;
    logic [`INSN_SIZE] insn;
    logic [`REG_SIZE] rd_data;
    logic [4:0] rd;
    logic we;
    cycle_status_e cycle_status;
  } stage_writeback_t;

  stage_writeback_t writeback_state;

  always_ff @(posedge clk) begin
    if (rst) begin
      writeback_state <= '{default: 0, cycle_status: CYCLE_RESET};
    end else begin
      writeback_state <= '{
          pc: memory_state.pc,
          insn: memory_state.insn,
          rd_data: (memory_state.insn[6:0] == OpLoad) ? m_load_data : memory_state.rd_data, 
          rd: memory_state.rd,
          we: memory_state.we,
          cycle_status: memory_state.cycle_status
      };
    end
  end

  wire [255:0] w_disasm;
  Disasm #(
      .PREFIX("W")
  ) disasm_4writeback (
      .insn  (writeback_state.insn),
      .disasm(w_disasm)
  );

  assign halt = writeback_state.insn[6:0] == OpEnviron 
              && writeback_state.insn[31:7] == 25'd0
              && writeback_state.cycle_status == CYCLE_NO_STALL;

  assign trace_completed_pc = (writeback_state.cycle_status == CYCLE_NO_STALL) ? writeback_state.pc : 32'b0;
  assign trace_completed_insn = (writeback_state.cycle_status == CYCLE_NO_STALL) ? writeback_state.insn : 32'b0;
  assign trace_completed_cycle_status = writeback_state.cycle_status;

endmodule

module MemorySingleCycle #(
    parameter int NUM_WORDS = 512
) (
    // rst for both imem and dmem
    input wire rst,

    // clock for both imem and dmem. The memory reads/writes on @(negedge clk)
    input wire clk,

    // must always be aligned to a 4B boundary
    input wire [`REG_SIZE] pc_to_imem,

    // the value at memory location pc_to_imem
    output logic [`REG_SIZE] insn_from_imem,

    // must always be aligned to a 4B boundary
    input wire [`REG_SIZE] addr_to_dmem,

    // the value at memory location addr_to_dmem
    output logic [`REG_SIZE] load_data_from_dmem,

    // the value to be written to addr_to_dmem, controlled by store_we_to_dmem
    input wire [`REG_SIZE] store_data_to_dmem,

    // Each bit determines whether to write the corresponding byte of store_data_to_dmem to memory location addr_to_dmem.
    // E.g., 4'b1111 will write 4 bytes. 4'b0001 will write only the least-significant byte.
    input wire [3:0] store_we_to_dmem
);

  // memory is arranged as an array of 4B words
  logic [`REG_SIZE] mem_array[NUM_WORDS];

`ifdef SYNTHESIS
  initial begin
    $readmemh("mem_initial_contents.hex", mem_array);
  end
`endif

  always_comb begin
    // memory addresses should always be 4B-aligned
    assert (pc_to_imem[1:0] == 2'b00);
    assert (addr_to_dmem[1:0] == 2'b00);
  end

  localparam int AddrMsb = $clog2(NUM_WORDS) + 1;
  localparam int AddrLsb = 2;

  always @(negedge clk) begin
    if (rst) begin
    end else begin
      insn_from_imem <= mem_array[{pc_to_imem[AddrMsb:AddrLsb]}];
    end
  end

  always @(negedge clk) begin
    if (rst) begin
    end else begin
      if (store_we_to_dmem[0]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][7:0] <= store_data_to_dmem[7:0];
      end
      if (store_we_to_dmem[1]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][15:8] <= store_data_to_dmem[15:8];
      end
      if (store_we_to_dmem[2]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][23:16] <= store_data_to_dmem[23:16];
      end
      if (store_we_to_dmem[3]) begin
        mem_array[addr_to_dmem[AddrMsb:AddrLsb]][31:24] <= store_data_to_dmem[31:24];
      end
      // dmem is "read-first": read returns value before the write
      load_data_from_dmem <= mem_array[{addr_to_dmem[AddrMsb:AddrLsb]}];
    end
  end
endmodule

/* This design has just one clock for both processor and memory. */
module Processor (
    input wire clk,
    input wire rst,
    output logic halt,
    output wire [`REG_SIZE] trace_completed_pc,
    output wire [`INSN_SIZE] trace_completed_insn,
    output cycle_status_e trace_completed_cycle_status
);

  wire [`INSN_SIZE] insn_from_imem;
  wire [`REG_SIZE] pc_to_imem, mem_data_addr, mem_data_loaded_value, mem_data_to_write;
  wire [3:0] mem_data_we;

  // This wire is set by cocotb to the name of the currently-running test, to make it easier
  // to see what is going on in the waveforms.
  wire [(8*32)-1:0] test_case;

  MemorySingleCycle #(
      .NUM_WORDS(8192)
  ) memory (
      .rst                (rst),
      .clk                (clk),
      // imem is read-only
      .pc_to_imem         (pc_to_imem),
      .insn_from_imem     (insn_from_imem),
      // dmem is read-write
      .addr_to_dmem       (mem_data_addr),
      .load_data_from_dmem(mem_data_loaded_value),
      .store_data_to_dmem (mem_data_to_write),
      .store_we_to_dmem   (mem_data_we)
  );

  DatapathPipelined datapath (
      .clk(clk),
      .rst(rst),
      .pc_to_imem(pc_to_imem),
      .insn_from_imem(insn_from_imem),
      .addr_to_dmem(mem_data_addr),
      .store_data_to_dmem(mem_data_to_write),
      .store_we_to_dmem(mem_data_we),
      .load_data_from_dmem(mem_data_loaded_value),
      .halt(halt),
      .trace_completed_pc(trace_completed_pc),
      .trace_completed_insn(trace_completed_insn),
      .trace_completed_cycle_status(trace_completed_cycle_status)
  );

endmodule
