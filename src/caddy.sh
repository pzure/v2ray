caddy_config() {
    is_caddy_site_file=$is_caddy_conf/${host}.conf
    case $1 in
    new)
        mkdir -p $is_caddy_dir $is_caddy_dir/sites $is_caddy_conf
        cat >$is_caddyfile <<-EOF
# don't edit this file #
{
  admin off
  http_port $is_http_port
  https_port $is_https_port
}
import $is_caddy_conf/*.conf
import $is_caddy_dir/sites/*.conf
EOF
        ;;
    *ws*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy ${path} 127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    *h2*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy ${path} h2c://127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    *grpc*)
        cat >${is_caddy_site_file} <<<"
${host}:${is_https_port} {
    reverse_proxy /${path}/* h2c://127.0.0.1:${port}
    import ${is_caddy_site_file}.add
}"
        ;;
    proxy)
        
        cat >${is_caddy_site_file}.add <<<"
reverse_proxy https://$proxy_site {
        header_up Host {upstream_hostport}
}"
        ;;
    esac
    [[ $1 != "new" && $1 != 'proxy' ]] && {
        [[ ! -f ${is_caddy_site_file}.add ]] && echo "# Error: " >${is_caddy_site_file}.add
    }
}
