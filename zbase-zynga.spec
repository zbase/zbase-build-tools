Summary:      ZBase - A high performance inmemory+disk NoSQL database
Name:         zbase-server
Version:      %{?version}
Release:      1
License:      Apache 2.0
Group:        Development/Languages
BuildRoot:    %{?buildpath}

Requires(rpmlib): rpmlib(CompressedFileNames) <= 3.0.4-1 rpmlib(PayloadFilesHavePrefix) <= 4.0-1

%description
ZBase - A high performance in-memory+disk NoSQL database

%post
/sbin/ldconfig /opt/zbase/lib /opt/zbase/lib/memcached

%files
/opt/zbase/*
/etc/init.d/*

%clean
