# Copyright (C) 2014-2015 UBER
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

################
#Strict Aliasing
################
LOCAL_DISABLE_STRICT := \
	libc_bionic \
	libc_dns \
	libc_tzcode \
	libziparchive \
	libtwrpmtp \
	libfusetwrp \
	libguitwrp \
	busybox \
	libuclibcrpc \
	libziparchive-host \
	libpdfiumcore \
	libandroid_runtime \
	libmedia \
	libpdfiumcore \
	libpdfium \
	bluetooth.default \
	logd \
	mdnsd \
	net_net_gyp \
	libstagefright_webm \
	libaudioflinger \
	libmediaplayerservice \
	libstagefright \
	ping \
	ping6 \
	libdiskconfig \
	libjavacore \
	libfdlibm \
	libvariablespeed \
	librtp_jni \
	libwilhelm \
	libdownmix \
	libldnhncr \
	libqcomvisualizer \
	libvisualizer \
	libutils \
	libandroidfw \
	dnsmasq \
	static_busybox \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support \
	content_content_renderer_gyp \
	third_party_WebKit_Source_modules_modules_gyp \
	third_party_WebKit_Source_platform_blink_platform_gyp \
	third_party_WebKit_Source_core_webcore_remaining_gyp \
	third_party_angle_src_translator_lib_gyp \
	third_party_WebKit_Source_core_webcore_generated_gyp \
	libc_gdtoa \
	libc_openbsd \
	libc \
	libc_nomalloc \
	patchoat \
	dex2oat \
	libart \
	libart-compiler \
	oatdump \
	libart-disassembler \
	linker \
	camera.msm8084 \
	mm-vdec-omx-test \
	libc_malloc \
	mdnsd \
	libstagefright_webm \
	libc_bionic_ndk \
	libc_dns \
	libc_gdtoa \
	libc_openbsd_ndk \
	liblog \
	libc \
	libbt-brcm_stack \
	libbt-vendor \
	libbluetooth_jni \
	gatt_testtool \
	libavmediaserviceextensions \
	libqsap_sdk \
	wpa_supplicant \
	libstlport \
	libwifi-hal-qcom \
	libandroid_runtime \
	libandroidfw \
	libosi \
	libnetlink \
	clatd \
	ip \
	libc_nomalloc \
	linker \
	sensors.flounder \
	libnvvisualizer \
	libskia \
	fio \
	tcpdump

LOCAL_FORCE_DISABLE_STRICT := \
	libziparchive-host \
	libziparchive \
	libdiskconfig \
	logd \
	libjavacore \
	camera.msm8084 \
	libstagefright_webm \
	libc_bionic_ndk \
	libc_dns \
	libc_gdtoa \
	libc_openbsd_ndk \
	liblog \
	libc \
	libbt-brcm_stack \
	libandroid_runtime \
	libandroidfw \
	libosi \
	libnetlink \
	clatd \
	ip \
	libc_nomalloc \
	linker \
	libc_malloc \
	sensors.flounder \
	libnvvisualizer \
	fio \
	tcpdump \
	libavmediaserviceextensions

DISABLE_STRICT := \
	-fno-strict-aliasing

STRICT_ALIASING_FLAGS := \
	-fstrict-aliasing \
	-Werror=strict-aliasing

STRICT_GCC_LEVEL := \
	-Wstrict-aliasing=3

STRICT_CLANG_LEVEL := \
	-Wstrict-aliasing=2

###############
# Krait Tunings
###############
LOCAL_DISABLE_KRAIT := \
	libc_dns \
	libc_tzcode \
	bluetooth.default \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support

KRAIT_FLAGS := \
	-mcpu=cortex-a15 \
	-mtune=cortex-a15

#############
# GCC Tunings
#############
LOCAL_DISABLE_GCCONLY := \
	bluetooth.default \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support

ifeq (arm,$(TARGET_ARCH))
GCC_ONLY := \
	-fira-loop-pressure \
	-fforce-addr \
	-funsafe-loop-optimizations \
	-funroll-loops \
	-ftree-loop-distribution \
	-fsection-anchors \
	-ftree-loop-im \
	-ftree-loop-ivcanon \
	-ffunction-sections \
	-fgcse-las \
	-fgcse-sm \
	-fweb \
	-ffp-contract=fast \
	-mvectorize-with-neon-quad
else
GCC_ONLY := \
	-fira-loop-pressure \
	-fforce-addr \
	-funsafe-loop-optimizations \
	-funroll-loops \
	-ftree-loop-distribution \
	-fsection-anchors \
	-ftree-loop-im \
	-ftree-loop-ivcanon \
	-ffunction-sections \
	-fgcse-las \
	-fgcse-sm \
	-fweb \
	-ffp-contract=fast
endif

##########
# GRAPHITE
##########
LOCAL_DISABLE_GRAPHITE := \
	libunwind \
	libFFTEm \
	libicui18n \
	libskia \
	libvpx \
	libmedia_jni \
	libstagefright_mp3dec \
	libart \
	libstagefright_amrwbenc \
	libpdfium \
	libpdfiumcore \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support \
	libjni_filtershow_filters \
	fio \
	libwebrtc_spl \
	libpcap \
	libFraunhoferAAC \
	libhwui \
	libavcodec \
	libavformat \
	libswscale

GRAPHITE_FLAGS := \
	-fgraphite \
	-fgraphite-identity \
	-floop-flatten \
	-floop-parallelize-all \
	-ftree-loop-linear \
	-floop-interchange \
	-floop-strip-mine \
	-floop-block

######
# Pipe
######
LOCAL_DISABLE_PIPE := \
	libc_dns \
	libc_tzcode \
	$(NO_OPTIMIZATIONS)

#################
# Memory Sanitize
#################
DISABLE_SANITIZE_LEAK := \
	libc_dns \
	libc_tzcode \
	$(NOOP_BLUETOOTH) \
	$(NO_OPTIMIZATIONS)

################
# Cortex Tuning
################
LOCAL_DISABLE_CORTEX := \
	bluetooth.default 

ifeq (arm,$(TARGET_ARCH))
CORTEX_FLAGS := \
        -mcpu=cortex-a57.cortex-a53 \
        -mtune=cortex-a57.cortex-a53
endif

# OpenMP
ifeq ($(ENABLE_GOMP),true)
LOCAL_DISABLE_GOMP := \
	libblas \
	libblasV8 \
	libF77blas \
	libF77blasV8 \
	libc_tzcode \
	libjni_latinime \
	libmedia \
	libnetd_client \
	libscrypt_static \
	libperfprofdcore \
	libperfprofdutils \
	libpng \
	libstagefright \
	libstagefright_mediafilter \
	perfprofd \
	$(NO_OPTIMIZATIONS)

 ifneq ($(filter arm arm64,$(TARGET_ARCH)),)
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
   ifeq ($(filter $(LOCAL_DISABLE_GOMP), $(LOCAL_MODULE)),)
    ifdef LOCAL_CFLAGS
     LOCAL_CFLAGS += -fopenmp
    else
     LOCAL_CFLAGS := -fopenmp
    endif
   endif
  endif
 endif
endif

NO_OPTIMIZATIONS += \
	libandroid_runtime_32 \
	libbinder \
	libbypass \
	libc_tzcode \
	libc++ \
	libc++abi \
	libcrypto \
	libcrypto-host_32 \
	libcompiler_rt \
	libdex \
	libfdlibm \
	libft2 \
	libFraunhoferAAC \
	libharfbuzz_ng \
	libharfbuzz_ng_32 \
	libhwui \
	libicui18n \
	libinput \
	libjni_latinime_common_static \
	libloc_core \
	liblog \
	libmedia_jni \
	libmm-qcamera \
	libmmcamera_interface \
	libmmjpeg_interface_32 \
	libmmcamera_interface_32 \
	libmmjpeg_interface \
	libmcldScript \
	libmcldMC \
	libmedia_jni \
	libmedia_jni_32 \
	libmincrypt \
	libnativebridge \
	libnfc-nci_32 \
	libnfc-nci \
	libnfc_nci_jni \
	libpcap \
	libpdfiumcore \
	libpdfium \
	libperfprofdcore \
	libqdutils \
	libqomx_core \
	libpdfiumcore_32 \
	libRSCpuRef \
	libRSDriver \
	libRSSupport \
	libril \
	librilutils \
	librilutils_static \
	libscrypt_static \
	libsfntly \
	libskia \
	libsqlite_jni_32 \
	libselinux \
	libsfntly \
	libssh \
	libwebrtc_spl \
	libwebp-decode \
	libwebp-encode \
	libxml2 \
	fsck.f2fs \
	linker \
	logd \
	logcat \
	make_f2fs \
	mm-qcamera-app \
	mm-qcamera-app_32 \
	mm-jpeg-interface-test \
	mm-qcamera-app \
	mdnsd \
	nfc_nci.bcm2079x.default \
	netd \
	pppd \
	racoon \
	rsg-generator
