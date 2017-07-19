[![Build Status](https://travis-ci.org/mediapeers/ansible-role-elasticsearch.svg?branch=master)](https://travis-ci.org/mediapeers/ansible-role-elasticsearch)

# Ansible Role for Elasticsearch
This is an Ansible role for [Elasticsearch](http://www.elasticsearch.org/).

**Note:** Only supports Elasticsearch 2.0 and newer.

## Features
- Support for installing plugins
- Support for installing and configuring EC2/S3 plugin
- Support for installing custom JARs in the Elasticsearch classpath (e.g. custom Lucene Similarity JAR)


## Enabling Added Features
### Configuring AWS EC2 / S3 plugin
The following variables need to be defined in your playbook or inventory:

- elasticsearch_aws_discovery: true
For just installing the s3 plugin in ES >= 5.x, for snapshot repo use:
- elasticsearch_aws_s3: true

The following variables provide a for now limited configuration for the plugin.
More options may be available in the future

- elasticsearch_plugin_aws_ec2_groups
- elasticsearch_plugin_aws_ec2_ping_timeout
- elasticsearch_plugin_aws_access_key
- elasticsearch_plugin_aws_secret_key
- elasticsearch_plugin_aws_region


### Installing plugins
You will need to define an array called `elasticsearch_plugins` in your playbook or inventory, such that:
```yaml
elasticsearch_plugins:
 - { name: '<plugin name>', url: '<[optional] plugin url>' }
 - ...
```

where if you were to install the plugin via bin/plugin, you would type:
`bin/plugin -install <plugin name>` or `bin/plugin -install <plugin name> -url <plugin url>`

Example for [https://github.com/elasticsearch/elasticsearch-mapper-attachments](https://github.com/elasticsearch/elasticsearch-mapper-attachments)
(`bin/plugin install elasticsearch/elasticsearch-mapper-attachments/1.9.0`):

```yaml
elasticsearch_plugins:
 - { name: 'elasticsearch/elasticsearch-mapper-attachments/1.9.0' }
```

Example for [https://github.com/imotov/elasticsearch-facet-script](https://github.com/imotov/elasticsearch-facet-script)
(`bin/plugin install http://dl.bintray.com/content/imotov/elasticsearch-plugins/elasticsearch-facet-script-1.1.2.zip`):

```yaml
elasticsearch_plugins:
 - { name: 'facet-script', url: 'http://dl.bintray.com/content/imotov/elasticsearch-plugins/elasticsearch-facet-script-1.1.2.zip' }
```

### Installing Custom JARs
Custom jars are made available to the Elasticsearch classpath by being downloaded into the elasticsearch_home_dir/lib folder. 
An example of a custom jar can include a custom Lucene Similarity Provider. You will need to define an array called `elasticsearch_custom_jars`
in your playbook or inventory, such that:

```yaml
elasticsearch_custom_jars:
 - { uri: '<URL where JAR can be downloaded from: required>', filename: '<alternative name for final JAR if different from file downladed: leave blank to use same filename>', user: '<BASIC auth username: leave blank of not needed>', passwd: '<BASIC auth password: leave blank of not needed>' }
 - ...
```

### Configuring Thread Pools
Elasticsearch [thread pools](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-threadpool.html) can be configured using the `elasticsearch_thread_pools` list variable:

```yaml
elasticsearch_thread_pools:
  - "threadpool.bulk.type: fixed"
  - "threadpool.bulk.size: 50"
  - "threadpool.bulk.queue_size: 1000"
```

## Disable Java installation

If you prefer to skip the built-in installation of the Oracle JRE, use the `elasticsearch_install_java` flag:

`elasticsearch_install_java: false`

## Include role in a larger playbook
### Add this role as a git submodule
Checkout this project as a submodule under roles/:

```
$ git submodule add git@github.com:mediapeers/ansible-role-elasticsearch.git roles/mediapeers.elasticsearch
```

### Include this role in your playbook
Example playbook, with minimal set of variables defined:

```yaml
---
- name: My Playbook for Elasticsearch hosts
  hosts: all_es_nodes
  become: true
  vars:
    elasticsearch_version: 2.4
    elasticsearch_heap_size: 2g
  elasticsearch_cluster_name: my-personal-es-cluster
  roles:
    - mediapeers.elasticsearch
  tasks:
   # Your tasks
```

When installing newer ES versions (>2.4) also override download url like this:

`elasticsearch_download_url: "https://artifacts.elastic.co/downloads/elasticsearch"`


# Dependencies
No other Ansible roles.

# License
MIT

# Author Information
Stefan Horning <horning@mediapeers.com>

Based on the works of George Stathis - gstathis [at] traackr.com
