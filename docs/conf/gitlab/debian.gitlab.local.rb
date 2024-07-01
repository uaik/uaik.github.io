external_url 'https://127.0.0.1'
user['username'] = 'gitlab'
user['group'] = 'gitlab'
gitlab_rails['gitlab_default_projects_features_builds'] = false
gitlab_rails['omniauth_enabled'] = false
gitlab_rails['smtp_enable'] = false
letsencrypt['enable'] = false
nginx['client_max_body_size'] = '250m'
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate_key'] = '/etc/ssl/private/auth.server.key'
nginx['ssl_certificate'] = '/etc/ssl/certs/auth.server.crt'
registry_nginx['redirect_http_to_https'] = true
mattermost_nginx['redirect_http_to_https'] = true
