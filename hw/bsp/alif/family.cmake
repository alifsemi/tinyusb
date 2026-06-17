if(NOT DEFINED ALIF_CMSIS_DFP)
  set(ALIF_CMSIS_DFP ${TOP}/hw/mcu/alif/ensemble-cmsis-dfp)
endif()
message(STATUS "Using ALIF_CMSIS_DFP: ${ALIF_CMSIS_DFP}")
if(NOT DEFINED ALIF_COMMON_APP_UTILS)
  set(ALIF_COMMON_APP_UTILS ${TOP}/hw/mcu/alif/common-app-utils)
endif()
message(STATUS "Using ALIF_COMMON_APP_UTILS: ${ALIF_COMMON_APP_UTILS}")
if(NOT DEFINED CMSIS_DIR)
  set(CMSIS_DIR ${TOP}/lib/CMSIS_6)
endif()
message(STATUS "Using CMSIS_DIR: ${CMSIS_DIR}")

# Include board specific
include(${CMAKE_CURRENT_LIST_DIR}/boards/${BOARD}/board.cmake OPTIONAL RESULT_VARIABLE board_cmake_included)
message(STATUS "Trying to include board: ${BOARD}${BOARD_QUALIFIERS}, success: ${board_cmake_included}")

# Validate MCU_VARIANT value
message(STATUS "Using MCU_VARIANT: ${MCU_VARIANT}")
if(NOT MCU_VARIANT STREQUAL "M55_HP" AND NOT MCU_VARIANT STREQUAL "M55_HE")
  message(FATAL_ERROR "The chip is not supported. MCU_VARIANT must be 'M55_HP' or 'M55_HE', got: ${MCU_VARIANT}")
endif()

set(CMAKE_TOOLCHAIN_FILE ${TOP}/examples/build_system/cmake/toolchain/arm_${TOOLCHAIN}.cmake)
message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")

#------------------------------------
# Functions
#------------------------------------

function(add_board_target BOARD_TARGET)
  if (TARGET ${BOARD_TARGET})
    return()
  endif ()

  # Determine RTSS core directory based on MCU variant
  if(MCU_VARIANT STREQUAL "M55_HP")
    set(RTSS_CORE rtss_hp)
  elseif(MCU_VARIANT STREQUAL "M55_HE")
    set(RTSS_CORE rtss_he)
  endif()

  set(LD_SCRIPT ${ALIF_CMSIS_DFP}/Device/core/${RTSS_CORE}/linker/linker_gnu_mram.ld.src)
  message(STATUS "Setting linker source file: ${LD_SCRIPT}")

  if (NOT DEFINED STARTUP_FILE_${CMAKE_C_COMPILER_ID})
    set(STARTUP_FILE_GNU ${ALIF_CMSIS_DFP}/Device/core/common/source/startup.c)
    set(STARTUP_FILE_Clang ${STARTUP_FILE_GNU})
    message(STATUS "Setting startup file: ${STARTUP_FILE_GNU}")
  endif ()

  add_library(${BOARD_TARGET} STATIC
    ${ALIF_CMSIS_DFP}/libs/board_config/board_config.c
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Source/Driver_USART.c
    ${ALIF_CMSIS_DFP}/drivers/source/uart.c
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Source/Driver_IO.c
    ${ALIF_CMSIS_DFP}/drivers/source/mhu_driver.c
    ${ALIF_CMSIS_DFP}/drivers/source/mhu_receiver.c
    ${ALIF_CMSIS_DFP}/drivers/source/mhu_sender.c
    ${ALIF_CMSIS_DFP}/drivers/source/pinconf.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/cache.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/mpu.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/pm.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/sau_tcm_ns_setup.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/startup.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/system.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/tgu.c
    ${ALIF_CMSIS_DFP}/Device/core/common/source/vectors.c
    ${ALIF_CMSIS_DFP}/Device/system/source/sys_clocks.c
    ${ALIF_CMSIS_DFP}/Device/system/source/sys_utils.c
    ${ALIF_CMSIS_DFP}/se_services/port/clock_runtime.c
    ${ALIF_CMSIS_DFP}/se_services/port/se_services_port.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_application.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_boot.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_clocks.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_cryptocell.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_error.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_extsys0.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_handler.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_maintenance.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_padcontrol.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_pinmux.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_power.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_system.c
    ${ALIF_CMSIS_DFP}/se_services/source/services_host_update.c
    ${ALIF_CMSIS_DFP}/se_services/templates/services_lib_interface.c
    ${ALIF_COMMON_APP_UTILS}/logging/uart_tracelib.c
    ${STARTUP_FILE_${CMAKE_C_COMPILER_ID}}
    )

  target_include_directories(${BOARD_TARGET} PUBLIC
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Include
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Source
    ${ALIF_CMSIS_DFP}/Device/core/${RTSS_CORE}/config
    ${ALIF_CMSIS_DFP}/Device/core/common/include
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/config
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/rte
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/include
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/include/${RTSS_CORE}
    ${ALIF_CMSIS_DFP}/Device/system/include
    ${ALIF_CMSIS_DFP}/Boards/${BOARD_DFP_DIR}
    ${ALIF_CMSIS_DFP}/drivers/include
    ${ALIF_CMSIS_DFP}/libs/board_config
    ${ALIF_CMSIS_DFP}/se_services/include
    ${ALIF_CMSIS_DFP}/se_services/port/include
    ${ALIF_CMSIS_DFP}/se_services/templates
    ${ALIF_COMMON_APP_UTILS}/logging
    ${CMSIS_DIR}/CMSIS/Core/Include
    ${CMSIS_DIR}/CMSIS/Driver/Include
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/boards/${BOARD}
    )

  # Add SOC and core definitions to board target
  target_compile_definitions(${BOARD_TARGET} PUBLIC ${SOC_VARIANT})
  if(MCU_VARIANT STREQUAL "M55_HP")
    target_compile_definitions(${BOARD_TARGET} PUBLIC CORE_M55_HP)
    target_compile_definitions(${BOARD_TARGET} PUBLIC M55_HP)
    target_compile_definitions(${BOARD_TARGET} PUBLIC RTSS_HP)
    message(STATUS "Adding CORE_M55_HP to board target ${BOARD_TARGET}")
  elseif(MCU_VARIANT STREQUAL "M55_HE")
    target_compile_definitions(${BOARD_TARGET} PUBLIC CORE_M55_HE)
    target_compile_definitions(${BOARD_TARGET} PUBLIC M55_HE)
    target_compile_definitions(${BOARD_TARGET} PUBLIC RTSS_HE)
    message(STATUS "Adding CORE_M55_HE to board target ${BOARD_TARGET}")
  endif()

  update_board(${BOARD_TARGET})

  if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
    message(STATUS "Defining Linker options")

    # Linker script pre-processing
    set(LD_SCRIPT_PP "${CMAKE_CURRENT_BINARY_DIR}/linker_gnu_mram.ld")
    add_custom_command(TARGET ${BOARD_TARGET} PRE_LINK
       COMMAND ${CMAKE_C_COMPILER} -E -P -mcpu=cortex-m55 -mfloat-abi=hard
                                   -I ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/config
                                   -xc ${LD_SCRIPT}
                                   -o ${LD_SCRIPT_PP}
      )

    target_link_options(${BOARD_TARGET} PUBLIC
      "LINKER:--script=${LD_SCRIPT_PP}"
      --specs=nosys.specs
      -Wl,-Map=linker.map,--cref,-print-memory-usage,--gc-sections,--no-warn-rwx-segments
      )

    target_link_libraries(${BOARD_TARGET} PUBLIC
      -lm -lc -lgcc
      )

    target_compile_options(${BOARD_TARGET} PUBLIC
      -Wno-undef -Wno-strict-prototypes
      )
  endif ()

endfunction()

function(configure_freertos)

  if(MCU_VARIANT STREQUAL "M55_HP")
    add_compile_definitions(
      CORE_M55_HP
      M55_HP
      RTSS_HP
      CDC_STACK_SZIE=CDC_STACK_SIZE
      ) 
  elseif(MCU_VARIANT STREQUAL "M55_HE")
    add_compile_definitions(
      CORE_M55_HE
      M55_HE
      RTSS_HE
      CDC_STACK_SZIE=CDC_STACK_SIZE
      ) 
  endif()

  set(FREERTOS_HEAP 4 CACHE STRING "FreeRTOS heap implementation")
  set(FREERTOS_CONFIG_FILE_DIRECTORY ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/FreeRTOSConfig CACHE STRING "FreeRTOS configuration file")

  # Determine RTSS core directory based on MCU variant
  if(MCU_VARIANT STREQUAL "M55_HP")
    set(RTSS_CORE rtss_hp)
  elseif(MCU_VARIANT STREQUAL "M55_HE")
    set(RTSS_CORE rtss_he)
  endif()

  # WORKAROUND: Add the board folder to the include path for the entire directory.
  # The FreeRTOS kernel is built as a separate library and does not automatically
  # inherit the board's include path where RTE_Components.h is located.
  # This ensures the kernel compilation can find the required headers.
  # There is not such problem with latest FreeRTOSKernel but 10.5.1 is not working
  # without setting FREERTOS_CONFIG_FILE_DIRECTORY.

  include_directories(
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Include
    ${ALIF_CMSIS_DFP}/Alif_CMSIS/Source
    ${ALIF_CMSIS_DFP}/Device/core/${RTSS_CORE}/config
    ${ALIF_CMSIS_DFP}/Device/core/common/include
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/config
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/rte
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/include
    ${ALIF_CMSIS_DFP}/Device/soc/${SOC_VARIANT}/include/${RTSS_CORE}
    ${ALIF_CMSIS_DFP}/Device/system/include
    ${ALIF_CMSIS_DFP}/Boards/${BOARD_DFP_DIR}
    ${ALIF_CMSIS_DFP}/drivers/include
    ${ALIF_CMSIS_DFP}/libs/board_config
    ${ALIF_CMSIS_DFP}/se_services/include
    ${ALIF_CMSIS_DFP}/se_services/port/include
    ${ALIF_CMSIS_DFP}/se_services/templates
    ${CMSIS_DIR}/CMSIS/Core/Include
    ${CMSIS_DIR}/CMSIS/Driver/Include
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/boards/${BOARD}
    )

endfunction()


function(family_configure_example TARGET RTOS)

  if(MCU_VARIANT STREQUAL "M55_HP")
    add_compile_definitions(
      CORE_M55_HP
      M55_HP
    ) 
  elseif(MCU_VARIANT STREQUAL "M55_HE")
    add_compile_definitions(
      CORE_M55_HE
      M55_HE
      ) 
  endif()

  # Board target
  if (NOT RTOS STREQUAL zephyr)
    add_board_target(board_${BOARD})
    target_link_libraries(${TARGET} PUBLIC board_${BOARD})
  endif ()

  # Configure FreeRTOS heap if using FreeRTOS
  if (RTOS STREQUAL "freertos")
    configure_freertos()
  endif ()

  target_compile_definitions(${TARGET} PUBLIC
    CFG_TUSB_RHPORT0_MODE=OPT_MODE_DEVICE
    TUP_DCD_ENDPOINT_MAX=8
    TUD_OPT_RHPORT=0
    BOARD_TUD_MAX_SPEED=OPT_MODE_HIGH_SPEED
    CFG_TUSB_MEM_ALIGN=TU_ATTR_ALIGNED\(32\)
    CFG_TUSB_MEM_SECTION=__attribute__\(\(section\(\"usb_dma_buf\"\)\)\)
    UNICODE
    _UNICODE
    _DEBUG
    _RTE_
    )

  family_configure_common(${TARGET} ${RTOS})

  message(STATUS "Configuring family example for TARGET: ${TARGET}, RTOS: ${RTOS}, BOARD: ${BOARD}, BOARD_QUALIFIERS: ${BOARD_QUALIFIERS}")

  target_sources(${TARGET} PRIVATE
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/family.c
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../board.c
    )

  target_include_directories(${TARGET} PUBLIC
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../../
    ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/boards/${BOARD}
    )

  if (RTOS STREQUAL zephyr)
    if (CONFIG_SOC_SERIES_E1C)
      zephyr_linker_sources(SECTIONS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/usb_buf_section_e1c.ld)
    else ()
      zephyr_linker_sources(SECTIONS ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/usb_buf_section.ld)
    endif ()
  endif ()

  family_add_tinyusb(${TARGET} OPT_MCU_ALIF)

  target_sources(${TARGET} PRIVATE
    ${TOP}/src/portable/alif/ensemble/dcd_ensemble.c
    )

  # Workaround for Ensemble
  # Remove -ffunction-sections from global flags for all relevant languages
  foreach(var CMAKE_C_FLAGS CMAKE_CXX_FLAGS CMAKE_ASM_FLAGS)
    if(${var} MATCHES "-ffunction-sections")
      string(REPLACE "-ffunction-sections" "" new_flags "${${var}}")
      set(${var} "${new_flags}" CACHE STRING "Remove -ffunction-sections" FORCE)
    endif()
  endforeach()

endfunction()
