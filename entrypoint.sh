#!/bin/sh
/clash &
echo "http/socks5 proxy server enabled"
exec "$@"
