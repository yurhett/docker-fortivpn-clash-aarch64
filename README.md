# docker-fortivpn-clash

Docker Hub: https://hub.docker.com/repository/docker/yulonger/docker-fortivpn-clash-aarch64

Connect to a Fortinet SSL-VPN via http/socks5 proxy.

## Usage

NOTE: I only tested this image on Linux-based systems.

1. Create an openfortivpn configuration file.

    ```
    $ cat /path/to/config
    host = vpn.example.com
    port = 443
    username = foo
    password = bar
    ```

2. Run the following command to start the container.

    ```
    $ docker container run \
        --cap-add=NET_ADMIN \
        --device=/dev/ppp \
        -p 7891:7891 \
        -v /path/to/config:/etc/openfortivpn/config:ro \
        yulonger/docker-fortivpn-clash-aarch64:latest

    ```

3. Now you can use SSL-VPN via `http://<host-ip>:7891` or `socks5://<host-ip>:7891`.

    ```
    $ http_proxy=http://192.168.1.2:7891 curl http://example.com

    $ ssh -o ProxyCommand="nc -x 192.168.1.2:7891 %h %p" foo@example.com
    ```
## Acknowledgement

@[Tosainu](https://github.com/Tosainu)‘s  [docker-fortivpn-socks5](https://github.com/Tosainu/docker-fortivpn-socks5)
@[Dreamacro](https://github.com/Dreamacro)'s [clash](https://github.com/Dreamacro/clash)

## License
MIT
