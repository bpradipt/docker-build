Name: docker-registry
Version: %{version}
Release: %{checkout}%{?dist}
Summary: The open-source application container engine

License: ASL 2.0

URL: https://dockerproject.com
Vendor: Docker
Packager: Docker <support@docker.com>


%description
Docker Registry 2.0 implementation is for storing and distributing Docker images.

%install
# Install binary
install -d $RPM_BUILD_ROOT/%{_bindir}
install -d $RPM_BUILD_ROOT/etc/registry
install -d $RPM_BUILD_ROOT/var/lib/registry
install -p -m 755 %{_filepath}/registry $RPM_BUILD_ROOT/%{_bindir}/registry
install -p -m 755 %{_filepath}/config.yml $RPM_BUILD_ROOT/etc/registry/config.yml

mkdir -p /var/lib/registry

# list files owned by the package here
%files
/%{_bindir}/registry
/etc/registry/config.yml
%dir /var/lib/registry

%changelog

