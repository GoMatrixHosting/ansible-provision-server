# Ansible Provision Server

The provision stage configures the environment that a subscription and Matrix service can exist in. 

Allows the client to select their base URL, element client URL, the DigitalOcean droplet location or to connect their own On-Premises server.


# Prerequisites

You need to setup the AWX system to use this playbook, see the [create-awx-system repository](https://gitlab.com/GoMatrixHosting/create-awx-system).


# DigitalOcean Mode

Allows a user to select the location of their DigitalOcean server.

- base_url - what URL the Matrix service will be based around. For a base_url of 'example.org' a homeserver at 'matrix.example.org' will be created.
- base_domain_used - whether the base_url has an existing website at it (true), or if you want the base_url to be hosted by the server (false).
- awx_element_subdomain - the subdomain the element client will intially be hosted at. (Eg: 'element' for element.example.org)
- do_droplet_region_long - a long string to represent the location of the droplet that will be created. Available regions:
	- 'New York City (USA)'
	- 'San Francisco (USA)'
	- 'Amsterdam (NLD)'
	- 'Frankfurt (DEU)'
	- 'Singapore (SGP)'
	- 'London (GBR)'
	- 'Toronto (CAN)'
	- 'Balgalore (IND)'


# On-Premises Mode

Allows a user to connect their own hardware, it must be a Debian 10 server and it must have the SSH public key loaded into it.

- base_url - see above.
- base_domain_used - see above.
- awx_element_subdomain - see above.
- server_ipv4 - the IPv4 address of the server to connect to AWX, at least one IP address must be defined.
- server_ipv6 - the IPv6 address of the server to connect to AWX, at least one IP address must be defined.


## License

    Copyright (C) 2021 GoMatrixHosting.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
