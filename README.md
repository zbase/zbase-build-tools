zbase-build-tools
=================

Scripts to build ZBase from source

#### Dependencies
 * CentOS 6 (We have tested on CentOS 6.2)
 * Autoconf >= 2.6
 * Boost-devel >= 1.41


#### How to build ?

Update the checkout file with source repositories and checkout tags/commitids and execute build scripts.

To build a rpm of ZBase, use:

    $ ./build-rpm.sh

To build from source to a given prefix, use:

    $ ./build.sh prefix_path

#### How to start zbase-server after RPM installation ?

Create server parameter config files as follows:

Config 1 (Server settings): /etc/sysconfig/memcached

    PORT="11211"
    USER="nobody"
    MAXCONN="65535"
    OPTIONS="-E /opt/zbase/lib/memcached/ep.so -e 'min_data_age=1200;queue_age_cap=1200;max_size=64424509440;ht_size=12582917;chk_max_items=500000;chk_period=3600;keep_closed_chks=true;restore_file_checks=false;restore_mode=false;inconsistent_slave_chk=false;ht_locks=100000;tap_keepalive=600;max_evict_entries=2000000;kvstore_config_file=/etc/sysconfig/memcached_multikvstore_config'"

Config 2 (KVStore settings): /etc/sysconfig/memcached_multikvstore_config

    {
      "kvstores" : {
        "kvstore1" : {
          "dbname" : "/db/zbase/ep.db",
          "db_shards" : 9,
          "data_dbnames" : [
            "/db/zbase/ep.db"
          ]
        }
      }
    }
    
Server can be started using following command:

    # /etc/init.d/memcached
    
To setup replication to another server, 

Set inconsistent_slave_chk=true in secondary server config
    
Add a config for vbucketmigrator, /etc/sysconfig/vbucketmigrator with following contents:

    TAPNAME=replication
    SLAVE=IP_ADDRESS
    
Start vbucketmigrator

    # /etc/init.d/vbucketmigrator start


#### How to start zbase-server after building from source ?

Create kvstore config as above at /tmp/kvstore.json and execute:

    $ $PREFIX_PATH/bin/memcached -u nobody -c 50 -P /tmp/memcached.pid -v -d -r -p 11211 -E $PREFIX_PATH/lib/memcached/ep.so -e 'kvstore_map_vbuckets=false;min_data_age=0;queue_age_cap=900;tap_noop_interval=800;chk_max_items=5000000;keep_closed_chks=true;restore_file_checks=false;inconsistent_slave_chk=false;tap_keepalive=600;ht_locks=1000;kvstore_config_file=/tmp/kvstore.json' &> /tmp/zbase.log &
