# 使用 $(BR2_EXTERNAL) 安全包含外部包
include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*.mk))