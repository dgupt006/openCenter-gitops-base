installation:
  enabled: true
  kubernetesProvider: ""
  # OpenStack nodes using an external cloud provider remain tainted until the
  # GitOps-managed CCM initializes them. Calico must become ready before Flux
  # can install that CCM, so every operator-managed control-plane workload
  # must tolerate the temporary bootstrap taint.
  controlPlaneTolerations:
    - key: node.cloudprovider.kubernetes.io/uninitialized
      operator: Exists
      effect: NoSchedule
  calicoNetwork:
    windowsDataplane: "${windows_dataplane}"
    nodeAddressAutodetectionV4:
%{ if calico_interface_autodetect == "interface" ~}
      interface: "${cni_iface}"
%{ endif ~}
%{ if calico_interface_autodetect == "cidr" ~}
      cidrs:
        - "${calico_interface_autodetect_cidr}"
%{ endif ~}
%{ if calico_interface_autodetect == "first-found" ~}
      firstFound: true
%{ endif ~}
    ipPools:
      - cidr: "${subnet_pods}"
        encapsulation: "${calico_encapsulation_type}"
        natOutgoing: ${calico_nat_outgoing}
  serviceCIDRs:
    - "${subnet_services}"

# Preserve the module's historical explicit Kubernetes API endpoint by default.
# Set kubernetes_service_endpoint_enabled to false to use the in-cluster
# Kubernetes service endpoint instead.
%{ if kubernetes_service_endpoint_enabled ~}
kubernetesServiceEndpoint:
  host: "${k8s_internal_ip}"
  port: "${k8s_api_port}"
%{ endif ~}
