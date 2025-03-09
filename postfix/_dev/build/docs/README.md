# Postfix Integration

This is a community developed integration designed to parse logs from [Postfix mail servers](https://www.postfix.org/).

## Compatibility
The `log` ingestion pipeline was tested with logs from Postfix version 3.6+ running on Ubuntu 24 LTS. 

Currently this integration supports parsing logs from the Postfix anvil, cleanup, error, local, master, pickup, postfix-script, qmgr, scache, smtp, and smtpd processes with additional support for [Dovecot LMTP](https://doc.dovecot.org/2.3/configuration_manual/protocols/lmtp_server/), [OpenDKIM](http://www.opendkim.org/) and [policyd-spf](https://manpages.debian.org/testing/postfix-policyd-spf-python/policyd-spf.1.en.html).

## Agent Policy Settings ##
This integration supports the following agent policy configuration settings:

| Title | Default Value | Description |
|---|---|---|
| Timezone Offset | `local` | By default, datetimes in the logs will be interpreted as relative to the timezone configured in the host where the agent is running. If ingesting logs from a host on a different timezone, use this field to set the timezone offset so that datetimes are correctly parsed. Acceptable timezone formats are: a canonical ID (e.g. "Europe/Amsterdam"), abbreviated (e.g. "EST") or an HH:mm differential (e.g. "-05:00") from UCT.  This setting has no effect on log entries that have an ISO8601 timestamp. |
| Paths | `/var/log/mail.log` | The path(s) to the postfix log file(s). Paths entires support wildcard characters such as `*` and `?`. |
| Calculate SMTP command metrics | `true` | Calculate the total number of accepted and rejected commands sent to the SMTPD daemon for a given connection. This may have minor performance impacts on your injestion nodes depending on event volume. |
| Drop Unparsed Events | `false` | Drops all logs failing to match a grok pattern in this integration. If disabled (`false`), the pipeline will add a `catch_all` tag to each unparsed event. **Note**: It is recommended to leave this disabled until you are comfortable that all interesting and relevant events are parsed correctly. |
| Perform GeoIP lookups | `true` | Enrich events with GeoIP information. | `geoip_enabled` | `bool` | No | Yes |
| Enable pipeline tracing | `false` | Pipeline tracing will add a `pipeline: <pipeline_name>` tag for each Postfix ingestion pipeline the event passes through.  This is useful for debugging. |
| Preserve original event | `false` | Preserves a raw copy of the original event, added to the field `event.original` |

{{ event "log" }}

{{ fields "log" }}