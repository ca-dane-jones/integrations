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

An example event for `log` looks as following:

```json
{
    "@timestamp": "2025-01-01T00:07:07.000Z",
    "agent": {
        "ephemeral_id": "5de5f298-d09b-4786-835d-aa485be2e10f",
        "id": "ee9912e3-07b5-4cf8-beb8-33112699ad73",
        "name": "elastic-agent-92462",
        "type": "filebeat",
        "version": "8.17.1"
    },
    "client": {
        "address": "89.160.20.113",
        "as": {
            "number": 29518,
            "organization": {
                "name": "Bredband2 AB"
            }
        },
        "geo": {
            "city_name": "Linköping",
            "continent_name": "Europe",
            "country_iso_code": "SE",
            "country_name": "Sweden",
            "location": {
                "lat": 58.4167,
                "lon": 15.6167
            },
            "region_iso_code": "SE-E",
            "region_name": "Östergötland County"
        },
        "ip": "89.160.20.113"
    },
    "data_stream": {
        "dataset": "postfix.log",
        "namespace": "50562",
        "type": "logs"
    },
    "ecs": {
        "version": "8.11.0"
    },
    "elastic_agent": {
        "id": "ee9912e3-07b5-4cf8-beb8-33112699ad73",
        "snapshot": false,
        "version": "8.17.1"
    },
    "event": {
        "agent_id_status": "verified",
        "category": [
            "session",
            "email"
        ],
        "dataset": "postfix.log",
        "ingested": "2025-03-03T22:13:42Z",
        "kind": [
            "event"
        ],
        "module": "anvil",
        "original": "Jan  1 00:07:07 mail postfix/anvil[21457]: statistics: max connection count 1 for (smtp:89.160.20.113) at Jan  1 00:03:46Dec 31 23:54:23 mail postfix/anvil[21425]: statistics: max cache size 1 at Dec 31 23:51:02",
        "provider": "postfix",
        "type": [
            "info"
        ]
    },
    "host": {
        "architecture": "x86_64",
        "containerized": false,
        "hostname": "elastic-agent-92462",
        "ip": [
            "172.23.0.2",
            "172.22.0.4"
        ],
        "mac": [
            "02-42-AC-16-00-04",
            "02-42-AC-17-00-02"
        ],
        "name": "mail",
        "os": {
            "family": "",
            "kernel": "6.11.0-17-generic",
            "name": "Wolfi",
            "platform": "wolfi",
            "type": "linux",
            "version": "20230201"
        }
    },
    "input": {
        "type": "filestream"
    },
    "log": {
        "file": {
            "device_id": "51",
            "inode": "146306",
            "path": "/tmp/service_logs/mail.log"
        },
        "level": "info",
        "offset": 125
    },
    "message": "statistics: max connection count 1 for (smtp:89.160.20.113) at Jan  1 00:03:46Dec 31 23:54:23 mail postfix/anvil[21425]: statistics: max cache size 1 at Dec 31 23:51:02",
    "postfix": {
        "anvil": {
            "connection": {
                "count": 1,
                "end_time": "2025-01-01T00:07:07.000Z",
                "service_name": "smtp"
            }
        }
    },
    "process": {
        "name": "postfix/anvil",
        "pid": 21457
    },
    "tags": [
        "preserve_original_event",
        "connection_metrics_enabled",
        "geoip_enabled",
        "pipeline_trace_enabled",
        "postfix",
        "pipeline: default",
        "pipeline: anvil",
        "pipeline: geoip",
        "pipeline: loglevel"
    ]
}
```

**Exported fields**

| Field | Description | Type |
|---|---|---|
| @timestamp | Event timestamp. | date |
| client.address | Some event client addresses are defined ambiguously. The event will sometimes list an IP, a domain or a unix socket.  You should always store the raw address in the `.address` field. Then it should be duplicated to `.ip` or `.domain`, depending on which one it is. | keyword |
| client.as.number | Unique number allocated to the autonomous system. The autonomous system number (ASN) uniquely identifies each network on the Internet. | long |
| client.as.organization.name | Organization name. | keyword |
| client.as.organization.name.text | Multi-field of `client.as.organization.name`. | match_only_text |
| client.domain | The domain name of the client system. This value may be a host name, a fully qualified domain name, or another host naming format. The value may derive from the original event or be added from enrichment. | keyword |
| client.geo.city_name | City name. | keyword |
| client.geo.continent_code | Two-letter code representing continent's name. | keyword |
| client.geo.continent_name | Name of the continent. | keyword |
| client.geo.country_iso_code | Country ISO code. | keyword |
| client.geo.country_name | Country name. | keyword |
| client.geo.location | Longitude and latitude. | geo_point |
| client.geo.region_iso_code | Region ISO code. | keyword |
| client.geo.region_name | Region name. | keyword |
| client.ip | IP address of the client (IPv4 or IPv6). | ip |
| client.registered_domain | The highest registered client domain, stripped of the subdomain. For example, the registered domain for "foo.example.com" is "example.com". This value can be determined precisely with a list like the public suffix list (http://publicsuffix.org). Trying to approximate this by simply taking the last two labels will not work well for TLDs such as "co.uk". | keyword |
| client.subdomain | The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain.  In a partially qualified domain, or if the the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain. For example the subdomain portion of "www.east.mydomain.co.uk" is "east". If the domain has multiple levels of subdomain, such as "sub2.sub1.example.com", the subdomain field should contain "sub2.sub1", with no trailing period. | keyword |
| client.top_level_domain | The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is "com". This value can be determined precisely with a list like the public suffix list (http://publicsuffix.org). Trying to approximate this by simply taking the last label will not work well for effective TLDs such as "co.uk". | keyword |
| data_stream.dataset | Data stream dataset. | constant_keyword |
| data_stream.namespace | Data stream namespace. | constant_keyword |
| data_stream.type | Data stream type. | constant_keyword |
| dns.question.name | The name being queried. If the name field contains non-printable characters (below 32 or above 126), those characters should be represented as escaped base 10 integers (\DDD). Back slashes and quotes should be escaped. Tabs, carriage returns, and line feeds should be converted to \t, \r, and \n respectively. | keyword |
| dns.question.type | The type of record being queried. | keyword |
| dns.type | The type of DNS event captured, query or answer. If your source of DNS events only gives you DNS queries, you should only create dns events of type `dns.type:query`. If your source of DNS events gives you answers as well, you should create one event per query (optionally as soon as the query is seen). And a second event containing all query details as well as an array of answers. | keyword |
| ecs.version | ECS version this event conforms to. `ecs.version` is a required field and must exist in all events. When querying across multiple indices -- which may conform to slightly different ECS versions -- this field lets integrations adjust to the schema version of the events. | keyword |
| email.direction | The direction of the message based on the sending and receiving domains. | keyword |
| email.from.address | The email address of the sender, typically from the RFC 5322 `From:` header field. | keyword |
| email.local_id | Unique identifier given to the email by the source that created the event. Identifier is not persistent across hops. | keyword |
| email.message_id | Identifier from the RFC 5322 `Message-ID:` email header that refers to a particular email message. | wildcard |
| email.to.address | The email address of recipient | keyword |
| error.code | Error code describing the error. | keyword |
| error.id | Unique identifier for the error. | keyword |
| error.message | Error message. | match_only_text |
| error.type | The type of the error, for example the class name of the exception. | keyword |
| event.action | The action captured by the event. This describes the information in the event. It is more specific than `event.category`. Examples are `group-add`, `process-started`, `file-created`. The value is normally defined by the implementer. | keyword |
| event.category | This is one of four ECS Categorization Fields, and indicates the second level in the ECS category hierarchy. `event.category` represents the "big buckets" of ECS categories. For example, filtering on `event.category:process` yields all events relating to process activity. This field is closely related to `event.type`, which is used as a subcategory. This field is an array. This will allow proper categorization of some events that fall in multiple categories. | keyword |
| event.dataset | Event dataset | constant_keyword |
| event.kind | This is one of four ECS Categorization Fields, and indicates the highest level in the ECS category hierarchy. `event.kind` gives high-level information about what type of information the event contains, without being specific to the contents of the event. For example, values of this field distinguish alert events from metric events. The value of this field can be used to inform how these kinds of events should be handled. They may warrant different retention, different access control, it may also help understand whether the data is coming in at a regular interval or not. | keyword |
| event.module | Name of the module this data is coming from. If your monitoring agent supports the concept of modules or plugins to process events of a given source (e.g. Apache logs), `event.module` should contain the name of this module. | keyword |
| event.provider | Source of the event. Event transports such as Syslog or the Windows Event Log typically mention the source of an event. It can be the name of the software that generated the event (e.g. Sysmon, httpd), or of a subsystem of the operating system (kernel, Microsoft-Windows-Security-Auditing). | keyword |
| event.timezone | This field should be populated when the event's timestamp does not include timezone information already (e.g. default Syslog timestamps). It's optional otherwise. Acceptable timezone formats are: a canonical ID (e.g. "Europe/Amsterdam"), abbreviated (e.g. "EST") or an HH:mm differential (e.g. "-05:00"). | keyword |
| event.type | This is one of four ECS Categorization Fields, and indicates the third level in the ECS category hierarchy. `event.type` represents a categorization "sub-bucket" that, when used along with the `event.category` field values, enables filtering events down to a level appropriate for single visualization. This field is an array. This will allow proper categorization of some events that fall in multiple event types. | keyword |
| host.ip | Host ip addresses. | ip |
| host.name | Name of the host. It can contain what hostname returns on Unix systems, the fully qualified domain name (FQDN), or a name specified by the user. The recommended value is the lowercase FQDN of the host. | keyword |
| input.type | Input type | keyword |
| log.file.device_id | File device ID | keyword |
| log.file.inode | File inode | keyword |
| log.file.path | Full path to the log file this event came from, including the file name. It should include the drive letter, when appropriate. If the event wasn't read from a log file, do not populate this field. | keyword |
| log.level | Original log level of the log event. If the source of the event provides a log level or textual severity, this is the one that goes in `log.level`. If your source doesn't specify one, you may put your event transport's severity here (e.g. Syslog severity). Some examples are `warn`, `err`, `i`, `informational`. | keyword |
| log.offset | Log offset | long |
| log.syslog.priority | Syslog priority | long |
| message | For log events the message field contains the log message, optimized for viewing in a log viewer. For structured logs without an original message field, other fields can be concatenated to form a human-readable summary of the event. If multiple messages exist, they can be combined into one message. | match_only_text |
| postfix.anvil.connection.cache_size | The maximum cache size during the client session. | long |
| postfix.anvil.connection.count | The total number of connections made during the client session. | long |
| postfix.anvil.connection.duration | The total duration of the client session. | long |
| postfix.anvil.connection.end_time | The time at which the client session ended. | date |
| postfix.anvil.connection.rate.count | The maximum number of connections made by this client over a specific duration. | long |
| postfix.anvil.connection.rate.timespan.unit | The time unit over which client connection rates were calculated. | keyword |
| postfix.anvil.connection.rate.timespan.value | The time value over which client connection rates were calculated. | long |
| postfix.anvil.connection.service_name | The master.cf service name of the postfix daemon process. | keyword |
| postfix.anvil.connection.start_time | The time at which the client session began. | date |
| postfix.configuration_path | Path to the configuation file used in process startup. | keyword |
| postfix.delivery.delays.before_qmgr_time | The time spent before the message reaches the queue manager, including the time it took for the message to be transmitted to the mail server. | float |
| postfix.delivery.delays.connection_setup_time | The amount of time spent setting up a connection to deliver an email to a recipient, including time spent in DNS, HELO, and TLS. | float |
| postfix.delivery.delays.in_qmgr_time | The amount of time spent by the queue manager in delivering an email to a recipient. | float |
| postfix.delivery.delays.message_transmission_time | The amount of time spent transmitting a message over an established connection. | float |
| postfix.delivery.delays.total_time | The total amount of time spent in email delivery processing. | long |
| postfix.delivery.reject.protocol | The protocol used to deliver the email to a recipient. | keyword |
| postfix.delivery.reject.stage | The stage of email delivery when a reject occured. | keyword |
| postfix.delivery.reject.stage_value | The value that caused the reject to occur. | keyword |
| postfix.delivery.reject.type | The type of reject that occurred. | keyword |
| postfix.delivery.status | The text based description of email delivery status to a recipient. | keyword |
| postfix.delivery.status_code.class | The RFC 3463 email delivery status code class returned by the SMTP server. | long |
| postfix.delivery.status_code.detail | The RFC 3463 email delivery status code detail returned by the SMTP server. | long |
| postfix.delivery.status_code.subject | The RFC 3463 email delivery status code subject returned by the SMTP server. | long |
| postfix.delivery.status_code.value | The full RFC 3463 email delivery status code returned by the SMTP server. | keyword |
| postfix.delivery.status_message | Additional email delivery status information. | match_only_text |
| postfix.dkim.algorithm | The DKIM hashing algorithm as specified by the email sender. | keyword |
| postfix.dkim.domain | The DKIM query domain as specified by the email sender. | keyword |
| postfix.dkim.protocol | The DKIM message transmission protocol. | keyword |
| postfix.dkim.selector | The DKIM key selector as specified by the email sender. | keyword |
| postfix.dkim.version | The opendkim version number. | version |
| postfix.email.size | Total size of the email message on disk. | long |
| postfix.email.to.original_address | The original intended recipient of this email prior to postfix processing. | keyword |
| postfix.error.code | Error code describing the error. | keyword |
| postfix.error.message | The error message. | match_only_text |
| postfix.error.type | The type of the error.  The type field will typically contain values such as warning or fatal. | keyword |
| postfix.qmgr.local_recipient_count | Total count of local recipients | long |
| postfix.qmgr.queue_name | The mail queue the message is currently in. | keyword |
| postfix.relay.server.address | The raw server address. |  |
| postfix.relay.server.domain | The domain name of the relay server system.  This value may be a host name,  a fully qualified domain name, or another host naming format. | keyword |
| postfix.relay.server.ip | IP address of the server (IPv4 or IPv6). | ip |
| postfix.relay.server.port | Port of the server. | long |
| postfix.relay.server.registered_domain | The highest registered server domain, stripped of the subdomain. | keyword |
| postfix.relay.server.subdomain | The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain. In a partially qualified domain, or if the the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain. | keyword |
| postfix.relay.server.top_level_domain | The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. | keyword |
| postfix.scache.cache_hits | The number of successful cache lookups over a period of time. | long |
| postfix.scache.cache_hits_percentage | The percentage of successful cache hits vs. total cache lookups over a period of time. | long |
| postfix.scache.cache_misses | The number of failed cache lookups over a period of time. | long |
| postfix.scache.cache_type | The type of cache the lookups were performed against.  Generally this will be of type address or domain. | keyword |
| postfix.scache.max_simultaneous_addresses | The maximum number of simultaneous address entries in the cache over a period of time. | long |
| postfix.scache.max_simultaneous_connections | The maximum number of simultaneous connection entries in the cache over a period of time. | long |
| postfix.scache.max_simultaneous_domains | The maximum number of simultaneous domain entries in the cache over a period of time. | long |
| postfix.scache.start_interval_timestamp | The timestamp at which the scache statistics interval started. | date |
| postfix.smtpd.connection.commands.auth.accepted_count | The number of AUTH commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.auth.rejected_count | The number of AUTH commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.auth.total_count | The total number of AUTH commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.bdat.accepted_count | The number of BDAT commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.bdat.rejected_count | The number of BDAT commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.bdat.total_count | The total number of BDAT commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.data.accepted_count | The number of DATA commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.data.rejected_count | The number of DATA commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.data.total_count | The total number of DATA commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.ehlo.accepted_count | The number of EHLO commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.ehlo.rejected_count | The number of EHLO commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.ehlo.total_count | The total number of EHLO commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.etrn.accepted_count | The number of ETRN commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.etrn.rejected_count | The number of ETRN commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.etrn.total_count | The total number of ETRN commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.expn.accepted_count | The number of EXPN commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.expn.rejected_count | The number of EXPN commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.expn.total_count | The total number of EXPN commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.helo.accepted_count | The number of HELO commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.helo.rejected_count | The number of HELO commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.helo.total_count | The total number of HELO commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.help.accepted_count | The number of HELP commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.help.rejected_count | The number of HELP commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.help.total_count | The total number of HELP commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.mail.accepted_count | The number of MAIL commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.mail.rejected_count | The number of MAIL commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.mail.total_count | The total number of MAIL commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.missing_parser.command_name | The name of the SMTP command identified as being missed by the SMTPD disconnect  command summary grok processor. | keyword |
| postfix.smtpd.connection.commands.noop.accepted_count | The number of NOOP commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.noop.rejected_count | The number of NOOP commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.noop.total_count | The total number of NOOP commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.quit.accepted_count | The number of QUIT commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.quit.rejected_count | The number of QUIT commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.quit.total_count | The total number of QUIT commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.rcpt.accepted_count | The number of RCPT commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.rcpt.rejected_count | The number of RCPT commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.rcpt.total_count | The total number of RCPT commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.rset.accepted_count | The number of RSET commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.rset.rejected_count | The number of RSET commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.rset.total_count | The total number of RSET commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.starttls.accepted_count | The number of STARTTLS commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.starttls.rejected_count | The number of STARTTLS commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.starttls.total_count | The total number of STARTTLS commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.total_accepted_count | The total number of commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.total_count | The total number of commands sent by the client. | long |
| postfix.smtpd.connection.commands.total_rejected_count | The total number of commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.unknown.accepted_count | The number of UNKNOWN commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.unknown.rejected_count | The number of UNKNOWN commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.unknown.total_count | The total number of UNKNOWN commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.commands.vrfy.accepted_count | The number of VRFY commands sent by the client that were accepted during a client connection. | long |
| postfix.smtpd.connection.commands.vrfy.rejected_count | The number of VRFY commands sent by the client that were rejected during a client connection. | long |
| postfix.smtpd.connection.commands.vrfy.total_count | The total number of VRFY commands sent by the client during a client connection. | long |
| postfix.smtpd.connection.lost.message | The high level description of the event. | keyword |
| postfix.smtpd.connection.lost.reason | The reason the connection was prematurely lost or terminated. | keyword |
| postfix.smtpd.connection.lost.stage | The stage of the connection when it was prematurely lost or terminated. | keyword |
| postfix.smtpd.connection.tls.certificate_status | This field contains the verification status of a certificate, if provided, during an SMTPD connection SSL handshake. | keyword |
| postfix.smtpd.connection.tls.key_exchange_algorithm | The algorithm used for client and server key exchange. | keyword |
| postfix.smtpd.connection.tls.signature_algorithm | The algorithm used for signing the certificate. | keyword |
| postfix.smtpd.connection.tls.signature_digest | The digest used for signing the certificate. | keyword |
| postfix.smtpd.connection.tls.signature_strength | The size of the key, represented in number of bits, used for signing the certificate. | long |
| postfix.spf.envelope_from | The SMTP from address used in SPF validation. | keyword |
| postfix.spf.helo.url.domain | The domain name of the host specified in the HELO.  This value may be a host name, a fully qualified domain name, or another host naming format. | keyword |
| postfix.spf.helo.url.registered_domain | The highest registered domain, stripped of the subdomain. | keyword |
| postfix.spf.helo.url.subdomain | The subdomain portion of the host specified in the HELO. | keyword |
| postfix.spf.helo.url.top_level_domain | The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. | keyword |
| postfix.spf.helo.value | The SMTP helo command used for SPF validation.  This is typically the client domain. | keyword |
| postfix.spf.identity.name | The SMTP field used for SPF identify validation. | keyword |
| postfix.spf.identity.value | The value of the SMTP field used for SPF identify validation. | keyword |
| postfix.spf.receiver | The value of the SMTP mail to field.  Note that policyd-spf default configuration sets this value to UNKNOWN. | keyword |
| postfix.spf.result | The SPF validation result. | keyword |
| postfix.spf.xcomment | The SPF X-Comment value.  This field is populated by Postfix when SPF checks are skipped due to SPF policy (e.g. local or trusted relays, or other whitelisting). Note: `postfix.spf.result` will be set to `Skip` when this field is populated. | match_only_text |
| postfix.version | The postfix version number. | version |
| process.end | The time the process ended. | date |
| process.exit_code | The exit code of the process, if this is a termination event. The field should be absent if there is no exit code for the event (e.g. process start). | long |
| process.name | Process name. Sometimes called program name or similar. | keyword |
| process.name.text | Multi-field of `process.name`. | match_only_text |
| process.pgid | Deprecated for removal in next major version release. This field is superseded by `process.group_leader.pid`. Identifier of the group of processes the process belongs to. | long |
| process.pid | Process id. | long |
| process.start | The time the process started. | date |
| server.address | Some event server addresses are defined ambiguously. The event will sometimes list an IP, a domain or a unix socket.  You should always store the raw address in the `.address` field. Then it should be duplicated to `.ip` or `.domain`, depending on which one it is. | keyword |
| server.as.number | Unique number allocated to the autonomous system. The autonomous system number (ASN) uniquely identifies each network on the Internet. | long |
| server.as.organization.name | Organization name. | keyword |
| server.as.organization.name.text | Multi-field of `server.as.organization.name`. | match_only_text |
| server.domain | The domain name of the server system. This value may be a host name, a fully qualified domain name, or another host naming format. The value may derive from the original event or be added from enrichment. | keyword |
| server.geo.city_name | City name. | keyword |
| server.geo.continent_name | Name of the continent. | keyword |
| server.geo.country_iso_code | Country ISO code. | keyword |
| server.geo.country_name | Country name. | keyword |
| server.geo.location.lat | Longitude and latitude. | geo_point |
| server.geo.location.lon | Longitude and latitude. | geo_point |
| server.geo.region_iso_code | Region ISO code. | keyword |
| server.geo.region_name | Region name. | keyword |
| server.ip | IP address of the server (IPv4 or IPv6). | ip |
| server.port | Port of the server. | long |
| server.registered_domain | The highest registered server domain, stripped of the subdomain. For example, the registered domain for "foo.example.com" is "example.com". This value can be determined precisely with a list like the public suffix list (http://publicsuffix.org). Trying to approximate this by simply taking the last two labels will not work well for TLDs such as "co.uk". | keyword |
| server.subdomain | The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain.  In a partially qualified domain, or if the the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain. For example the subdomain portion of "www.east.mydomain.co.uk" is "east". If the domain has multiple levels of subdomain, such as "sub2.sub1.example.com", the subdomain field should contain "sub2.sub1", with no trailing period. | keyword |
| server.top_level_domain | The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is "com". This value can be determined precisely with a list like the public suffix list (http://publicsuffix.org). Trying to approximate this by simply taking the last label will not work well for effective TLDs such as "co.uk". | keyword |
| tags | List of keywords used to tag each event. | keyword |
| tls.cipher | String indicating the cipher used during the current connection. | keyword |
| tls.established | Boolean flag indicating if the TLS negotiation was successful and transitioned to an encrypted tunnel. | boolean |
| tls.version | Numeric part of the version parsed from the original string. | keyword |
| tls.version_protocol | Normalized lowercase protocol name parsed from original string. | keyword |
| user.id | Unique identifier of the user. | keyword |
