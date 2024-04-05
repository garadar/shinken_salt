### Description:


The state monitoring will deploy all the shinken stack:

- init.sls:     Entrypoint which is common to all substate
- common.sls:   This state install common shinken soft
- master.sls:   State to deploy shinken arbiter only 
- client.sls:   State to deploy all monitor client (NRPE, nagios script, cron etc ...)
- repos.sls:    State to initialiaze monitoring repo (needed for thruk)
- thruk.sls:    State to deploy thruk web GUI.

Some state include other state not described here. But nevermind it should be working fine.
You need to add all your conf file in:

  `$ mkdir -p ./files/{usr/lib64,etc/{thruk,sudoers.d,cron.d,shinken,httpd,nrpe.d}}`
