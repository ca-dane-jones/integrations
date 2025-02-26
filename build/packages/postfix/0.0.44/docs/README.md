# Postfix Integration

This is a community developed integration designed to parse logs from [Postfix mail servers](https://www.postfix.org/). The plug-in supports 

## Compatibility
The `log` ingestion pipeline was tested with logs from Postfix version 3.6.4 running on Debian. 

Currently this integration supports parsing logs from the Postfix anvil, cleanup, error, local, master, pickup, postfix-script, qmgr, scache, smtp, and smtpd processes with additional support for [OpenDKIM](http://www.opendkim.org/) and [policyd-spf](https://manpages.debian.org/testing/postfix-policyd-spf-python/policyd-spf.1.en.html).  All other events are dropped.
