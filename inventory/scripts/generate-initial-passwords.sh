#!/usr/bin/env bash
# Based on a bash script for generating strong passwords for the Jitsi role in this ansible project:
# https://github.com/spantaleev/matrix-docker-ansible-deploy

generatePassword() {
    openssl rand -hex 16
}

usage() {
  echo "Usage: $0 matrix_domain output_file output_repo_file"
}
DOMAIN="$1"; shift
if [ "" = "$DOMAIN" ]; then usage 2>&1; exit 1; fi
VARFILE="$1"; shift
if [ "" = "$VARFILE" ]; then usage 2>&1; exit 1; fi

cat <<VAREND > "$VARFILE"
# Basic Settings
matrix_domain: $DOMAIN
matrix_ssl_lets_encrypt_support_email: chatoasis@protonmail.com
matrix_coturn_turn_static_auth_secret: $(generatePassword)
matrix_synapse_macaroon_secret_key: $(generatePassword)
# Element Settings
matrix_client_element_enabled: true
matrix_client_element_jitsi_preferredDomain: jitsi.$DOMAIN
# Element Extension
matrix_client_element_configuration_extension_json: |
  {
  "disable_3pid_login": true
  }
# End Element Extension
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
# Synapse Extension
matrix_synapse_configuration_extension_yaml: |
  admin_contact: 'mailto:chatoasis@protonmail.com'
  mau_stats_only: true
# End Synapse Extension
# PostgreSQL Settings
matrix_postgres_connection_hostname: matrix-postgres
matrix_postgres_db_name: synapse
matrix_postgres_connection_username: synapse
matrix_postgres_connection_password: $(generatePassword)
# Base Domain Settings
matrix_nginx_proxy_base_domain_homepage_enabled: false
matrix_well_known_matrix_server_enabled: false
# Extra Settings
matrix_vars_yml_snapshotting_enabled: false
VAREND


