#!/usr/bin/env bash
# Based on a bash script for generating strong passwords for the Jitsi role in this ansible project:
# https://github.com/spantaleev/matrix-docker-ansible-deploy

generatePassword() {
    openssl rand -hex 16
}

usage() {
  echo "Usage: $0 matrix_domain element_subdomain client_email output_file"
}
DOMAIN="$1"; shift
if [ "" = "$DOMAIN" ]; then usage 2>&1; exit 1; fi
ELEMENT_SUBDOMAIN="$1"; shift
if [ "" = "$ELEMENT_SUBDOMAIN" ]; then usage 2>&1; exit 1; fi
CLIENT_EMAIL="$1"; shift
if [ "" = "$CLIENT_EMAIL" ]; then usage 2>&1; exit 1; fi
VARFILE="$1"; shift
if [ "" = "$VARFILE" ]; then usage 2>&1; exit 1; fi

cat <<VAREND > "$VARFILE"
# AWX Settings
matrix_awx_enabled: true
# Basic Settings
matrix_domain: $DOMAIN
matrix_ssl_lets_encrypt_support_email: chatoasis@protonmail.com
matrix_coturn_turn_static_auth_secret: $(generatePassword)
matrix_synapse_macaroon_secret_key: $(generatePassword)
# Element Settings
matrix_client_element_enabled: true
matrix_server_fqn_element: $ELEMENT_SUBDOMAIN.$DOMAIN
matrix_client_element_jitsi_preferredDomain: jitsi.$DOMAIN
# Element Extension
matrix_client_element_configuration_extension_json: |
  {
  "disable_3pid_login": true
  }
# End Element Extension
# Ma1sd Settings
matrix_ma1sd_enabled: true 
# Jitsi Settings
matrix_jitsi_enabled: true
matrix_jitsi_jicofo_component_secret: $(generatePassword)
matrix_jitsi_jicofo_auth_password: $(generatePassword)
matrix_jitsi_jvb_auth_password: $(generatePassword)
matrix_jitsi_jibri_recorder_password: $(generatePassword)
matrix_jitsi_jibri_xmpp_password: $(generatePassword)
# Synapse Settings
matrix_synapse_container_metrics_api_host_bind_port: 9000
matrix_synapse_metrics_enabled: true
matrix_synapse_metrics_port: 9100
matrix_synapse_allow_public_rooms_over_federation: true
matrix_synapse_enable_registration: false
matrix_synapse_rc_login:
    address:
        per_second: 50
        burst_count: 300
    account:
        per_second: 0.17
        burst_count: 300
    failed_attempts:
        per_second: 0.17
        burst_count: 3
# Synapse Extension
matrix_synapse_configuration_extension_yaml: |
  autocreate_auto_join_rooms: true
  mau_stats_only: true
  admin_contact: 'mailto:$CLIENT_EMAIL'
# End Synapse Extension
# PostgreSQL Settings
matrix_postgres_connection_password: $(generatePassword)
matrix_synapse_connection_password: $(generatePassword)
# Base Domain Settings
# Synapse Admin Settings
matrix_synapse_admin_enabled: false
# Matrix Shared Secret Auth
matrix_synapse_ext_password_provider_shared_secret_auth_enabled: false
matrix_synapse_ext_password_provider_shared_secret_auth_shared_secret: $(generatePassword)
# Matrix Corporal
matrix_corporal_enabled: false
matrix_corporal_http_api_enabled: false
matrix_corporal_reconciliation_user_id_local_part: "matrix-corporal"
# Matrix Corporal Policy Provider
# Extra Settings
matrix_vars_yml_snapshotting_enabled: false
VAREND


