#!/bin/bash

# STM32F103C8T6 项目管理工具
# 功能：一站式处理构建、烧录、重置等开发流程

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # 重置颜色

# 项目配置
PROJECT_NAME="STM32-F103-C8T6"
BUILD_DIR="build"
FIRMWARE_BIN="${BUILD_DIR}/firmware.bin"
FIRMWARE_ELF="${BUILD_DIR}/${PROJECT_NAME}.elf"
FLASH_ADDR="0x08000000"
SCRIPT_NAME=$(basename "$0")

# 日志函数(增强视觉区分)
log_info() {
    echo -e "${BLUE}• ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}${BOLD}$1${NC}"
}

log_warn() {
    echo -e "${YELLOW}! ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}${BOLD}$1${NC}" >&2
}

# 检查环境(工具、项目结构)
cmd_check() {
    log_info "检查开发环境..."
    
    # 检查必要工具
    local tools=("arm-none-eabi-gcc" "cmake" "make" "st-flash")
    local missing=()
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing+=("$tool")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少必要工具：${missing[*]}"
        log_info "安装建议："
        log_info "  - arm-none-eabi-gcc: brew install arm-none-eabi-gcc"
        log_info "  - stlink (含st-flash): brew install stlink"
        log_info "  - cmake: brew install cmake"
        exit 1
    fi
    
    # 检查项目结构
    local required_files=("CMakeLists.txt" "src")
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -e "$file" ]; then
            missing_files+=("$file")
        fi
    done
    if [ ${#missing_files[@]} -ne 0 ]; then
        log_error "项目结构不完整，缺少：${missing_files[*]}"
        log_info "请在项目根目录执行此脚本"
        exit 1
    fi
    
    log_success "环境检查通过"
}

# 清理构建产物
cmd_clean() {
    log_info "清理构建文件..."
    if [ -d "$BUILD_DIR" ]; then
        # 确认是否有内容需要清理
        if [ "$(ls -A "$BUILD_DIR" 2>/dev/null)" ]; then
            rm -rf "$BUILD_DIR"
            log_info "已删除构建目录：$BUILD_DIR"
        else
            log_info "构建目录为空，无需清理"
        fi
    else
        log_info "构建目录不存在，无需清理"
    fi
    log_success "清理完成"
}

# 编译项目(含配置)
cmd_build() {
    log_info "开始编译项目..."
    mkdir -p "$BUILD_DIR" || {
        log_error "无法创建构建目录：$BUILD_DIR"
        exit 1
    }
    cd "$BUILD_DIR" || {
        log_error "无法进入构建目录：$BUILD_DIR"
        exit 1
    }
    
    # 配置CMake(显示版本信息)
    log_info "正在配置CMake..."
    if cmake --version | grep -q "cmake version"; then
        if ! cmake ..; then
            log_error "CMake配置失败"
            cd .. && exit 1
        fi
    else
        log_error "CMake命令异常"
        cd .. && exit 1
    fi
    
    # 并行编译(自动适配CPU核心数)
    local jobs
    if jobs=$(nproc 2>/dev/null); then
        :
    elif jobs=$(sysctl -n hw.ncpu 2>/dev/null); then
        :
    else
        jobs=4
        log_warn "无法检测CPU核心数，使用默认4线程编译"
    fi
    log_info "使用 $jobs 线程编译..."
    if ! make -j"$jobs"; then
        log_error "编译失败"
        cd .. && exit 1
    fi
    
    cd .. || exit 1
    
    # 显示固件信息(格式化输出)
    log_info "固件信息："
    if [ -f "$FIRMWARE_ELF" ]; then
        arm-none-eabi-size "$FIRMWARE_ELF" | awk '
            NR==1 {printf "  %-6s %-6s %-6s %-6s %-6s %s\n", $1, $2, $3, $4, $5, $6}
            NR==2 {printf "  %-6d %-6d %-6d %-6d %-6x %s\n", $1, $2, $3, $4, $5, $6}
        '
    else
        log_warn "未找到ELF文件，可能编译不完整"
    fi
    log_success "编译完成 -> 输出文件：$FIRMWARE_BIN"
}

# 烧录固件到设备
cmd_flash() {
    log_info "准备烧录固件..."
    
    # 检查固件是否存在
    if [ ! -f "$FIRMWARE_BIN" ]; then
        log_error "未找到固件文件：$FIRMWARE_BIN"
        log_info "请先执行 ${BOLD}${SCRIPT_NAME} build${NC} 编译项目"
        exit 1
    fi
    
    # 检查设备连接
    log_info "检查ST-Link连接..."
    if ! st-info --probe &>/dev/null; then
        log_warn "未检测到ST-Link设备，尝试直接烧录..."
    fi
    
    # 执行烧录
    log_info "正在烧录到地址 $FLASH_ADDR..."
    if st-flash write "$FIRMWARE_BIN" "$FLASH_ADDR"; then
        log_success "固件已成功烧录到STM32F103C8T6"
    else
        log_error "烧录失败"
        log_info "排查建议："
        log_info "  1. 检查ST-Link与开发板连接"
        log_info "  2. 确认开发板供电正常"
        log_info "  3. 尝试先执行 ${BOLD}${SCRIPT_NAME} reset${NC} 重置设备"
        exit 1
    fi
}

# 重置设备
cmd_reset() {
    log_info "重置STM32设备..."
    if st-flash reset; then
        log_success "设备重置成功"
    else
        log_warn "重置失败，可能原因："
        log_warn "  - 设备未连接或供电异常"
        log_warn "  - ST-Link驱动问题"
    fi
}

# 完整流程(清理->编译->烧录)
cmd_full() {
    log_info "${BOLD}开始完整开发流程...${NC}"
    log_info "步骤：检查环境 -> 清理 -> 编译 -> 烧录"
    cmd_check && \
    cmd_clean && \
    cmd_build && \
    cmd_flash && \
    log_success "全流程执行完成！"
}

# 显示帮助信息
show_help() {
    echo -e "${BOLD}STM32F103C8T6 项目管理工具${NC}"
    echo "用于简化STM32开发中的编译、烧录等流程"
    echo
    echo -e "${BOLD}用法：${NC}${SCRIPT_NAME} <命令>"
    echo
    echo -e "${BOLD}命令列表：${NC}"
    echo "  check    检查开发环境(必备工具和项目结构)"
    echo "  clean    清理构建目录及中间文件"
    echo "  build    编译项目并生成固件(.elf和.bin)"
    echo "  flash    将固件烧录到STM32设备"
    echo "  reset    重置STM32设备"
    echo "  full     执行完整流程(check -> clean -> build -> flash)"
    echo "  help     显示此帮助信息"
    echo
    echo -e "${BOLD}示例：${NC}"
    echo "  ${SCRIPT_NAME} build   # 编译项目"
    echo "  ${SCRIPT_NAME} full    # 一键完成清理、编译和烧录"
}

# 主逻辑
if [ $# -ne 1 ]; then
    show_help
    exit 1
fi

case "$1" in
    check)  cmd_check ;;
    clean)  cmd_clean ;;
    build)  cmd_check; cmd_build ;;  # 编译前自动检查环境
    flash)  cmd_flash ;;
    reset)  cmd_reset ;;
    full)   cmd_full ;;
    help)   show_help ;;
    *)
        log_error "未知命令：$1"
        show_help
        exit 1
        ;;
esac