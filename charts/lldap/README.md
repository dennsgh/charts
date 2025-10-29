# LLDAP Helm Chart

Chart deploys [LLDAP](https://github.com/lldap/lldap).

## Quickstart
```bash
helm upgrade --install lldap ./charts/lldap \
  -n identity --create-namespace \
  --set lldap.baseDN=dc=example,dc=com \
  --set lldap.adminUsername=admin
