# STM32F103C8T6 标准外设库项目模板

基于STM32F103C8T6微控制器的嵌入式开发模板，集成STM32标准外设库（V3.6.0）与CMake构建系统，适配macOS Apple Silicon环境，提供完整的编译、烧录流程。


## 项目特点

- **开箱即用**：预置标准外设库核心驱动与初始化代码，无需手动移植
- **跨平台构建**：通过CMake实现一键配置，支持macOS/Linux系统
- **自动化工具链**：集成`f1flow`脚本，简化「编译→烧录→调试」全流程
- **规范结构**：分离驱动层与用户层代码，便于项目扩展与维护


## 硬件规格

| 参数                | 详情                          |
|---------------------|-------------------------------|
| 微控制器            | STM32F103C8T6（Cortex-M3）    |
| 主频                | 最高72MHz                     |
| 存储                | 64KB Flash / 20KB SRAM        |
| 外设                | GPIO、USART、SPI、I2C、定时器等 |
| 封装                | LQFP48                        |


## 软件环境

### 依赖工具

- **交叉编译器**：`arm-none-eabi-gcc`（版本10+）
- **构建工具**：`cmake`（3.10+）、`make`
- **烧录工具**：`st-link`（含`st-flash`）
- **推荐IDE**：VS Code（搭配C/C++、CMake Tools插件）


## 项目结构

```
.
├── arm-none-eabi-toolchain.cmake  # ARM交叉编译工具链配置
├── CMakeLists.txt                # 主构建脚本
├── f1flow                         # 自动化工作流脚本（编译/烧录）
├── driver/                       # 标准外设库驱动实现（.c）
├── inc/                          # 头文件目录
│   ├── driver/                   # 驱动头文件（.h）
│   └── user/                     # 用户应用头文件
├── ld/                           # 链接器脚本
│   └── stm32_flash.ld            # 内存布局定义（Flash/RAM分配）
├── src/                          # 源代码
│   ├── system/                   # 系统核心代码
│   │   ├── startup_stm32f10x_md.s # 启动汇编文件（中断向量表）
│   │   ├── system_stm32f10x.c    # 系统时钟初始化
│   │   └── core_cm3.c            # Cortex-M3内核函数
│   └── user/                     # 用户应用代码
│       ├── main.c                # 程序入口
│       └── stm32f10x_it.c        # 中断服务函数
└── .vscode/                      # VS Code配置（可选）
```


## 快速开始

### 1. 环境搭建

```bash
# 安装依赖（macOS示例，使用Homebrew）
brew install arm-none-eabi-gcc stlink cmake

# 克隆项目
git clone https://github.com/NoahIsaacMiller/Stm32-F103-C8T6-Std-Peripheral-Lib-Template-On-Mac-Apple-Silicon.git
cd Stm32-F103-C8T6-Std-Peripheral-Lib-Template-On-Mac-Apple-Silicon

# 赋予脚本执行权限
chmod +x f1flow
```


### 2. 构建与烧录

使用`f1flow`脚本管理全流程：

```bash
# 检查环境是否就绪
./f1flow check

# 编译项目（自动检查环境）
./f1flow build

# 烧录固件到开发板
./f1flow flash

# 一键执行：清理→编译→烧录
./f1flow full

# 重置开发板
./f1flow reset
```


## 开发指南

### 新增功能模块

1. 在`src/user/`下创建功能文件（如`lcd.c`）
2. 在`inc/user/`下创建对应头文件（如`lcd.h`）
3. 在`main.c`中包含头文件并调用功能函数


### 配置外设

1. 打开`inc/user/stm32f10x_conf.h`
2. 取消对应外设的注释以启用驱动（如`#define USE_STDPERIPH_GPIO`）
3. 在用户代码中初始化外设（参考标准外设库示例）


### 调整系统时钟

默认使用8MHz外部晶振（HSE），通过PLL倍频至72MHz。如需修改：

1. 编辑`src/system/system_stm32f10x.c`
2. 调整`SetSysClockTo72()`函数中的PLL配置参数


## 注意事项

1. **芯片型号匹配**：本模板默认适配STM32F103C8T6（中等密度设备），如需使用其他F1系列芯片，需修改：
   - `CMakeLists.txt`中的`STM32F10X_MD`定义
   - 链接器脚本`ld/stm32_flash.ld`中的Flash/RAM容量

2. **固件大小限制**：STM32F103C8T6 Flash为64KB，编译时注意`text`段大小不超过此限制

3. **调试建议**：使用VS Code的`launch.json`配置OpenOCD调试，需配合ST-Link V2调试器


## 许可证

本项目基于STM32标准外设库V3.6.0构建，遵循STMicroelectronics的许可协议。用户代码部分采用MIT许可。