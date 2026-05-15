### 1. AXI4 Protocol Verification
**`/AXI Project`**

A full UVM-based verification environment for an AXI4 Full Slave, built from scratch — DUT design, testbench architecture, functional coverage closure, and formal property proofs in Jasper Gold.

---

#### What was built

**DUT — AXI4 Full Slave (SystemVerilog)**
- 5-channel implementation: AW / W / B / AR / R with independent per-channel FSMs
- Byte-lane steering via `wstrb` for partial-word writes
- All three burst modes: FIXED, INCR, WRAP — with correct wrap-boundary address computation
- Error responses: SLVERR (slave error) and DECERR (decode error)

**UVM Testbench**
- `uvm_config_db` virtual interface propagation — clean separation of TB and DUT
- Directed sequences for FIXED / INCR / WRAP burst modes
- Error injection sequences targeting SLVERR and DECERR paths
- Reference-model scoreboard: every AXI4 transaction checked against golden output
- Functional coverage collector: burst type × length × size × response cross-coverage

**Formal Verification — Jasper Gold**
- SVA property suite proving protocol correctness exhaustively (no simulation gaps)
- Proved: valid/ready handshake deadlock freedom
- Proved: WRAP burst address wrap-boundary invariants
- Proved: SLVERR / DECERR response correctness

---

#### Key results

| Metric | Result |
|--------|--------|
| Functional coverage | 95%+ |
| Burst modes verified | FIXED · INCR · WRAP |
| Formal properties proved | Deadlock freedom · burst invariants · error responses |
| Verification tool | Synopsys VCS + Jasper Gold |

---

#### Architecture



┌─────────────────────────────────────────────────────────────────────┐
│                          TEST LAYER                                  │
│        FIXED / INCR / WRAP sequences · error injection               │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────┐
│                        UVM ENVIRONMENT                               │
│                                                                      │
│  ┌─────────────────────────────────────┐  ┌──────────────────────┐  │
│  │           UVM AGENT                 │  │     SCOREBOARD       │  │
│  │                                     │  │                      │  │
│  │  ┌─────────────┐                   │  │  reference model     │  │
│  │  │  Sequencer  │                   │  │  actual vs expected  │  │
│  │  │  (stimulus) │                   │◄─┤  95%+ func coverage  │  │
│  │  └──────┬──────┘                   │  └──────────▲───────────┘  │
│  │         │                          │             │               │
│  │  ┌──────▼──────┐  ┌─────────────┐ │  ┌──────────┴───────────┐  │
│  │  │   Driver    │  │   Monitor   │─┼─► │  Coverage Collector  │  │
│  │  │ (AXI4 pins) │  │  (passive)  │ │  │  burst · err · type  │  │
│  │  └──────┬──────┘  └──────▲──────┘ │  └──────────────────────┘  │
│  │         │   vif (config_db)  │    │                              │
│  └─────────┼────────────────────┼───┘                              │
│            │                    │                                   │
│  ┌─────────▼────────────────────┴───────────────────────────────┐  │
│  │                  DUT — AXI4 FULL SLAVE                        │  │
│  │                                                               │  │
│  │  ┌───────┐  ┌───────────┐  ┌──────────┐  ┌───┐  ┌────────┐  │  │
│  │  │  AW   │  │     W     │  │    B     │  │ AR│  │   R    │  │  │
│  │  │ write │  │ write data│  │  write   │  │rd │  │SLVERR  │  │  │
│  │  │ addr  │  │  + wstrb  │  │ response │  │adr│  │DECERR  │  │  │
│  │  │  FSM  │  │  + burst  │  │          │  │FSM│  │        │  │  │
│  │  └───────┘  └───────────┘  └──────────┘  └───┘  └────────┘  │  │
│  │        FIXED / INCR / WRAP burst modes · wrap-boundary calc   │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────┐
│               JASPER GOLD — FORMAL SVA VERIFICATION                  │
│                                                                      │
│  ✓ valid/ready deadlock freedom        (safety property)             │
│  ✓ burst boundary invariants           (WRAP address wrap check)     │
│  ✓ SLVERR / DECERR response correct   (protocol compliance)         │
│                                                                      │
│  → Exhaustive proof — no simulation gaps                             │
└─────────────────────────────────────────────────────────────────────┘
