# 保留完整日志输出
setenv bootargs "console=ttyS2,115200n8 rootwait rw rootfstype=ext4"

# 【防御】确保加载地址变量存在，若 U-Boot 未预设则使用 RK3036 安全默认值
# 0x62000000: zImage 安全加载区 (避开 SPL/ATF 保留内存)
# 0x61f00000: DTB 安全加载区 (与 zImage 保持 1MB 间距防止覆盖)
test -n "${kernel_addr_r}" || setenv kernel_addr_r 0x62000000
test -n "${fdt_addr_r}"    || setenv fdt_addr_r    0x61f00000

# 防呆设计：自动探测 SD 卡设备号
if fatload mmc 0:1 ${kernel_addr_r} zImage; then
    setenv bootargs "${bootargs} root=/dev/mmcblk0p2"
    setenv mmcdev 0
else
    if fatload mmc 1:1 ${kernel_addr_r} zImage; then
        setenv bootargs "${bootargs} root=/dev/mmcblk1p2"
        setenv mmcdev 1
    else
        echo "ERROR: zImage not found on mmc0 or mmc1!"
        reset
    fi
fi

# DTB 加载校验
if ! fatload mmc ${mmcdev}:1 ${fdt_addr_r} rk3036-evb.dtb; then
    echo "ERROR: Failed to load rk3036-evb.dtb from mmc${mmcdev}:1!"
    reset
fi

bootz ${kernel_addr_r} - ${fdt_addr_r}