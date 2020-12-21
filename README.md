# Ansible Provision Server

Creates digitalocean droplet and space, performs initial setup, adds relevant playbooks to users account.

```
# IPO Summary:

INPUT: matrix_domain, do_droplet_region, plan_size, client_email, base_domain_used
PROCESSING: Spawns a DO droplet and DO space with that name. Or connects a users BYO server. Creates AWX account for client and generates matrix_vars.yml. Performs initial server setup.
OUTPUT: server_ipv4, server_ipv6

(see: https://developers.digitalocean.com/documentation/changelog/api-v2/new-size-slugs-for-droplet-plan-changes/)

Plan size	Slug		vCPUs	RAM	Disk	Transfer	Monthly Cost
"micro" 	s-1vcpu-2gb 	1 	2 GB 	50 GB 	2 TB 		$10
"small" 	s-2vcpu-4gb 	2 	4 GB 	80 GB 	4 TB 		$20
"medium"	s-4vcpu-8gb 	4 	8 GB 	160 GB 	5 TB 		$40
"large"		s-8vcpu-32gb 	8 	32 GB 	320 GB 	7 TB 		$80
"jumbo"		-	 	- 	- 	- 	- 		-

Relies on the following file on the AWX host: /var/lib/awx/hosting/hosting_vars.yml

do_api_token: value
do_spaces_access_key: value
do_spaces_secret_key: value
do_image_master: value
```
