# Common to host and target Java modules.

###########################################################
## .proto files: Compile proto files to .java
###########################################################
proto_sources := $(filter %.proto,$(LOCAL_SRC_FILES))
# Because names of the .java files compiled from .proto files are unknown until the
# .proto files are compiled, we use a timestamp file as depedency.
proto_java_sources_file_stamp :=
ifneq ($(proto_sources),)
proto_sources_fullpath := $(addprefix $(LOCAL_PATH)/, $(proto_sources))

# By putting the generated java files into $(LOCAL_INTERMEDIATE_SOURCE_DIR), they will be
# automatically found by the java compiling function transform-java-to-classes.jar.
proto_java_intemediate_dir := $(LOCAL_INTERMEDIATE_SOURCE_DIR)/proto
proto_java_sources_file_stamp := $(proto_java_intemediate_dir)/Proto.stamp
proto_java_sources_dir := $(proto_java_intemediate_dir)/src

$(proto_java_sources_file_stamp): PRIVATE_PROTO_INCLUDES := $(TOP)
$(proto_java_sources_file_stamp): PRIVATE_PROTO_SRC_FILES := $(proto_sources_fullpath)
$(proto_java_sources_file_stamp): PRIVATE_PROTO_JAVA_OUTPUT_DIR := $(proto_java_sources_dir)
ifeq ($(LOCAL_PROTOC_OPTIMIZE_TYPE),micro)
$(proto_java_sources_file_stamp): PRIVATE_PROTO_JAVA_OUTPUT_OPTION := --javamicro_out
else
  ifeq ($(LOCAL_PROTOC_OPTIMIZE_TYPE),nano)
$(proto_java_sources_file_stamp): PRIVATE_PROTO_JAVA_OUTPUT_OPTION := --javanano_out
  else
$(proto_java_sources_file_stamp): PRIVATE_PROTO_JAVA_OUTPUT_OPTION := --java_out
  endif
endif
$(proto_java_sources_file_stamp): PRIVATE_PROTOC_FLAGS := $(LOCAL_PROTOC_FLAGS)
$(proto_java_sources_file_stamp): PRIVATE_PROTO_JAVA_OUTPUT_PARAMS := $(LOCAL_PROTO_JAVA_OUTPUT_PARAMS)
$(proto_java_sources_file_stamp) : $(proto_sources_fullpath) $(PROTOC)
	$(call transform-proto-to-java)

#TODO: protoc should output the dependencies introduced by imports.
endif # proto_sources

#########################################
## Java resources

# Look for resource files in any specified directories.
# Non-java and non-doc files will be picked up as resources
# and included in the output jar file.
java_resource_file_groups :=

LOCAL_JAVA_RESOURCE_DIRS := $(strip $(LOCAL_JAVA_RESOURCE_DIRS))
ifneq ($(LOCAL_JAVA_RESOURCE_DIRS),)
  # This makes a list of words like
  #     <dir1>::<file1>:<file2> <dir2>::<file1> <dir3>:
  # where each of the files is relative to the directory it's grouped with.
  # Directories that don't contain any resource files will result in groups
  # that end with a colon, and they are stripped out in the next step.
  java_resource_file_groups += \
    $(foreach dir,$(LOCAL_JAVA_RESOURCE_DIRS), \
	$(subst $(space),:,$(strip \
		$(LOCAL_PATH)/$(dir): \
	    $(patsubst ./%,%,$(sort $(shell cd $(LOCAL_PATH)/$(dir) && \
		find . \
		    -type d -a -name ".svn" -prune -o \
		    -type f \
			-a \! -name "*.java" \
			-a \! -name "package.html" \
			-a \! -name "overview.html" \
			-a \! -name ".*.swp" \
			-a \! -name ".DS_Store" \
			-a \! -name "*~" \
			-print \
		    ))) \
	)) \
    )
  java_resource_file_groups := $(filter-out %:,$(java_resource_file_groups))
endif # LOCAL_JAVA_RESOURCE_DIRS

LOCAL_JAVA_RESOURCE_FILES := $(strip $(LOCAL_JAVA_RESOURCE_FILES))
ifneq ($(LOCAL_JAVA_RESOURCE_FILES),)
  java_resource_file_groups += \
    $(foreach f,$(LOCAL_JAVA_RESOURCE_FILES), \
	$(patsubst %/,%,$(dir $(f)))::$(notdir $(f)) \
     )
endif # LOCAL_JAVA_RESOURCE_FILES

ifdef java_resource_file_groups
  # The full paths to all resources, used for dependencies.
  java_resource_sources := \
    $(foreach group,$(java_resource_file_groups), \
	$(addprefix $(word 1,$(subst :,$(space),$(group)))/, \
	    $(wordlist 2,9999,$(subst :,$(space),$(group))) \
	) \
    )
  # The arguments to jar that will include these files in a jar file.
  # Quote the file name to handle special characters (such as #) correctly.
  extra_jar_args := \
    $(foreach group,$(java_resource_file_groups), \
	$(addprefix -C "$(word 1,$(subst :,$(space),$(group)))" , \
	    $(foreach w, $(wordlist 2,9999,$(subst :,$(space),$(group))), "$(w)" ) \
	) \
    )
  java_resource_file_groups :=
else
  java_resource_sources :=
  extra_jar_args :=
endif # java_resource_file_groups

######################################
## PRIVATE java vars
# LOCAL_SOURCE_FILES_ALL_GENERATED is set only if the module does not have static source files,
# but generated source files in its LOCAL_INTERMEDIATE_SOURCE_DIR.
# You have to set up the dependency in some other way.
need_compile_java := $(strip $(all_java_sources)$(all_res_assets)$(java_resource_sources))$(LOCAL_STATIC_JAVA_LIBRARIES)$(filter true,$(LOCAL_SOURCE_FILES_ALL_GENERATED))
ifdef need_compile_java

full_static_java_libs := \
    $(foreach lib,$(LOCAL_STATIC_JAVA_LIBRARIES), \
      $(call intermediates-dir-for, \
        JAVA_LIBRARIES,$(lib),$(LOCAL_IS_HOST_MODULE),COMMON)/javalib.jar)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_STATIC_JAVA_LIBRARIES := $(full_static_java_libs)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_RESOURCE_DIR := $(LOCAL_RESOURCE_DIR)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ASSET_DIR := $(LOCAL_ASSET_DIR)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CLASS_INTERMEDIATES_DIR := $(intermediates.COMMON)/classes
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_SOURCE_INTERMEDIATES_DIR := $(intermediates.COMMON)/src
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_JAVA_SOURCES := $(all_java_sources)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_RMTYPEDEFS := $(LOCAL_RMTYPEDEFS)

# full_java_libs: The list of files that should be used as the classpath.
#                 Using this list as a dependency list WILL NOT WORK.
# full_java_lib_deps: Should be specified as a prerequisite of this module
#                 to guarantee that the files in full_java_libs will
#                 be up-to-date.
ifndef LOCAL_IS_HOST_MODULE
ifeq ($(LOCAL_SDK_VERSION),)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH := -bootclasspath $(call java-lib-files,core-libart)
else
ifeq ($(LOCAL_SDK_VERSION)$(TARGET_BUILD_APPS),current)
# LOCAL_SDK_VERSION is current and no TARGET_BUILD_APPS.
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH := -bootclasspath $(call java-lib-files,android_stubs_current)
else ifeq ($(LOCAL_SDK_VERSION)$(TARGET_BUILD_APPS),system_current)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH := -bootclasspath $(call java-lib-files,android_system_stubs_current)
else
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH := -bootclasspath $(call java-lib-files,sdk_v$(LOCAL_SDK_VERSION))
endif # current or system_current
endif # LOCAL_SDK_VERSION

full_shared_java_libs := $(call java-lib-files,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
full_java_lib_deps := $(call java-lib-deps,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))

else # LOCAL_IS_HOST_MODULE

ifeq ($(USE_CORE_LIB_BOOTCLASSPATH),true)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH := -bootclasspath $(call java-lib-files,core-libart-hostdex,$(LOCAL_IS_HOST_MODULE))

full_shared_java_libs := $(call java-lib-files,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
full_java_lib_deps := $(call java-lib-deps,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE)) \
    $(full_shared_java_libs)
else
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH :=

full_shared_java_libs := $(addprefix $(HOST_OUT_JAVA_LIBRARIES)/,\
    $(addsuffix $(COMMON_JAVA_PACKAGE_SUFFIX),$(LOCAL_JAVA_LIBRARIES)))
full_java_lib_deps := $(full_shared_java_libs)
endif # USE_CORE_LIB_BOOTCLASSPATH
endif # !LOCAL_IS_HOST_MODULE

full_java_libs := $(full_shared_java_libs) $(full_static_java_libs) $(LOCAL_CLASSPATH)
full_java_lib_deps := $(full_java_lib_deps) $(full_static_java_libs) $(LOCAL_CLASSPATH)

ifndef LOCAL_IS_HOST_MODULE
# This is set by packages that are linking to other packages that export
# shared libraries, allowing them to make use of the code in the linked apk.
apk_libraries := $(sort $(LOCAL_APK_LIBRARIES) $(LOCAL_RES_LIBRARIES))
ifneq ($(apk_libraries),)
  link_apk_libraries := \
      $(foreach lib,$(apk_libraries), \
        $(call intermediates-dir-for, \
              APPS,$(lib),,COMMON)/classes.jar)

  # link against the jar with full original names (before proguard processing).
  full_shared_java_libs += $(link_apk_libraries)
  full_java_libs += $(link_apk_libraries)
  full_java_lib_deps += $(link_apk_libraries)
endif

# This is set by packages that contain instrumentation, allowing them to
# link against the package they are instrumenting.  Currently only one such
# package is allowed.
LOCAL_INSTRUMENTATION_FOR := $(strip $(LOCAL_INSTRUMENTATION_FOR))
ifdef LOCAL_INSTRUMENTATION_FOR
  ifneq ($(words $(LOCAL_INSTRUMENTATION_FOR)),1)
    $(error \
        $(LOCAL_PATH): Multiple LOCAL_INSTRUMENTATION_FOR members defined)
  endif

  link_instr_intermediates_dir.COMMON := $(call intermediates-dir-for, \
      APPS,$(LOCAL_INSTRUMENTATION_FOR),,COMMON)
  # link against the jar with full original names (before proguard processing).
  link_instr_classes_jar := $(link_instr_intermediates_dir.COMMON)/classes.jar
  full_java_libs += $(link_instr_classes_jar)
  full_java_lib_deps += $(link_instr_classes_jar)
endif  # LOCAL_INSTRUMENTATION_FOR
endif  # LOCAL_IS_HOST_MODULE

endif  # need_compile_java

# We may want to add jar manifest or jar resource files even if there is no java code at all.
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_EXTRA_JAR_ARGS := $(extra_jar_args)
jar_manifest_file :=
ifneq ($(strip $(LOCAL_JAR_MANIFEST)),)
jar_manifest_file := $(LOCAL_PATH)/$(LOCAL_JAR_MANIFEST)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_JAR_MANIFEST := $(jar_manifest_file)
else
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_JAR_MANIFEST :=
endif

##########################################################
ifndef LOCAL_IS_HOST_MODULE
## AAPT Flags
# aapt doesn't accept multiple --extra-packages flags.
# We have to collapse them into a single --extra-packages flag here.
LOCAL_AAPT_FLAGS := $(strip $(LOCAL_AAPT_FLAGS))
ifdef LOCAL_AAPT_FLAGS
ifeq ($(filter 0 1,$(words $(filter --extra-packages,$(LOCAL_AAPT_FLAGS)))),)
aapt_flags := $(subst --extra-packages$(space),--extra-packages@,$(LOCAL_AAPT_FLAGS))
aapt_flags_extra_packages := $(patsubst --extra-packages@%,%,$(filter --extra-packages@%,$(aapt_flags)))
aapt_flags_extra_packages := $(sort $(subst :,$(space),$(aapt_flags_extra_packages)))
LOCAL_AAPT_FLAGS := $(filter-out --extra-packages@%,$(aapt_flags)) \
    --extra-packages $(subst $(space),:,$(aapt_flags_extra_packages))
aapt_flags_extra_packages :=
aapt_flags :=
endif
endif

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_AAPT_FLAGS := $(LOCAL_AAPT_FLAGS) $(PRODUCT_AAPT_FLAGS)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_PACKAGE_NAME := $(LOCAL_MANIFEST_PACKAGE_NAME)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_INSTRUMENTATION_FOR := $(LOCAL_MANIFEST_INSTRUMENTATION_FOR)

ifdef aidl_sources
ALL_MODULES.$(my_register_name).AIDL_FILES := $(aidl_sources)
endif
endif  # !LOCAL_IS_HOST_MODULE

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_ALL_JAVA_LIBRARIES := $(full_java_libs)

ALL_MODULES.$(my_register_name).INTERMEDIATE_SOURCE_DIR := \
    $(ALL_MODULES.$(my_register_name).INTERMEDIATE_SOURCE_DIR) $(LOCAL_INTERMEDIATE_SOURCE_DIR)

###########################################################
# JACK
###########################################################
ifdef LOCAL_JACK_ENABLED
ifdef need_compile_java

full_static_jack_libs := \
    $(foreach lib,$(LOCAL_STATIC_JAVA_LIBRARIES), \
      $(call intermediates-dir-for, \
        JAVA_LIBRARIES,$(lib),$(LOCAL_IS_HOST_MODULE),COMMON)/classes.jack)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_STATIC_JACK_LIBRARIES := $(full_static_jack_libs)

ifndef LOCAL_IS_HOST_MODULE
ifeq ($(LOCAL_SDK_VERSION),)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES := $(call jack-lib-files,core-libart)
else
ifeq ($(LOCAL_SDK_VERSION)$(TARGET_BUILD_APPS),current)
# LOCAL_SDK_VERSION is current and no TARGET_BUILD_APPS.
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES := $(call jack-lib-files,android_stubs_current)
else ifeq ($(LOCAL_SDK_VERSION)$(TARGET_BUILD_APPS),system_current)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES := $(call jack-lib-files,android_system_stubs_current)
else
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES := $(call jack-lib-files,sdk_v$(LOCAL_SDK_VERSION))
endif # current or system_current
endif # LOCAL_SDK_VERSION

full_shared_jack_libs := $(call jack-lib-files,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
full_jack_lib_deps := $(call jack-lib-deps,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))

else # LOCAL_IS_HOST_MODULE

ifeq ($(USE_CORE_LIB_BOOTCLASSPATH),true)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES := $(call jack-lib-files,core-libart-hostdex,$(LOCAL_IS_HOST_MODULE))
full_shared_jack_libs := $(call jack-lib-files,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
full_jack_lib_deps := $(call jack-lib-deps,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
else
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_BOOTCLASSPATH_JAVA_LIBRARIES :=
full_shared_jack_libs := $(call jack-lib-deps,$(LOCAL_JAVA_LIBRARIES),$(LOCAL_IS_HOST_MODULE))
full_jack_lib_deps := $(full_shared_jack_libs)
endif # USE_CORE_LIB_BOOTCLASSPATH
endif # !LOCAL_IS_HOST_MODULE
full_jack_libs := $(full_shared_jack_libs) $(full_static_jack_libs) $(LOCAL_JACK_CLASSPATH)
full_jack_lib_deps += $(full_static_jack_libs) $(LOCAL_JACK_CLASSPATH)

ifndef LOCAL_IS_HOST_MODULE
# This is set by packages that are linking to other packages that export
# shared libraries, allowing them to make use of the code in the linked apk.
ifneq ($(apk_libraries),)
  link_apk_jack_libraries := \
      $(foreach lib,$(apk_libraries), \
        $(call intermediates-dir-for, \
              APPS,$(lib),,COMMON)/classes.jack)

  # link against the jar with full original names (before proguard processing).
  full_shared_jack_libs += $(link_apk_jack_libraries)
  full_jack_libs += $(link_apk_jack_libraries)
  full_jack_lib_deps += $(link_apk_jack_libraries)
endif

# This is set by packages that contain instrumentation, allowing them to
# link against the package they are instrumenting.  Currently only one such
# package is allowed.
ifdef LOCAL_INSTRUMENTATION_FOR
   # link against the jar with full original names (before proguard processing).
   link_instr_classes_jack := $(link_instr_intermediates_dir.COMMON)/classes.noshrob.jack
   full_jack_libs += $(link_instr_classes_jack)
   full_jack_lib_deps += $(link_instr_classes_jack)
endif  # LOCAL_INSTRUMENTATION_FOR
endif  # !LOCAL_IS_HOST_MODULE

# Propagate local configuration options to this target.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_ALL_JACK_LIBRARIES:= $(full_jack_libs)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_JARJAR_RULES := $(LOCAL_JARJAR_RULES)

endif  # need_compile_java
endif # LOCAL_JACK_ENABLED
