# ical-filter-proxy

[![Build Status](https://travis-ci.org/darkphnx/ical-filter-proxy.svg?branch=master)](https://travis-ci.org/darkphnx/ical-filter-proxy)

Got an iCal feed full of nonsense that you don't need? Does your calendar client have piss-poor
filtering options (looking at your Google Calendar)?

Use ical-filter-proxy to (you guessed it) proxy and filter your iCal feed. Define your source
calendar and filtering options in `config.yml` and you're good to go.

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
```

## Additional Rules

At the moment rules are pretty simple, supporting only start times, end times, equals and
not-equals as that satisfies my use case. To add support for additional rules please extend
`lib/ical_filter_proxy/filter_rule.rb`. Pull requests welcome.

## Installing/Running

After you've created a `config.yml` simply bundle and run rackup.

```bash
bundle install
bundle exec rackup -p 8000
```

Voila! Your calendar will now be available at http://localhost:8000/my_calendar_name?key=myapikey.


I'd recommend running it behind something like nginx, but you can do what you like.
