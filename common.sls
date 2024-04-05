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


### Main ###

{{ create_group( monitor_user ) }}
{{ create_user( monitor_user, monitor_group) }}

# Ensure required packages are installed
install_dependencies:
  pkg.installed:
    - names:
      - python2
      - python2-pip
      - python2-devel
      - gcc
      - libcurl-devel
      - openssl-devel

# Set alternative python to python2
python_alternative:
  alternatives.set:
    - name: python
    - path: /usr/bin/python2
    - require:
      - pkg: install_dependencies


# Install pycurl with specified SSL backend using cmd (pip is bugged)
install_pycurl:
  cmd.run:
    - name: PYCURL_SSL_LIBRARY=openssl pip2 install pycurl==7.43.0.4 --compile --no-cache-dir
    - unless: pip2 list 2>1|grep -q pycurl
    - require:
      - alternatives: python_alternative


# Install Shinken
install_shinken:
  pip.installed:
    - name: shinken
    - pip_bin: /usr/bin/pip2
    - extra_args:
    - require:
      - cmd: install_pycurl
      - group: macro_{{ monitor_group }}___group
      - user: macro_{{ monitor_group }}___user


# Initialize Shinken
init_shinken:
  cmd.run:
    - name: shinken --init
    - unless: shinken inventory |grep -q livestatus
    - require:
      - cmd: install_pycurl
      - pip: install_shinken

# Install Shinken modules
{% for module in salt['pillar.get']('monitoring:shinken_modules', []) %}
install_shinken_{{ module }}:
  cmd.run:
    - name: shinken install {{ module }}
    - unless: shinken inventory | grep -q {{ module }}
    - require:
      - pip: install_shinken
{% endfor %}


### Clean /etc/shinken for satellite (doesn't need the entire shinken conf)
{% if salt['pillar.get']('roles:shinken_master', false) is sameas false %}
keep_only_shinken_salt:
  file.recurse:
    - source: salt://{{ tpldir }}/files/etc/shinken
    - name: /etc/shinken
    - clean: true
    - include_pat:
      - daemons*
      - modules*
      - packs*
    - require:
      - init_shinken
{% endif %}

# Create directories for Shinken with Nagios user ownership
create_shinken_log_directories:
  file.directory:
    - name: /var/log/shinken
    - user: shinken
    - group: shinken
    - require:
      - pip: install_shinken
create_shinken_run_directories:
  file.directory:
    - name: /var/run/shinken
    - user: shinken
    - group: shinken
    - require:
      - pip: install_shinken


### Start service ###
{% if  salt['pillar.get']('baobab:maintenance:active', []) is sameas true %}
{% set service_type = 'service.dead' %}
{% else %}
{% set service_type = 'service.running' %}
{% endif %}


{% set shinken_component = ['poller','broker','scheduler','receiver','reactionner'] %}

{% for component in shinken_component %}
shinken_{{ component }}_running:
  {{ service_type }}:
    - name: shinken-{{ component }}
    - require:
      - file: create_shinken_run_directories
      {% if salt['pillar.get']('roles:shinken_master', false) is sameas false %}
      - file: keep_only_shinken_salt
      {% endif %}
{% endfor %}



