set(CMAKE_SYSTEM_CPU cortex-m55 CACHE INTERNAL "System Processor")

set(CPU Cortex-M55)
set(FPU DP_FPU)
set(DSP DSP)
set(MVE FP_FVE)
set(BYTE_ORDER Little-endian)

set(SOC_VARIANT AE1C1F4051920)
set(BOARD_DFP_DIR DevKit-e1c)

# Include qualifiers specific
include(${CMAKE_CURRENT_LIST_DIR}/${BOARD_QUALIFIERS}/board.cmake)

function(update_board TARGET)
endfunction()
