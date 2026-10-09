---
%{ if kubelet_cloud_provider != "" ~}
# Run kubelet with --cloud-provider=external so an externally deployed cloud
# controller manager (CCM) can initialize each node, set spec.providerID, and
# clear the node.cloudprovider.kubernetes.io/uninitialized taint (OCTR-750).
cloud_provider: external
%{ endif ~}
%{ if external_cloud_provider != "" ~}
# Select a CCM managed by Kubespray. Leave this empty when GitOps owns the CCM.
external_cloud_provider: ${external_cloud_provider}
%{ endif ~}
# CoreDNS and its autoscaler must be schedulable before an external CCM clears
# the uninitialized taint; otherwise Flux cannot resolve or reach GitHub during
# bootstrap. These tolerations are harmless after node initialization.
dns_extra_tolerations:
  - key: node.cloudprovider.kubernetes.io/uninitialized
    operator: Exists
    effect: NoSchedule
dns_autoscaler_extra_tolerations:
  - key: node.cloudprovider.kubernetes.io/uninitialized
    operator: Exists
    effect: NoSchedule
metrics_server_extra_tolerations:
  - key: node.cloudprovider.kubernetes.io/uninitialized
    operator: Exists
    effect: NoSchedule
%{ if sysctl_file_path != "" ~}
sysctl_file_path: "${sysctl_file_path}"
%{ endif ~}
%{ if sysctl_ignore_unknown_keys != null ~}
sysctl_ignore_unknown_keys: ${sysctl_ignore_unknown_keys}
%{ endif ~}
%{ if length(additional_sysctl) > 0 ~}
additional_sysctl:
%{ for sysctl in additional_sysctl ~}
  - name: "${sysctl.name}"
    value: "${sysctl.value}"
%{ endfor ~}
%{ endif ~}
