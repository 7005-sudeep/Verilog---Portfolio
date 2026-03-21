module skid_buffer #(parameter WIDTH = 8) (
    input  logic             clk,
    input  logic             rst_n,

    // Input Interface (From Producer)
    input  logic [WIDTH-1:0] s_data,
    input  logic             s_valid,
    output logic             s_ready,

    // Output Interface (To Consumer)
    output logic [WIDTH-1:0] m_data,
    output logic             m_valid,
    input  logic             m_ready
);

    // Internal Storage (The "Skid" registers)
    logic [WIDTH-1:0] main_reg;
    logic [WIDTH-1:0] skid_reg;
    logic             skid_full;

    // 1. Ready Logic: We are ready if the skid register is empty
    assign s_ready = !skid_full;

    // 2. Control & Data Path
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            main_reg  <= '0;
            skid_reg  <= '0;
            skid_full <= 1'b0;
            m_valid   <= 1'b0;
        end else begin
            // CASE 1: Data flowing through (Standard Handshake)
            if (s_valid && s_ready) begin
                if (m_valid && !m_ready) begin
                    // Destination is NOT ready, move data to Skid
                    skid_reg  <= s_data;
                    skid_full <= 1'b1;
                end else begin
                    // Destination IS ready, move data to Main
                    main_reg  <= s_data;
                    m_valid   <= 1'b1;
                end
            end

            // CASE 2: Emptying the Skid Buffer
            if (m_valid && m_ready && skid_full) begin
                main_reg  <= skid_reg;
                skid_full <= 1'b0;
            end
            
            // CASE 3: Output Handshake completes
            if (m_valid && m_ready && !s_valid) begin
                m_valid <= 1'b0;
            end
        end
    end

    assign m_data = main_reg;

endmodule
