#!/system/bin/sh

BB=/sbin/bb/busybox

############################
# Custom Kernel Settings for FusterCluck Kernel!!
# Adpted from RenderBroken's Script.
#

# mpdecision shouldn't be running, but stop it just in case it is.
stop mpdecision
echo "[FusterCluck-Kernel] Boot Script Started" | tee /dev/kmsg

############################
# Intelli_Plug Settings
#
# Give Intelliplug access for power HAL
chmod 0222 /sys/kernel/intelli_plug/perf_boost
chown system system /sys/kernel/intelli_plug/perf_boost
chmod 0666 /sys/module/intelli_plug/parameters/nr_run_profile_sel
chown system system /sys/module/intelli_plug/parameters/nr_run_profile_sel

# Turn on Intelliplug by default
echo 1 > /sys/module/intelli_plug/parameters/intelli_plug_active

# Limit max screen off frequency
echo 1497600 > /sys/module/intelli_plug/parameters/screen_off_max


############################
# MSM_Hotplug Settings
#
echo 1 > /sys/module/msm_hotplug/min_cpus_online
echo 2 > /sys/module/msm_hotplug/cpus_boosted
echo 500 > /sys/module/msm_hotplug/down_lock_duration
echo 2500 > /sys/module/msm_hotplug/boost_lock_duration
echo 200 5:100 50:50 350:200 > /sys/module/msm_hotplug/update_rates
echo 100 > /sys/module/msm_hotplug/fast_lane_load
echo 1 > /sys/module/msm_hotplug/max_cpus_online_susp

############################
# Tweak Background Writeout
#
echo 200 > /proc/sys/vm/dirty_expire_centisecs
echo 40 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 10 > /proc/sys/vm/swappiness

############################
# Set TCP Congestion
#
echo westwood > /proc/sys/net/ipv4/tcp_congestion_control

############################
# Power Effecient Workqueues (Enable for battery)
#
echo 1 > /sys/module/workqueue/parameters/power_efficient

############################
# CPU Multi-Core Power Savint (Enable for battery)
#

echo 1 > /sys/devices/system/cpu/sched_mc_power_savings

############################
# MSM Limiter
#
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_0
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_1
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_2
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_3
echo 1958400 > /sys/kernel/msm_limiter/resume_max_freq_0
echo 1958400 > /sys/kernel/msm_limiter/resume_max_freq_1
echo 1958400 > /sys/kernel/msm_limiter/resume_max_freq_2
echo 1958400 > /sys/kernel/msm_limiter/resume_max_freq_3
echo 1958400 > /sys/kernel/msm_limiter/live_max_freq_0
echo 1958400 > /sys/kernel/msm_limiter/live_max_freq_1
echo 1958400 > /sys/kernel/msm_limiter/live_max_freq_2
echo 1958400 > /sys/kernel/msm_limiter/live_max_freq_3
echo 1497000 > /sys/kernel/msm_limiter/suspend_max_freq

############################
# Scheduler and Read Ahead
#
echo zen > /sys/block/mmcblk0/queue/scheduler
echo 1024 > /sys/block/mmcblk0/bdi/read_ahead_kb

############################
# GPU Governor
#
echo 389000000 > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/max_freq

############################
# Governor Tunings
#
echo ondemand > /sys/kernel/msm_limiter/scaling_governor_0
echo 95 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
echo 75 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
echo 85 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load

echo interactive > /sys/kernel/msm_limiter/scaling_governor_0
echo 20000 1400000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
echo 90 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
echo 1190400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
echo 85 1500000:90 1800000:70 > /sys/devices/system/cpu/cpufreq/interactive/target_loads
echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
echo 30000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
echo 100000 > /sys/devices/system/cpu/cpufreq/interactive/max_freq_hysteresis
echo 30000 > /sys/devices/system/cpu/cpufreq/interactive/timer_slack

echo impulse > /sys/kernel/msm_limiter/scaling_governor_0
echo 20000 1400000:40000 1700000:20000 > /sys/devices/system/cpu/cpufreq/impulse/above_hispeed_delay
echo 95 > /sys/devices/system/cpu/cpufreq/impulse/go_hispeed_load
echo 1190400 > /sys/devices/system/cpu/cpufreq/impulse/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpufreq/impulse/io_is_busy
echo 85 1500000:90 1800000:70 > /sys/devices/system/cpu/cpufreq/impulse/target_loads
echo 40000 > /sys/devices/system/cpu/cpufreq/impulse/min_sample_time
echo 30000 > /sys/devices/system/cpu/cpufreq/impulse/timer_rate
echo 100000 > /sys/devices/system/cpu/cpufreq/impulse/max_freq_hysteresis
echo 30000 > /sys/devices/system/cpu/cpufreq/impulse/timer_slack
echo 1 > /sys/devices/system/cpu/cpufreq/impulse/powersave_bias

echo 652800 > /sys/devices/system/cpu/cpufreq/smartmax/suspend_ideal_freq
echo 1497600 > /sys/devices/system/cpu/cpufreq/smartmax/touch_poke_freq
echo 1036800 > /sys/devices/system/cpu/cpufreq/smartmax/awake_ideal_freq
echo 1497600 > /sys/devices/system/cpu/cpufreq/smartmax/boosot_freq

############################
# LMK Tweaks
#
echo 2560,4096,8192,16384,24576,32768 > /sys/module/lowmemorykiller/parameters/minfree
echo 32 > /sys/module/lowmemorykiller/parameters/cost

############################
# Disable Debugging
#
echo "0" > /sys/module/kernel/parameters/initcall_debug;
echo "0" > /sys/module/alarm_dev/parameters/debug_mask;
echo "0" > /sys/module/binder/parameters/debug_mask;
echo "0" > /sys/module/xt_qtaguid/parameters/debug_mask;
echo "[FusterCluck-Kernel] disable debug mask" | tee /dev/kmsg

############################
# TCP Stack Tweaks
#
#   Define TCP buffer sizes for various networks
#   ReadMin, ReadInitial, ReadMax, WriteMin, WriteInitial, WriteMax,
    setprop net.tcp.buffersize.default 4096,87380,110208,4096,16384,110208
    setprop net.tcp.buffersize.lte     524288,1048576,2097152,262144,524288,1048576
    setprop net.tcp.buffersize.umts    4094,87380,110208,4096,16384,110208
    setprop net.tcp.buffersize.hspa    4094,87380,1220608,4096,16384,1220608
    setprop net.tcp.buffersize.hsupa   4094,87380,1220608,4096,16384,1220608
    setprop net.tcp.buffersize.hsdpa   4094,87380,1220608,4096,16384,1220608
    setprop net.tcp.buffersize.hspap   4094,87380,1220608,4096,16384,1220608
    setprop net.tcp.buffersize.edge    4093,26280,35040,4096,16384,35040
    setprop net.tcp.buffersize.gprs    4092,8760,11680,4096,8760,11680
    setprop net.tcp.buffersize.evdo    4094,87380,262144,4096,16384,262144

#   Assign TCP buffer thresholds to be ceiling value of technology maximums
#   Increased technology maximums should be reflected here.
    write /proc/sys/net/core/rmem_max  2097152
    write /proc/sys/net/core/wmem_max  2097152

############################
# Kernel Same Page Merging
#
echo 1 > /sys/kernel/mm/ksm/run
echo 1 > /sys/kernel/mm/ksm/deferred_timer
echo 300 > /sys/kernel/mm/ksm/pages_to_scan
echo 500 > /sys/kernel/mm/ksm/sleep_milliseconds


############################
# MSM Theral Controls
#
# I like to setup 3 degrees below defaults, for safety.

echo 68 > /sys/kernel/msm_thermal/conf/allowed_low_high
echo 65 > /sys/kernel/msm_thermal/conf/allowed_low_low
echo 1497600 > /sys/kernel/msm_thermal/conf/allowed_low_freq 
echo 75 > /sys/kernel/msm_thermal/conf/allowed_mid_high 
echo 69 > /sys/kernel/msm_thermal/conf/allowed_mid_low 
echo 960000 > /sys/kernel/msm_thermal/conf/allowed_mid_freq 
echo 81 > /sys/kernel/msm_thermal/conf/allowed_max_high 
echo 76 > /sys/kernel/msm_thermal/conf/allowed_max_low
echo 300000 > /sys/kernel/msm_thermal/conf/allowed_max_freq 
echo 400 > /sys/kernel/msm_thermal/conf/poll_ms 
echo 82 > /sys/kernel/msm_thermal/conf/shutdown_temp 

############################
# Set Intelliactive as default governor
#

echo intelliactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo intelliactive > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo intelliactive > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo intelliactive > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

############################
# Set Sound Defaults
#
# Thses are just my sound preferences, set thema as you like.

echo 6 > /sys/devices/virtual/misc/soundcontrol/speaker_boost
echo 2 > /sys/devices/virtual/misc/soundcontrol/volume_boost

############################
# Limit GPU to 389mhz to save some power.
#

echo 389000000 > /sys/devices/fdb00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/max_gpuclk


echo "[FusterCluck-Kernel] Boot Script Completed!" | tee /dev/kmsg
