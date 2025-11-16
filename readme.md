# STM32 F103 C8T6 项目模板

基于STM32 F103 C8T6 微控制器的嵌入式C语言项目模板，使用STM32标准外设库进行开发，并采用CMake构建系统进行项目管理。

## 项目概述

本项目模板提供了一个完整的STM32F103C8T6开发环境配置，包括：
- 基于STM32标准外设库的驱动代码
- CMake构建系统配置
- ARM Cortex-M3交叉编译工具链设置
- 内存映射和链接脚本
- 基本的项目结构和示例代码

## 硬件特性

- **微控制器**: STM32F103C8T6 (ARM Cortex-M3内核)
- **Flash容量**: 128KB
- **SRAM容量**: 20KB
- **工作频率**: 最高72MHz
- **封装形式**: LQFP48

## 软件环境

### 开发工具链

- **交叉编译工具**: ARM GCC (arm-none-eabi-gcc)
- **构建系统**: CMake 3.10+
- **调试工具**: st-link, openocd等
- **烧录工具**: st-flash

### 项目结构
```.
├── arm-none-eabi-toolchain.cmake  # 交叉编译工具链配置（必选）
├── CMakeLists.txt                # 主构建脚本（项目核心配置）
├── build/                        # 编译输出目录（自动生成，无需手动修改）
├── driver/                       # ST标准外设库驱动实现（官方源码）
├── inc/                          # 头文件总目录（分驱动层+用户层）
│   ├── driver/                   # 驱动头文件（与driver/目录一一对应）
│   └── user/                     # 用户应用头文件（自定义声明）
├── ld/                           # 链接器脚本（内存布局定义）
│   └── stm32f10x_flash.ld        # F103C8T6专属链接脚本
├── src/                          # 源代码总目录（系统核心+用户应用）
│   ├── system/                   # 系统启动与初始化代码
│   └── user/                     # 用户业务逻辑代码
└── readme.md                     # 项目说明（环境搭建、编译烧录教程）
```

## 快速开始

### 1. 环境准备

确保已安装以下工具：
- ARM GCC交叉编译工具链
- CMake 3.10或更高版本
- st-flash烧录工具（或其他适用的烧录工具）

### 2. 构建项目

```bash
# 创建构建目录
mkdir build && cd build

# 配置项目
cmake ..

# 编译项目
make
```

### 3. 烧录程序

编译完成后会生成`firmware.bin`文件，可以使用st-flash进行烧录：

```bash
st-flash write firmware.bin 0x08000000
```

## 代码结构说明

### 主要源文件

- `src/user/main.c`: 应用程序入口点
- `src/system/startup_stm32f10x_md.s`: 启动汇编代码
- `src/system/system_stm32f10x.c`: 系统初始化代码
- `src/system/core_cm3.c`: Cortex-M3内核外设访问层

### 配置文件

- `inc/user/stm32f10x_conf.h`: 外设驱动配置文件
- `inc/user/stm32f10x_it.h`: 中断处理函数声明
- `inc/driver/stm32f10x.h`: 芯片选择和基本配置

## 自定义开发

### 添加新的源文件

1. 在`src/user/`目录下添加新的C源文件
2. 如果需要，在`inc/user/`目录下添加相应的头文件
3. 在`CMakeLists.txt`中更新`USER_SRCS`变量（如果未使用自动扫描）

### 配置外设

通过修改`inc/user/stm32f10x_conf.h`文件来启用或禁用特定的外设驱动。

## 注意事项

1. 该项目默认配置为STM32F103C8T6（中等密度设备），如需更换其他型号，请相应调整配置。
2. 默认外部晶振频率为8MHz，如需更改请修改`stm32f10x.h`中的HSE_VALUE定义。
3. 链接脚本配置了128KB Flash和20KB RAM，请根据实际芯片规格进行调整。

## 许可证

本项目基于STM32标准外设库V3.5.1，遵循STMicroelectronics相关许可协议。