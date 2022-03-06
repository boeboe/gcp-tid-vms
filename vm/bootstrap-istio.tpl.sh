#!/usr/bin/env bash
# https://istio.io/latest/docs/setup/install/virtual-machine/

# Install the root certificate 
mkdir -p /etc/certs
tee -a /etc/certs/root-cert.pem << END
REPLACE_ROOT_CERT
END

# Install the token
mkdir -p /var/run/secrets/tokens
tee -a /var/run/secrets/tokens/istio-token << END
REPLACE_ISTIO_TOKEN

END

# Install the package containing the Istio virtual machine integration runtime
curl -L https://storage.googleapis.com/istio-release/releases/REPLACE_ISTIO_VERSION/deb/istio-sidecar.deb -o /tmp/istio-sidecar.deb
dpkg -i /tmp/istio-sidecar.deb

# Install cluster.env 
tee -a /var/lib/istio/envoy/cluster.env << END
REPLACE_CLUSTER_ENV
END

# Install the Mesh Config
tee -a /etc/istio/config/mesh << END
REPLACE_MESH_CONFIG
END

# Add the istiod host
tee -a /etc/hosts << END

# Host entry for Istiod
REPLACE_ISTIOD_HOSTS
END

# Transfer ownership of the files to Istio Proxy
mkdir -p /etc/istio/proxy
chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem

# Start/enable the Istio agent service
systemctl enable istio
systemctl start istio
