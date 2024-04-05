{% from "repo/init.sls"
     import repos_pillar_field,
            mirror_base_url %}

include:
    - repo

{% set labs_consol_stable_repo_name = 'labs_consol_stable_' ~ grains['osmajorrelease'] %}

{% set labs_consol_stable_repo = salt['pillar.get'](repos_pillar_field ~ ':' ~ labs_consol_stable_repo_name) %}

Local-{{ labs_consol_stable_repo_name }}:
    pkgrepo.managed:
        - enabled: 1
        - humanname: {{ 'Local - ' ~ labs_consol_stable_repo.humanname }}
        - baseurl:  {{ labs_consol_stable_repo.baseurl_local }}
        - gpgcheck: {{ labs_consol_stable_repo.gpgcheck }}
        - gpgkey: {{ labs_consol_stable_repo.gpgkey }}
        - require:
            - file: repo_key

