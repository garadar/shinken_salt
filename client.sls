###############################################################
#
#  This state target all shinken  to install:
#       - nrpe
#       - nagios-plugins
#
##############################################################
{% from "slurm/init.sls" import ClusterName %}
{% from "monitoring/init.sls" import shinken_version %}
{% from 'macros/lib.sls' import create_user with context %}
{% from 'macros/lib.sls' import create_group with context %}

{{ create_group('nrpe') }}
{{ create_user('nrpe', 'nrpe') }}

nrpe_pkg:
  pkg.installed:
    - pkgs:
      - nrpe


nrpe_config:
  file.managed:
    - source: salt://{{ tpldir }}/template/etc/nagios/nrpe.cfg
    - name: /etc/nagios/nrpe.cfg
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        ClusterName: {{ ClusterName }}
    - require:
      - pkg: nrpe_pkg

nrpe_sudoers:
  file.managed:
    - source: salt://{{ tpldir }}/files/etc/sudoers.d/nrpe
    - name: /etc/sudoers.d/nrpe
    - user: root
    - group: root
    - mode: "0600"
    - require:
      - pkg: nrpe_pkg

nrpe_command:
  file.managed:
    - source: salt://{{ tpldir }}/files/etc/nrpe.d/nrpe.cfg
    - name: /etc/nrpe.d/nrpe.cfg
    - user: root
    - group: root
    - mode: "0644"
    - require:
      - pkg: nrpe_pkg


nrpe_service:
  service.running:
    - name: nrpe
    - enable: True
    - reload: True
    - watch:
      - file: nrpe_config
      - file: nrpe_command

nagios_plugins_pkg:
  pkg.installed:
    - pkgs:
      - nagios-plugins-load
      - nagios-plugins-disk
      - nagios-plugins-nrpe
      - nagios-plugins-ping
      - nagios-plugins-snmp
      - nagios-plugins-dummy

nagios_plugins:
  file.recurse:
    - source: salt://{{ tpldir }}/files/usr/lib64/nagios/plugins
    - name: /usr/lib64/nagios/plugins
    - user: root
    - group: root
    - file_mode: "0655"

check_highstate_cron:
  file.managed:
    - source:  salt://{{ tpldir }}/files/etc/cron.d/check_highstate
    - name: /etc/cron.d/check_highstate
    - mode: '0600'
    - user: root
    - group: root

