FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
COPY ldap-cacert.pem /etc/pki/ca-trust/source/anchors/ldap-cacert.pem
RUN update-ca-trust

FROM quay.io/keycloak/keycloak:25.0.2 as builder

WORKDIR /opt/keycloak

FROM quay.io/keycloak/keycloak:25.0.2
COPY --from=ubi-micro-build /etc/pki /etc/pki
COPY --from=builder /opt/keycloak/ /opt/keycloak/

COPY PrivacyIDEA-Provider-v1.4.0.KC22.jar /opt/keycloak/providers/
COPY ldap-cacert.pem /etc/openldap/certs/ldap-cacert.pem

ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://keycloak_db/keycloak

ENV KC_DB_USERNAME=<db-user>
ENV KC_DB_PASSWORD=<db-password>
ENV KC_HOSTNAME=<hostname>
ENV KC_PROXY=edge
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_HOSTNAME_DEBUG=true
ENV KC_METRICS_ENABLED=true
ENV KC_HEALTH_ENABLED=true

RUN /opt/keycloak/bin/kc.sh build

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
