
#
# INPUT: matrix_domain (via cli)
# PROCESSING: Check if this domain is already in use, return true if it has.
# OUTPUT: Boolean (True if imposter)
#

import sys
import os

matrix_domain = sys.argv[1]

used_domains = []

member_ids = os.listdir('/var/lib/awx/projects/clients/')

for member_id in member_ids:
  subscription_ids = os.listdir('/var/lib/awx/projects/clients/' + member_id)
#  print(subscription_ids)
  for subscription_id in subscription_ids:
  # Remove non-directory entries
#    print(subscription_id)
#    print(os.path.isdir('/var/lib/awx/projects/clients/' + member_id + '/' + subscription_id))
    if os.path.isdir('/var/lib/awx/projects/clients/' + member_id + '/' + subscription_id) == False:
      subscription_ids.remove(subscription_id)
#  print(subscription_ids)
  for subscription_id in subscription_ids:
  # collect those matrix_domains into a list
    file_path = '/var/lib/awx/projects/clients/' + member_id + '/' + subscription_id + '/server_vars.yml'
    if os.path.isfile(file_path):
      droplet_data = open(file_path,'r')
      #print(droplet_data.read())
      droplet_data_lines = droplet_data.readlines()
#    print(droplet_data_lines)
      for line in droplet_data_lines:
        if 'matrix_domain: ' in line:
          line = line.replace("\n", "")
          line = line.replace("matrix_domain: ", "")
          used_domains.append(line)

#print(used_domains)

if matrix_domain in used_domains:
  print("True")
elif matrix_domain not in used_domains:
  print("False")
