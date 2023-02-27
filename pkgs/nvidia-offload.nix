{ writeShellScriptBin,
  findutils,
  provider ? "NVIDIA-G0",
  glxVendor ? "nvidia",
  vkLayer ? "NVIDIA_only",
  libVaDriver ? "vdpau",
  vdpauDriver ? "nvidia"
}:
writeShellScriptBin "nvidia-offload" ''
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=${provider}
  export __GLX_VENDOR_LIBRARY_NAME=${glxVendor}
  export __VK_LAYER_NV_optimus=${vkLayer}
  export LIBVA_DRIVER_NAME="${libVaDriver}"
  export VDPAU_DRIVER="${vdpauDriver}"

  if [ -e /etc/NIXOS ]
  then
    export VK_ICD_FILENAMES=$(${findutils}/bin/find /run/opengl-driver/share/vulkan/icd.d -name nvidia_icd*)
  else
    export VK_ICD_FILENAMES=$(${findutils}/bin/find /usr/share/vulkan/icd.d -name nvidia_icd*)
  fi

  exec -a "$0" "$@"
''
