#!/bin/sh

# purpose: list all 802.11s mesh parameters

parameters='retry_timeout confirm_timeout holding_timeout max_peer_links max_retries ttl element_ttl auto_open_plinks hwmp_max_preq_retries path_refresh_time min_discovery_timeout hwmp_active_path_timeout hwmp_preq_min_interval hwmp_net_diameter_traversal_time hwmp_rootmode hwmp_rann_interval gate_announcements fwding sync_offset_max_neighor rssi_threshold hwmp_active_path_to_root_timeout hwmp_root_interval hwmp_confirmation_interval power_mode awake_window plink_timeout'

for param in $parameters ; do
  echo -n "$param: "
  iw dev wlan0 get mesh_param "mesh_$param"
done
