{ writeShellScriptBin,
  provider ? "NVIDIA-G0",
  glxVendor ? "nvidia",
  vkLayer ? "NVIDIA_only"
}:
writeShellScriptBin "nvidia-offload" ''
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=${provider}
  export __GLX_VENDOR_LIBRARY_NAME=${glxVendor}
  export __VK_LAYER_NV_optimus=${vkLayer}
  exec -a "$0" "$@"
''
