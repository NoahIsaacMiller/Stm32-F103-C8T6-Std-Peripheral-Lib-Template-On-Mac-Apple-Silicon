# 设置CMake最低版本要求（兼容3.10及以上）
cmake_minimum_required(VERSION 3.10)

# 交叉编译配置：避免配置阶段链接失败
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# 引入ARM交叉编译工具链配置文件
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/arm-none-eabi-toolchain.cmake)

# 显式指定交叉编译工具
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)
set(CMAKE_SIZE arm-none-eabi-size)

# 定义项目名称
project(STM32-F103-C8T6 C ASM)

# --------------------------
# 核心配置（芯片与编译参数）
# --------------------------
set(MCU_FLAGS -mcpu=cortex-m3 -mthumb -mfloat-abi=soft)
set(LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/ld/stm32_flash.ld")

# --------------------------
# 头文件与源文件
# --------------------------
include_directories(
  ${CMAKE_SOURCE_DIR}/inc/driver
  ${CMAKE_SOURCE_DIR}/inc/user
  ${CMAKE_SOURCE_DIR}/src/system
)

set(SYSTEM_SRCS
  ${CMAKE_SOURCE_DIR}/src/system/startup_stm32f10x_md.s
  ${CMAKE_SOURCE_DIR}/src/system/core_cm3.c
  ${CMAKE_SOURCE_DIR}/src/system/system_stm32f10x.c
)

file(GLOB DRIVER_SRCS ${CMAKE_SOURCE_DIR}/driver/*.c)
file(GLOB USER_SRCS ${CMAKE_SOURCE_DIR}/src/user/*.c)

# --------------------------
# 编译与链接配置
# --------------------------
add_executable(${PROJECT_NAME}
  ${SYSTEM_SRCS}
  ${DRIVER_SRCS}
  ${USER_SRCS}
)

target_compile_options(${PROJECT_NAME} PRIVATE
  ${MCU_FLAGS} -Wall -Wextra -O2 -ffunction-sections -fdata-sections -std=c99
)

set_source_files_properties(
  ${CMAKE_SOURCE_DIR}/src/system/startup_stm32f10x_md.s
  PROPERTIES
  COMPILE_OPTIONS "${MCU_FLAGS};-xassembler-with-cpp"
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
  STM32F10X_MD USE_STDPERIPH_DRIVER
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
  SUFFIX ".elf"
)

target_link_options(${PROJECT_NAME} PRIVATE
  ${MCU_FLAGS} -T${LINKER_SCRIPT} -nostartfiles -nostdlib -Wl,--gc-sections
  -Wl,-Map=${PROJECT_NAME}.map
)


add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
  # 生成.bin文件
  COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:${PROJECT_NAME}>" firmware.bin
  
  # 烧录命令
  COMMAND echo "========================================================="
  COMMAND echo "烧录命令: st-flash write firmware.bin 0x08000000"
  COMMAND echo "========================================================="
  
  COMMENT "生成固件完成"
)