###############################################################
#
#  This state target the master shinken and install:
#       - shinken-arbiter
#  And his own satellite
#       - shinken-poller
#       - shinken-broker
#       - shinken-scheduler
#
#  And Web Interface:
#       - Thruk
#         - require:
#           - state: apache
#
# Passive check are ran on the poller
#
#
##############################################################

### Import and variables ###


{% from 'macros/lib.sls'
     import create_user with context %}
{% from 'macros/lib.sls'
     import create_group with context %}

{% set monitor_user  = 'shinken' %}
{% set monitor_group = 'shinken' %}

### Include ###

include:
  - repo
  - monitoring.repo
  - firewalld
  - apache
  - monitoring.common

### Main ###

# Open port 7769 on the public zone interface
open_firewall_port:
  firewalld.present:
    - name: public
    - ports:
      - 7769/tcp
    - require:
      - pip: install_shinken

arbiter_cfg:
  file.recurse:
    - source:  salt://{{ tpldir }}/files/etc/shinken/
    - name: /etc/shinken/
    - require:
      - pip: install_shinken

