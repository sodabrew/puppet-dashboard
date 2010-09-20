%global confdir ext/packaging/redhat
%global initrddir /etc/rc.d/init.d

Name:           puppet-dashboard
Version:        1.0.3
Release:        3%{?dist}
Summary:        Systems Management web application
Group:          Applications/System
License:        GPLv2+
URL:            http://www.puppetlabs.com
Source0:        http://yum.puppetlabs.com/sources/%{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       ruby(abi) = 1.8, rubygems, rubygem-rake, ruby-mysql
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
rm -rf %{buildroot}

install -p -d -m0755 %{buildroot}%{_datadir}/%{name}
install -p -d -m0755 %{buildroot}%{_datadir}/%{name}/vendor
install -p -d -m0755 %{buildroot}%{_datadir}/%{name}/public
install -p -d -m0755 %{buildroot}%{_defaultdocdir}/%{name}-%{version}
cp -p -r app bin config db ext lib public Rakefile script spec %{buildroot}%{_datadir}/%{name}
install -Dp -m0644 VERSION %{buildroot}%{_datadir}/%{name}/VERSION
install -Dp -m0644 config/database.yml.example %{buildroot}%{_datadir}/%{name}/config/database.yml

# Add sysconfig and init script
install -Dp -m0755 %{confdir}/%{name}.init %{buildroot}%{initrddir}/puppet-dashboard
install -Dp -m0644 %{confdir}/%{name}.sysconfig %{buildroot}%{_sysconfdir}/sysconfig/puppet-dashboard

# Not all plugins are installed from our source file.
mkdir %{buildroot}%{_datadir}/%{name}/vendor/plugins
for plugin in authlogic inherited_resources jrails object_daddy resources_controller timeline_fu will_paginate; do
  cp -p -r vendor/plugins/$plugin %{buildroot}%{_datadir}/%{name}/vendor/plugins/$plugin
done

cp -p -r vendor/gems %{buildroot}%{_datadir}/%{name}/vendor
cp -p -r vendor/rails %{buildroot}%{_datadir}/%{name}/vendor

chmod a+x %{buildroot}%{_datadir}/%{name}/script/* 

for file in $(find %{buildroot} -size 0) ; do
    rm -f "$file"
done

rm -f -r %{buildroot}%{_datadir}/%{name}/.git

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
rm -rf %{buildroot}

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%{_datadir}/%{name}/config/database.yml
%{initrddir}/puppet-dashboard
%{_sysconfdir}/sysconfig/puppet-dashboard
%doc CHANGELOG COPYING README.markdown
%changelog
* Fri Jul 30 2010 James Turnbull <james@puppetlabs.com> - 1.0.3-3
- Fixed database.yml error

* Fri Jul 30 2010 James Turnbull <james@puppetlabs.com> - 1.0.3-2
- Fixed VERSION issue

* Thu Jul 29 2010 James Turnbull <james@puppetlabs.com> - 1.0.3-1
- Incremented version

* Sat Jul 15 2010 James Turnbull <james@puppetlabs.com> - 1.0.1-2
- Added MySQL requires
- Configured database.yml file

* Fri Jul 14 2010 James Turnbull <james@puppetlabs.com> - 1.0.1-1
- Removed rspec-rails plugin
- Removed doc files
- Updated for Puppet Labs 1.0.1 release

* Mon May 03 2010 Todd Zullinger <tmz@pobox.com> - 1.0.0-4
- Don't define %%_initrddir, rpm has defined it since the Red Hat Linux days
  (When RHEL-6 and Fedora-9 are the oldest supported releases, %%_initddir should
  be used instead.)
- %%global is preferred over %%define
  https://fedoraproject.org/wiki/Packaging:Guidelines#Source_RPM_Buildtime_Macros
- Drop use of %%{__mkdir} and similar, the macros add nothing but clutter
- Fix Source0 URL

* Mon May  3 2010 James Turnbull <james@lovedthanlost.net> - 1.0.0-3
- Fixed init script type

* Fri Apr 16 2010 James Turnbull <james@lovedthanlost.net> - 1.0.0-2
- Added init script support
- Imported changes for older RPM builds provided by Michael Stahnke

* Thu Mar 26 2010 James Turnbull <james@lovedthanlost.net> - 1.0.0-1
- Initial release.

