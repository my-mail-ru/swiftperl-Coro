Name:          swiftperl-Coro
Version:       %{__version}
Release:       %{!?__release:1}%{?__release}%{?dist}
Summary:       Swift wrapper for Perl module Coro

Group:         Development/Libraries
License:       MIT
URL:           https://github.com/my-mail-ru/%{name}
Source0:       https://github.com/my-mail-ru/%{name}/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz
BuildRoot:     %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: swift
BuildRequires: swift-packaging
BuildRequires: perl-devel
BuildRequires: perl-libs
BuildRequires: swiftperl
BuildRequires: perl-Coro
Requires:      swiftperl
Requires:      perl-libs
Requires:      perl-Coro

%swift_find_provides_and_requires

%description
Swift wrapper for Perl module Coro.

%{?__revision:Built from revision %{__revision}.}


%prep
%setup -q
%swift_patch_package


%build
%swift_build


%install
rm -rf %{buildroot}
rm -f .build/release/libCPerlCoro.so
%swift_install
%swift_install_devel


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{swift_libdir}/*.so
%{swift_moduledir}/*.swiftmodule
%{swift_moduledir}/*.swiftdoc
%{swift_clangmoduleroot}/CPerlCoro
