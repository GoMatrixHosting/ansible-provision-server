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
# Jitsi Settings
matrix_jitsi_enabled: true
matrix_jitsi_jicofo_component_secret: $(generatePassword)
matrix_jitsi_jicofo_auth_password: $(generatePassword)
matrix_jitsi_jvb_auth_password: $(generatePassword)
matrix_jitsi_jibri_recorder_password: $(generatePassword)
matrix_jitsi_jibri_xmpp_password: $(generatePassword)
# Synapse Settings
matrix_synapse_allow_public_rooms_over_federation: true
matrix_synapse_enable_registration: false
# Base Domain Settings
matrix_nginx_proxy_base_domain_homepage_enabled: false
# Extra Settings
matrix_vars_yml_snapshotting_enabled: false
VAREND


