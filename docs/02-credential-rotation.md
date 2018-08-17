# Use case: database credential rotation

Now that we know how to create custom workflow step script plugin, let's walk through a real world use case: rotation database credentials. Credential rotation has traditionally been a complicated, thankless administrative chore. The type of work that might be labeled [toil](https://landing.google.com/sre/book/chapters/eliminating-toil.html) and exactly the kind of work that Rundeck has been designed to streamline.

## The problem

What's difficult about database credential rotation?

* It involves multiple steps across multiple nodes in your production cluster.
* It's necessary to handle secrets in the form of the new credentials you're creating, plus credentials of a super user that can create the new login.
* Fat-fingering some value can potentially cause a site-wide outage if your app can't authenticate with the database anymore.

## How can we address the problem with Rundeck?

By creating a custom script plugin to interact with the database, its downstream clients and the Rundeck Key Storage, we can automate the creation and deployment of the new credentials as well as safely handle the decomissioning of the old credentials.

### Secure secrets handling

Since the Key Storage stores the credentials, the administrator triggering the credential rotation doesn't ever need to see the actual credentials of the database super user or the newly generated database user.

### Critical logic is tested ahead of time

The logic for creating the database login is encapsulated in a script that has been tested prior to actually needing to rotate the credentials, so we avoid putting a human in the stressful, error-prone situation of having to figure out correct syntax to run on a live system on the fly.

Similarly, the app restart logic is encapsulated as well, with health check logic as an extra safety measure to halt the process in case something has gone wrong before applying the change to the whole cluster.

### Ease of use encourages proactive security

Lastly, by creating a single button solution to rotate database credentials, we're much more likely to rotate our credentials on a regular basis to mitigate potential security risks, rather than only after a security incident has already occured.

## Restarting the apps

``` yaml
name: Database credential management
version: 1
rundeckPluginVersion: 1.2
author: Carlo Cabanilla
date: 2018-07-20
url: http://rundeck.org/
providers:
  - name: RestartApp
    service: RemoteScriptNodeStep
    plugin-type: script
    script-interpreter: /bin/bash
    script-file: restart.sh
    script-args: ${config.process} ${config.health_url}
    config:
      - type: String
        name: process
        title: process
        description: the process to restart
      - type: String
        name: health_url
        title: health_url
        description: the http endpoint to poll to check that it's healthy
        default: http://localhost:8080
```

* Config parameters
    * Shows up in ui
    * default
    * descriptions
    * more intuitive than a bash script

## Modifying the app config

``` yaml
  - name: UpdateDBCredentials
    service: RemoteScriptNodeStep
    plugin-type: script
    script-interpreter: /usr/bin/python3
    script-file: change_password.py
    script-args: /etc/web.yaml ${config.user} ${config.password}
    config:
      - type: String
        name: user
        title: user
        description: 'db user'
      - type: String
        name: password
        title: password
        description: 'db password'
        renderingOptions:
          valueConversion: "STORAGE_PATH_AUTOMATIC_READ"
```

* Explain STORAGE_PATH_AUTOMATIC_READ

## Creating the new db login

``` yaml
  - name: CreateDBUser
    service: RemoteScriptNodeStep
    plugin-type: script
    script-interpreter: /bin/bash
    script-file: create-db-user.sh
    script-args: ${config.master_db_user} ${config.master_db_password} ${config.new_user} ${config.new_password} ${config.role}
    config:
      - type: String
        name: master_db_user
        title: master_db_user
        description: 'master db user'
        default: master1
      - type: String
        name: master_db_password
        title: master_db_password
        description: 'master db user password'
        default: keys/projects/hello-project/db/master1
        renderingOptions:
          valueConversion: "STORAGE_PATH_AUTOMATIC_READ"
      - type: String
        name: new_user
        title: new_user
        description: 'New db user'
      - type: String
        name: new_password
        title: new_password
        description: 'New db password'
        renderingOptions:
          valueConversion: "STORAGE_PATH_AUTOMATIC_READ"
      - type: String
        name: role
        title: role
        description: 'Database role to grant the new user'
```

## One button credential rotation

``` yaml
  options:
  - label: master_user_version
    name: master_user_version
    value: '1'
  - label: web_user_version
    name: web_user_version
    required: true
  sequence:
    commands:
    - jobref:
        group: ''
        importOptions: true
        name: create_db_user
        nodeStep: 'true'
        uuid: daeb3230-dcc7-4b82-97f4-f744f050bffe
    - jobref:
        args: -dbuser web${option.web_user_version}
        group: ''
        name: change_password
        nodeStep: 'true'
        uuid: 542f5584-6568-424f-bbbe-36ba783ccc8c
    - jobref:
        group: ''
        name: restart
        nodeStep: 'true'
        uuid: 3e692968-e82f-4e69-a14f-d074c394cb6c
    keepgoing: false
    strategy: sequential
  uuid: f0c42b76-1bd3-44c1-9638-ab84e9f5b67a
```
