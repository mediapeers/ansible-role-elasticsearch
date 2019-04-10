require 'spec_helper'

es_version = ANSIBLE_VARS.fetch('elasticsearch_version', '2.0.0')
es_major_version = es_version[0].to_i
es_aws_discovery = ANSIBLE_VARS.fetch('elasticsearch_aws_discovery', false)
es_aws_s3 = ANSIBLE_VARS.fetch('elasticsearch_aws_s3', false)

describe "Elastic Search setup" do
  describe package('oracle-java8-installer') do
    it { should be_installed }
  end

  describe package('elasticsearch') do
    it { should be_installed.with_version(ANSIBLE_VARS.fetch('elasticsearch_version', 'FAIL')) }
  end

  describe service('elasticsearch') do
    it { should be_enabled }
  end

  describe file('/usr/share/elasticsearch/') do
    it { should be_directory }
  end
end

if es_major_version == 2
  describe "Version 2.x configuration" do
    describe file('/etc/elasticsearch/elasticsearch.yml') do
      it { should be_file }
      if ANSIBLE_VARS.fetch('elasticsearch_cluster_name', false)
        its(:content) { should include("cluster.name: #{ANSIBLE_VARS.fetch('elasticsearch_cluster_name', 'FAIL')}") }
      end
      if ANSIBLE_VARS.fetch('elasticsearch_groovy_sandbox', false)
        its(:content) { should include("script.groovy.sandbox.enabled: true") }
      end
      ANSIBLE_VARS.fetch('elasticsearch_allowed_scripting_actions', []).each do |action|
        its(:content) { should include("script.#{action}: on") }
      end
    end

    describe file('/etc/elasticsearch/logging.yml') do
      it { should be_file }
    end

    describe file('/etc/default/elasticsearch') do
      it { should be_file }
      its(:content) { should include("ES_USER=#{ANSIBLE_VARS.fetch('elasticsearch_user', 'elasticearch')}") }
      its(:content) { should include("ES_GROUP=#{ANSIBLE_VARS.fetch('elasticsearch_group', 'elasticearch')}") }
      its(:content) { should include("MAX_OPEN_FILES=#{ANSIBLE_VARS.fetch('elasticsearch_max_open_files', '65535')}") }
    end

    describe file('/usr/share/elasticsearch/plugins/') do
      it { should be_directory }
    end

    describe file('/var/log/elasticsearch/') do
      it { should be_directory }
    end

    context "AWS plugin enabled", if: es_aws_discovery || es_aws_s3 do
      describe file('/usr/share/elasticsearch/plugins/cloud-aws/') do
        it { should be_directory }
      end

      describe file('/etc/elasticsearch/elasticsearch.yml') do
        its(:content) { should include("discovery.type: ec2") }
        its(:content) { should include("cloud.aws.access_key: '#{ANSIBLE_VARS.fetch('elasticsearch_plugin_aws_access_key', 'FAIL')}'") }
        its(:content) { should include("cloud.aws.secret_key: '#{ANSIBLE_VARS.fetch('elasticsearch_plugin_aws_secret_key', 'FAIL')}'") }
      end
    end

    context "No AWS discovery enabled", if: !es_aws_discovery do
      describe file('/etc/elasticsearch/elasticsearch.yml') do
        its(:content) { should_not include("discovery.type: ec2") }
      end
    end
  end
end

if es_major_version == 5
  describe "Version 5.x configuration" do
    describe file('/etc/elasticsearch/elasticsearch.yml') do
      it { should be_file }
      its(:content) { should include("cluster.name: #{ANSIBLE_VARS.fetch('elasticsearch_cluster_name', 'FAIL')}") }
    end

    describe file('/etc/default/elasticsearch') do
      it { should be_file }
      its(:content) { should include("MAX_OPEN_FILES=#{ANSIBLE_VARS.fetch('elasticsearch_max_open_files', '65536')}") }
      its(:content) { should include("ES_USER=#{ANSIBLE_VARS.fetch('elasticsearch_user', 'elasticearch')}") }
      its(:content) { should include("ES_GROUP=#{ANSIBLE_VARS.fetch('elasticsearch_group', 'elasticearch')}") }
    end

    describe file('/etc/elasticsearch/jvm.options') do
      it { should be_file }
      its(:content) { should include("-Xms#{ANSIBLE_VARS.fetch('elasticsearch_heap_size', 'FAIL')}") }
      its(:content) { should include("-Xmx#{ANSIBLE_VARS.fetch('elasticsearch_heap_size', 'FAIL')}") }
    end

    describe file('/usr/share/elasticsearch/plugins/') do
      it { should be_directory }
    end

    describe file('/var/log/elasticsearch/') do
      it { should be_directory }
    end

    context "AWS discovery plugin enabled", if: es_aws_discovery do
      describe file('/usr/share/elasticsearch/plugins/discovery-ec2/') do
        it { should be_directory }
      end

      describe file('/etc/elasticsearch/elasticsearch.yml') do
        its(:content) { should include("discovery.zen.hosts_provider: ec2") }
      end
    end

    context "AWS s3 plugin enabled", if: es_aws_s3 do
      describe file('/usr/share/elasticsearch/plugins/repository-s3/') do
        it { should be_directory }
      end
    end

    context "No AWS discovery enabled", if: !es_aws_discovery do
      describe file('/etc/elasticsearch/elasticsearch.yml') do
        its(:content) { should_not include("discovery.zen.hosts_provider: ec2") }
      end
    end
  end
end

if es_major_version == 6
  describe "Version 6.x configuration" do
    describe file('/etc/elasticsearch/elasticsearch.yml') do
      it { should be_file }
      its(:content) { should include("cluster.name: #{ANSIBLE_VARS.fetch('elasticsearch_cluster_name', 'FAIL')}") }
    end
  end

  context "AWS s3 plugin enabled", if: es_aws_s3 do
    describe file('/usr/share/elasticsearch/plugins/repository-s3/') do
      it { should be_directory }
    end
  end
end
