
module alu #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [3:0]       alu_ctrl,
    output logic [WIDTH-1:0] result,
    output logic             zero,
    output logic             carry,
    output logic             overflow,
    output logic             negative,
    output logic             sign,
    output logic             parity,
    output logic             mul_busy
);
    logic [1:0]       mul_stage;
    logic is_add, is_sub, is_addu, is_subu;
    logic is_and, is_xor, is_not;
    logic is_sll, is_srl, is_sra, is_rol, is_ror;
    logic is_shift, is_arith, is_mul;

    assign is_add   = (alu_ctrl == 4'b0000);
    assign is_sub   = (alu_ctrl == 4'b0001);
    assign is_and   = (alu_ctrl == 4'b0010);
    assign is_xor   = (alu_ctrl == 4'b0011);
    assign is_not   = (alu_ctrl == 4'b0100);
    assign is_addu  = (alu_ctrl == 4'b0101);
    assign is_subu  = (alu_ctrl == 4'b0110);
    assign is_mul   = rst_n && (alu_ctrl == 4'b0111);   // rst_n-gated, no X propagation

    assign is_sll   = (alu_ctrl == 4'b1000);
    assign is_srl   = (alu_ctrl == 4'b1001);
    assign is_sra   = (alu_ctrl == 4'b1010);
    assign is_rol   = (alu_ctrl == 4'b1011);
    assign is_ror   = (alu_ctrl == 4'b1100);

    assign is_shift = is_sll | is_srl | is_sra | is_rol | is_ror;
    assign is_arith = is_add | is_sub;

    logic [7:0] pp0_r, pp1_r, pp2_r, pp3_r;
    logic [7:0] s1_r,  s2_r;
    logic [1:0] mul_stage_reg;    // 0,1,2 = captures completed (only 3 real states now)
    logic [1:0] mul_stage_disp;

    always_comb begin
        if (!is_mul)
            mul_stage_disp = 2'd0;
        else if (mul_stage_reg == 2'd2)
            mul_stage_disp = 2'd3;      // final stage: product valid THIS cycle
        else
            mul_stage_disp = mul_stage_reg + 2'd1;
    end

    assign mul_stage = mul_stage_disp;

    assign mul_busy = is_mul && (mul_stage_reg != 2'd2);

    logic [7:0] pp0_raw, pp1_raw, pp2_raw, pp3_raw;
    logic [7:0] pp0_sh,  pp1_sh,  pp2_sh,  pp3_sh;

    booth_decoder u_dec0 (.a(a), .grp({b[1], b[0], 1'b0}), .pp(pp0_raw));
    booth_decoder u_dec1 (.a(a), .grp({b[3], b[2], b[1]}), .pp(pp1_raw));
    booth_decoder u_dec2 (.a(a), .grp({b[5], b[4], b[3]}), .pp(pp2_raw));
    booth_decoder u_dec3 (.a(a), .grp({b[7], b[6], b[5]}), .pp(pp3_raw));

    assign pp0_sh = pp0_raw;
    assign pp1_sh = {pp1_raw[5:0], 2'b00};
    assign pp2_sh = {pp2_raw[3:0], 4'b0000};
    assign pp3_sh = {pp3_raw[1:0], 6'b000000};

    logic [7:0] cla1_a, cla1_b, cla1_sum;
    logic       cla1_cin, cla1_cout;
    logic [7:0] cla2_a, cla2_b, cla2_sum;
    logic       cla2_cin, cla2_cout;

    cla8 u_cla1 (.a(cla1_a), .b(cla1_b), .cin(cla1_cin),
                 .sum(cla1_sum), .cout(cla1_cout));
    cla8 u_cla2 (.a(cla2_a), .b(cla2_b), .cin(cla2_cin),
                 .sum(cla2_sum), .cout(cla2_cout));

    logic [7:0] b_xor;
    logic       cin_normal;
    assign b_xor = (is_sub | is_subu) ? ~b : b;
    assign cin_normal = (is_sub | is_subu) ? 1'b1 : 1'b0;

    always_comb begin
        if (is_mul && (mul_stage_reg == 2'd1)) begin
            cla1_a   = pp0_r;
            cla1_b   = pp1_r;
            cla1_cin = 1'b0;
        end else begin
            cla1_a   = a;
            cla1_b   = b_xor;
            cla1_cin = cin_normal;
        end

        if (is_mul && (mul_stage_reg == 2'd1)) begin
            cla2_a   = pp2_r;
            cla2_b   = pp3_r;
            cla2_cin = 1'b0;
        end else if (is_mul && (mul_stage_reg == 2'd2)) begin
            cla2_a   = s1_r;
            cla2_b   = s2_r;   
            cla2_cin = 1'b0;
        end else begin
            cla2_a   = 8'd0;
            cla2_b   = 8'd0;
            cla2_cin = 1'b0;
        end
    end

    logic [2:0] shift_amt;
    logic [7:0] sll_out, srl_out, sra_out, rol_out, ror_out, shift_result;

    assign shift_amt = b[2:0];
    assign sll_out = a << shift_amt;
    assign srl_out = a >> shift_amt;
    assign sra_out = $signed(a) >>> shift_amt;

    always_comb begin
        case (shift_amt)
            3'd0: rol_out = a;
            3'd1: rol_out = {a[6:0], a[7]};
            3'd2: rol_out = {a[5:0], a[7:6]};
            3'd3: rol_out = {a[4:0], a[7:5]};
            3'd4: rol_out = {a[3:0], a[7:4]};
            3'd5: rol_out = {a[2:0], a[7:3]};
            3'd6: rol_out = {a[1:0], a[7:2]};
            3'd7: rol_out = {a[0],   a[7:1]};
        endcase
    end

    always_comb begin
        case (shift_amt)
            3'd0: ror_out = a;
            3'd1: ror_out = {a[0],   a[7:1]};
            3'd2: ror_out = {a[1:0], a[7:2]};
            3'd3: ror_out = {a[2:0], a[7:3]};
            3'd4: ror_out = {a[3:0], a[7:4]};
            3'd5: ror_out = {a[4:0], a[7:5]};
            3'd6: ror_out = {a[5:0], a[7:6]};
            3'd7: ror_out = {a[6:0], a[7]};
        endcase
    end

    assign shift_result = is_sll ? sll_out :
                          is_srl ? srl_out :
                          is_sra ? sra_out :
                          is_rol ? rol_out :
                          is_ror ? ror_out : 8'd0;

    logic [7:0] and_result, xor_result, not_result;
    assign and_result = a & b;
    assign xor_result = a ^ b;
    assign not_result = ~a;

    logic [7:0] result_next;

    always_comb begin
        if (is_mul) begin
            result_next = 8'd0;
        end else begin
            case (alu_ctrl)
                4'b0000: result_next = cla1_sum;
                4'b0001: result_next = cla1_sum;
                4'b0010: result_next = and_result;
                4'b0011: result_next = xor_result;
                4'b0100: result_next = not_result;
                4'b0101: result_next = cla1_sum;
                4'b0110: result_next = cla1_sum;
                4'b1000,
                4'b1001,
                4'b1010,
                4'b1011,
                4'b1100: result_next = shift_result;
                default: result_next = 8'd0;
            endcase
        end
    end

    logic flag_z_next, flag_c_next, flag_v_next, flag_n_next, flag_s_next, flag_p_next;

    assign flag_z_next = ~|result_next;
    assign flag_n_next = result_next[WIDTH-1];
    assign flag_p_next = ~^result_next;

    always_comb begin
        if (is_add) begin
            flag_c_next = cla1_cout;
            flag_v_next = (~a[WIDTH-1] & ~b[WIDTH-1] & cla1_sum[WIDTH-1]) |
                          ( a[WIDTH-1] &  b[WIDTH-1] & ~cla1_sum[WIDTH-1]);
        end else if (is_sub) begin
            flag_c_next = ~cla1_cout;
            flag_v_next = (~a[WIDTH-1] &  b[WIDTH-1] & cla1_sum[WIDTH-1]) |
                          ( a[WIDTH-1] & ~b[WIDTH-1] & ~cla1_sum[WIDTH-1]);
        end else if (is_addu) begin
            flag_c_next = cla1_cout;
            flag_v_next = 1'b0;
        end else if (is_subu) begin
            flag_c_next = ~cla1_cout;
            flag_v_next = 1'b0;
        end else begin
            flag_c_next = 1'b0;
            flag_v_next = 1'b0;
        end
        flag_s_next = flag_v_next ^ flag_n_next;
    end

    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_stage_reg <= 2'd0;
        pp0_r <= 8'd0; pp1_r <= 8'd0; pp2_r <= 8'd0; pp3_r <= 8'd0;
        s1_r  <= 8'd0; s2_r  <= 8'd0;
    end else begin
        if (is_mul) begin
            if (mul_stage_reg == 2'd2)
                mul_stage_reg <= 2'd0; 
            else
                mul_stage_reg <= mul_stage_reg + 1'b1;
        end else begin
            mul_stage_reg <= 2'd0;
        end

        if (is_mul && (mul_stage_reg == 2'd0)) begin
            pp0_r <= pp0_sh;
            pp1_r <= pp1_sh;
            pp2_r <= pp2_sh;
            pp3_r <= pp3_sh;
        end else if (is_mul && (mul_stage_reg == 2'd1)) begin
            s1_r <= cla1_sum;
            s2_r <= cla2_sum;
        end
    end
end

    always_comb begin
        if (is_mul) begin
            result   = (mul_stage_reg == 2'd2) ? cla2_sum : 8'd0;
            zero     = ~|result;
            negative = result[WIDTH-1];
            parity   = ~^result;
            carry    = 1'b0;
            overflow = 1'b0;
            sign     = 1'b0;
        end else begin
            result   = result_next;
            zero     = flag_z_next;
            carry    = flag_c_next;
            overflow = flag_v_next;
            negative = flag_n_next;
            sign     = flag_s_next;
            parity   = flag_p_next;
        end
    end

endmodule
