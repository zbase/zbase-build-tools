Summary:      Membase for Zynga 
Name:         membase 
Version:      %{?version}
Release:      1
License:      Zynga
Group:        Development/Languages
BuildRoot:    %{?buildpath}

Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1

%description
Membase is memcache+ep-engine. This is membase for Zynga.

%post
sudo /sbin/ldconfig /opt/membase/lib /opt/membase/lib/memcached

%files
/*

%changelog
* Mon Apr 9 2012 <nigupta@zynga.com> 
- Initial version
