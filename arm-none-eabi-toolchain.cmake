# 目标系统配置，告知CMake当前为交叉编译，目标系统为通用嵌入式平台
# 设置目标系统名称为Generic（通用），适用于无操作系统的嵌入式环境
set(CMAKE_SYSTEM_NAME Generic)
# 设置目标系统版本为1（版本号在此场景下无实际意义，仅满足CMake要求）
set(CMAKE_SYSTEM_VERSION 1)
# 指定目标处理器架构为ARM，匹配STM32等ARM架构微控制器
set(CMAKE_SYSTEM_PROCESSOR arm)

# 定义交叉编译器的前缀，简化后续编译器及工具的路径设置
# arm-none-eabi-是针对ARM Cortex-M/R系列裸机开发的工具链前缀
set(TOOLCHAIN_PREFIX arm-none-eabi)

# 配置各类编译器及工具的路径
# 假设工具链的bin目录已添加到系统PATH环境变量，因此无需指定完整路径
# C编译器：使用ARM交叉编译工具链中的gcc
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
# C++编译器：使用ARM交叉编译工具链中的g++（如需支持C++开发可启用）
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
# 汇编器：使用ARM交叉编译工具链中的gcc作为汇编器前端（支持预处理）
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
# 目标文件复制工具：用于将ELF文件转换为二进制/十六进制文件
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy)
# 大小查看工具：用于分析目标文件各段的大小
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}-size)

# 工具链根目录设置，用于CMake查找工具链自带的库文件和头文件
# 此处示例路径为/opt/arm-none-eabi，实际应根据工具链安装位置修改
set(TOOLCHAIN_DIR /opt/arm-none-eabi)
# 将工具链目录设置为CMake查找根路径，优先在此目录下搜索资源
set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR})

# 配置CMake的查找规则，确保交叉编译时只使用目标工具链的资源
# 程序查找模式：NEVER表示不在目标系统路径中搜索程序（编译器等工具使用主机系统的）
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# 库文件查找模式：ONLY表示只在目标工具链路径中搜索库文件（避免链接主机系统的库）
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# 头文件查找模式：ONLY表示只在目标工具链路径中搜索头文件（确保使用嵌入式环境的头文件）
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# 包查找模式：ONLY表示只在目标工具链路径中搜索CMake包（适配嵌入式平台的包）
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)