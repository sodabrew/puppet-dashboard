%define confdir ext/packaging/redhat
%define _initrddir /etc/rc.d/init.d}

Name:           puppet-dashboard
Version:        1.0.0
Release:        2%{?dist}
Summary:        Systems Management web application
Group:          Development/Tools 
License:        GPLv2+
URL:            http://www.puppetlabs.com 
Source:         http://puppetlabs.com/downloads/puppet/%{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       ruby(abi) = 1.8, rubygems, rubygem(rake)
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires(post): chkconfig
Requires(preun): chkconfig
Requires(preun): initscripts
Requires(postun): initscripts

%description
Puppet Dashboard is a systems management web application for managing
Puppet installations and is written using the Ruby on Rails framework.

%prep
%setup -q

%build

%install
%{__rm} -rf %{buildroot}

%{__install} -p -d -m0755 %{buildroot}%{_datadir}/%{name}
%{__install} -p -d -m0755 %{buildroot}%{_datadir}/%{name}/vendor
%{__install} -p -d -m0755 %{buildroot}%{_defaultdocdir}/%{name}-%{version}
%{__cp} -p -r app bin config db lib public Rakefile script spec %{buildroot}%{_datadir}/%{name}

# Add sysconfig and init script
%{__install} -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{_initrddir}/puppet-dashboard
%{__install} -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/puppet-dashboard

# Not all plugins are installed from our source file.
%{__mkdir} %{buildroot}%{_datadir}/%{name}/vendor/plugins
for plugin in authlogic inherited_resources jrails object_daddy resources_controller rspec-rails timeline_fu will_paginate; do
  %{__cp} -p -r vendor/plugins/$plugin %{buildroot}%{_datadir}/%{name}/vendor/plugins/$plugin
done

%{__cp} -p -r vendor/gems %{buildroot}%{_datadir}/%{name}/vendor
%{__cp} -p -r vendor/rails %{buildroot}%{_datadir}/%{name}/vendor

chmod a+x %{buildroot}%{_datadir}/%{name}/script/* 

for file in $(find %{buildroot} -size 0) ; do
    %{__rm} -f "$file"
done

%{__rm} -f -r %{buildroot}%{_datadir}/%{name}/.git

mv CHANGELOG timestamp
iconv -f ISO-8859-1 -t UTF-8 -o CHANGELOG timestamp
touch -r timestamp CHANGELOG 

%post
/sbin/chkconfig --add puppet-dashboard || :

%preun
if [ "$1" = 0 ] ; then
  /sbin/service puppet-dashboard stop > /dev/null 2>&1
  /sbin/chkconfig --del puppet-dashboard || :
fi

%postun
if [ "$1" -ge 1 ]; then
  /sbin/service puppet-dashboard condrestart >/dev/null 2>&1 || :
fi

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%{_initrddir}/puppet-dashboard
%{_sysconfdir}/sysconfig/puppet-dashboard
%doc CHANGELOG COPYING README.markdown VERSION doc/README_FOR_APP doc/domain-model.graffle doc/domain-model.png

%changelog
* Fri Apr 16 2010 James Turnbull <james@lovedthanlost.net> - 1.0.0-2
- Added init script support
- Imported changes for older RPM builds provided by Michael Stahnke

* Thu Mar 26 2010 James Turnbull <james@lovedthanlost.net> - 1.0.0-1
- Initial release.

