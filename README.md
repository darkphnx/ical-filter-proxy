# ical-proxy

A fork of the original [ical-filter-proxy](https://github.com/darkphnx/ical-filter-proxy) from darkphnx!

Got an iCal feed full of nonsense that you don't need? Does your calendar client have piss-poor
filtering options (looking at your Google Calendar)?

Use ical-proxy to proxy and filter your iCal feed, as well as complete some transformations to make each event more to your need. Define your source
calendar and filtering options in `config.yml` and you're good to go.

In addition, display alarms can be created or cleared.

## Configuration

```yaml
my_calendar_name:
   ical_url: https://source-calendar.com/my_calendar.ics # Source calendar
   api_key: myapikey # (optional) append ?key=myapikey to your URL to grant access
   timezone: Europe/London # (optional) ensure all time comparisons are done in this TZ
   rules:
      - field: start_time # start_time and end_time supported
        operator: not-equals # equals and not-equals supported
        val: "09:00" # A time in 24hour format, zero-padded
      - field: summary # summary and description supported
        operator: startswith # (not-)startswith, (not-)equals and (not-)includes supported
        val: # array of values also supported
          - Planning
          - Daily Standup
      - field: summary # summary and description supported
        operator: matches # match against regex pattern
        val: # array of values also supported
          - '/Team A/i'
   alarms: # (optional) create/clear alarms for filtered events
     clear_existing: true # (optional) if true, existing alarms will be removed, default: false 
     triggers: # (optional) triggers for new alarms. Description will be the alarm summary, action is 'DISPLAY'
       - '-P1DT0H0M0S' # iso8061 supported
       - 2 days # supports full day[s], hour[s], minute[s], no combination in one trigger
    transformations:
      # Rename/normalize event summaries. Each rule can be a plain string match or a regex.
      # Use `regex: true` to force compiling a string as a regex, or provide a
      # string that looks like a regex (e.g. "/pattern/i").
      rename:
        # Normalizer style: if it matches the pattern (in summary or description), set the summary to a fixed value.
        - pattern: '/spin( class)?/i'
          to: 'Spin'
          search: ['summary', 'description']
          regex: true
        # Search and replace within summary only (gsub on summary)
        - pattern: 'Draft'
          replace: 'Final'
      location: # (optional) use regex to extract a location from title/description or add fixed location data
        - extract_from: 'description' # extract location from description (first capture group). Only sets when current location is blank (default).
          pattern: '/Location:\\s*([^\\n]+)/i'
          set_if_blank: true
        - pattern: '/Watford/i' # add GEO when a place name appears in summary or description
          search: ['summary', 'description']
          geo: { lat: 51.6565, lon: -0.3903 }
        - pattern: '/Hemel/i' # normalize location to a fixed string based on a match
          search: ['summary', 'description']
          location: 'HP1 2AA'
```

### Variable substitution

It might be useful to inject configuration values as environment variable.  
Variables are substituted if they begin with `ICAL_PROXY_<value>` and are defined in the configuration like `${ICAL_PROXY_<value>}`.  

Example: 
```yaml
  api_key: ${ICAL_PROXY_API_KEY}
```

If a placeholder is defined but environment variable is missing, it is substituted with an empty string!

## Additional Rules

At the moment rules are pretty simple, supporting only start times, end times, equals and
not-equals as that satisfies my use case. To add support for additional rules please extend
`lib/ical_proxy/filter/filter_rule.rb`. Pull requests welcome.

## Installing/Running

After you've created a `config.yml` simply bundle and run Puma.

```bash
bundle install
bundle exec puma -C config/puma.rb
```

Voila! Your calendar will now be available at http://localhost:8000/my_calendar_name?key=myapikey.


I'd recommend running it behind something like nginx, but you can do what you like.

### Docker

Create a `config.yml` as shown above.

```bash
docker build -t ical-proxy .
docker run -d --name ical-proxy -v $(pwd)/config.yml:/app/config.yml -p 8000:8000 ical-proxy
```

### Lambda

ical-proxy can be run as an AWS Lambda process using their API Gateway.

Create a new API Gateway in the AWS Console and link to to a new Lambda process. This should create all of the permissions required in AWS land.

Next we need to package the app up ready for Lambda. First of all, craft your config.yml and place it in the root of the source directory. A handy rake task is included which will fetch any dependencies and zip them up ready to be uploaded.

```bash
bundle exec rake lamba:build
```

This task will output the file `ical-proxy.zip`. Note that you must have the `zip` utility installed locally to use this task.

When prompted during the Lambda setup, provide this zip file and set the handler to `lambda.handle`.

That's it! Your calendar should now be available at `https://aws-api-gateway-host/default/gateway_name?calendar=my_calendar_name&key=my_api_key`
