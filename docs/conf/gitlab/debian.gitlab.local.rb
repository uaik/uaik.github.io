external_url 'https://127.0.0.1'
user['username'] = 'gitlab'
user['group'] = 'gitlab'
letsencrypt['enable'] = false
nginx['client_max_body_size'] = '250m'
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate_key'] = '/etc/ssl/_ssc/auth.server.key'
nginx['ssl_certificate'] = '/etc/ssl/_ssc/auth.server.crt'
registry_nginx['redirect_http_to_https'] = true
mattermost_nginx['redirect_http_to_https'] = true
gitlab_rails['gitlab_default_projects_features_builds'] = false
gitlab_rails['omniauth_enabled'] = false
gitlab_rails['smtp_enable'] = false
gitlab_rails['smtp_pool'] = true
gitlab_rails['gitlab_email_from'] = 'gitlab@localhost'
gitlab_rails['gitlab_email_display_name'] = 'GitLab'
gitlab_rails['usage_ping_enabled'] = false
