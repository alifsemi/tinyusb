set(CMAKE_SYSTEM_CPU cortex-m55 CACHE INTERNAL "System Processor")

set(CPU Cortex-M55)
set(FPU DP_FPU)
set(DSP DSP)
set(MVE FP_FVE)
set(BYTE_ORDER Little-endian)

set(SOC_VARIANT AE722F80F55D5)
set(BOARD_DFP_DIR DevKit-e7)
# Note: E3 (AE302F80F55D5LE) has no native SOC directory in the DFP.
# E3 targets use this board cmake with E7 SOC includes as a workaround.

# Include qualifiers specific
include(${CMAKE_CURRENT_LIST_DIR}/${BOARD_QUALIFIERS}/board.cmake)

function(update_board TARGET)
endfunction()
