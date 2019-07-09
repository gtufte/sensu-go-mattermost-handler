# Mattermost handler for Sensu Go

Get notified in Mattermost when incidents occur

## Installing with Puppet

Using [the Sensu Go Puppet-module](https://forge.puppet.com/sensu/sensu), define the handler in Hiera like so:

```
sensu::backend::handlers:
  mattermost:
    type: pipe
    command: "/path/on/the/sensu/backend/server/to/mattermost.rb"
    env_vars:
      - URI=https://mattermost.example.com/hooks/<hook_id>
      - USERNAME=SensuGo
      - ICON_URL=https://example.com/path/to/some.png
    annotations:
      channel: "Sensu Events"
    filters:
      - list_of_any_filter_to_apply_for_this_handler
```

Then define this handler to be used with a check, also in Hiera, e.g:

```
sensu::backend::checks:
  load:
    command: '/opt/sensu-plugins-ruby/embedded/bin/check-load.rb'
    interval: 60
    subscriptions:
      - linux
    publish: true
    handlers:
      - mattermost
```
