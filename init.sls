#
{% from "slurm/init.sls" import ClusterName %}
{% set shinken_version = salt['pillar.get']('shinken:pkg:version') %}

############################## README #####################################
#
#   - Pillar roles:shinken_master has to be defined for the shinken master
#
#   - Pillar roles:shinken_poller has to be defined for each satellite.
#     (The master can be also a poller)
#
#   - Pillar roles:shinken_thruk has to be defined for server hosting
#     monitoring web GUI.
#
###########################################################################



include:
{% if salt['pillar.get']('roles:shinken_poller', false) is sameas false %}
  - monitoring.common
{% endif %}
{% if salt['pillar.get']('roles:shinken_master', false) is sameas false %}
  - monitoring.master
{% endif%}
{% if salt['pillar.get']('roles:shinken_thruk', false) is sameas false %}
  - monitoring.thruk
{% endif%}
  - monitoring.client

