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

#######Import and variables #######


#######Include #######

include:
  - repo
  - monitoring.repo
  - firewalld
  - apache

####### Main #######



### Thruk ###

# Need apache state
# Do not forget to configure firewalld

### Install Thruk RPM
install_thruk:
  pkg.installed:
    - pkgs:
      - thruk
      ## Required for oauth
      - perl-Crypt-JWT



thruk_local_conf:
  file.managed:
    - name: /etc/thruk/thruk_local.conf
    - source: salt://{{ tpldir }}/files/etc/thruk/thruk_local.conf
    - mode: '0744'
    - user: root
    - group: root
    - require:
      - pkg: install_thruk

httpd_thruk.conf:
  file.managed:
    - name: /etc/httpd/conf.d/thruk.conf
    - source: salt://{{ tpldir }}/files/etc/httpd/conf.d/thruk.conf
    - mode: '0744'
    - user: root
    - group: root
    - require:
      - pkg: install_thruk

httpd_ssl.conf:
  file.managed:
    - name: /etc/httpd/conf.d/ssl.conf
    - source: salt://{{ tpldir }}/files/etc/httpd/conf.d/ssl.conf
    - mode: '0744'
    - user: root
    - group: root
    - require:
      - pkg: install_thruk
