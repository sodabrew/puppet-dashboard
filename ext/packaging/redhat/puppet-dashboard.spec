%global confdir ext/packaging/redhat
%global initrddir /etc/rc.d/init.d

Name:           puppet-dashboard
Version:        1.1.0
Release:        1%{?dist}
Summary:        Systems Management web application
Group:          Applications/System
License:        GPLv2+
URL:            http://www.puppetlabs.com
Source0:        http://yum.puppetlabs.com/sources/%{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       ruby(abi) = 1.8, rubygems, rubygem-rake, ruby-mysql
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(id -un)

Requires(pre):    shadow-utils
Requires(post):   chkconfig
Requires(preun):  chkconfig
Requires(preun):  initscripts
Requires(postun): initscripts

%description
Puppet Dashboard is a systems management web application for managing
Puppet installations and is written using the Ruby on Rails framework.

%pre
getent group puppet-dashboard > /dev/null || groupadd -r puppet-dashboard
getent passwd puppet-dashboard > /dev/null || \
  useradd -r -g puppet-dashboard -d %{_datadir}/puppet-dashboard -s /sbin/nologin \
  -c "Puppet Dashboard" puppet-dashboard
exit 0

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT

install -p -d -m0755 $RPM_BUILD_ROOT/%{_datadir}/%{name}
install -p -d -m0755 $RPM_BUILD_ROOT/%{_datadir}/%{name}/log
install -p -d -m0755 $RPM_BUILD_ROOT/%{_datadir}/%{name}/public
install -p -d -m0755 $RPM_BUILD_ROOT/%{_datadir}/%{name}/tmp
install -p -d -m0755 $RPM_BUILD_ROOT/%{_datadir}/%{name}/vendor
install -p -d -m0755 $RPM_BUILD_ROOT/%{_defaultdocdir}/%{name}-%{version}
cp -p -r app bin config db ext lib public Rakefile script spec $RPM_BUILD_ROOT/%{_datadir}/%{name}
install -Dp -m0644 config/database.yml.example $RPM_BUILD_ROOT/%{_datadir}/%{name}/config/database.yml
install -Dp -m0644 RELEASE_NOTES.md $RPM_BUILD_ROOT/%{_datadir}/%{name}/RELEASE_NOTES.md
install -Dp -m0644 VERSION $RPM_BUILD_ROOT/%{_datadir}/%{name}/VERSION

# Add sysconfig and init script
install -Dp -m0755 %{confdir}/%{name}.init $RPM_BUILD_ROOT/%{initrddir}/puppet-dashboard
install -Dp -m0644 %{confdir}/%{name}.sysconfig $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/puppet-dashboard

cp -p -r vendor $RPM_BUILD_ROOT/%{_datadir}/%{name}/

chmod a+x $RPM_BUILD_ROOT/%{_datadir}/%{name}/script/*

rm -f -r $RPM_BUILD_ROOT/%{_datadir}/%{name}/.git*

mv CHANGELOG timestamp
iconv -f ISO-8859-1 -t UTF-8 -o CHANGELOG timestamp
touch -r timestamp CHANGELOG
rm timestamp

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

%files
%defattr(-,root,root,0755)
%{_datadir}/%{name}
%attr(0640,puppet-dashboard,puppet-dashboard) %config(noreplace) %{_datadir}/%{name}/config/database.yml
%{initrddir}/puppet-dashboard
%{_sysconfdir}/sysconfig/puppet-dashboard
%attr(-,puppet-dashboard,puppet-dashboard) %{_datadir}/%{name}/config/environment.rb
%attr(-,puppet-dashboard,puppet-dashboard) %{_datadir}/%{name}/public
%attr(-,puppet-dashboard,puppet-dashboard) %dir %{_datadir}/%{name}/log
%attr(-,puppet-dashboard,puppet-dashboard) %dir %{_datadir}/%{name}/tmp

%doc CHANGELOG COPYING README.markdown README_PACKAGES.markdown RELEASE_NOTES.md

%changelog
* Thu Apr 07 2011 James Turnbull <james@puppetlabs.com> - 1.1.0-1
- Removed zero byte file deletion
- Incremented version

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

