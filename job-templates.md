---
title: Job Templates
---

## Unit Testing with `bosh-template` gem <a id="unit-testing"></a>

`bosh-template` Ruby gem could be used for unit testing your job templates. Unit testing of job templates becomes even more important once they contain more complex ERB logic that may perform validation or data transformation.

See example of unit tests in a production release: [https://github.com/cloudfoundry/bosh-dns-aliases-release/blob/master/spec/bosh-dns-aliases_spec.rb](https://github.com/cloudfoundry/bosh-dns-aliases-release/blob/master/spec/bosh-dns-aliases_spec.rb).

Assuming we have a job `web-server` with a following `config.json` ERB template:

```ruby
<%=

port = p("port")

if port &lt; 1024 or port &gt; 4000
  raise "Ports lower than 1024 or higher than 4000 are not allowed"
end

JSON.dump("port" => port)

%>
```

To start unit testing `web-server` job, add `Gemfile` to the root of your release so that `bundler` gem can install all dependencies necessary for testing:

```ruby
source 'https://rubygems.org'

group :development, :test do
  gem 'bosh-template'
  gem 'rspec'
  gem 'rspec-its'
end
```

Then run `bundle install` from the same directory to download and install specified gems.

Now that necessary dependencies are installed, let's add `spec/jobs/web_server_spec.rb` to test if conditional within our `config.json` template:

```ruby
require 'rspec'
require 'json'
require 'bosh/template/test'

describe 'web-server job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:job) { release.job('web-server') }

  describe 'config.json' do
    let(:template) { job.template('config/config.json') }

    it 'raises error if given port is < 1024' do
      expect {
        template.render("port" => 1023)
      }.to raise_error "Ports lower than 1024 or higher than 4000 are not allowed"
    end

    it 'raises error if given port is > 4000' do
      expect {
        template.render("port" => 4001)
      }.to raise_error "Ports lower than 1024 or higher than 4000 are not allowed"
    end

    it 'configures port successfully' do
      config = JSON.parse(template.render("port" => 1024))
      expect(config['port']).to eq(1024)

      config = JSON.parse(template.render("port" => 4000))
      expect(config['port']).to eq(4000)
    end
  end
end
```

Above set of tests provides enough gurantee that our ERB template is validating and passing down correct configuration to the web server binary.

At this point release directory will look something like this:

```
web-server-release $ tree .
.
├── Gemfile
├── Gemfile.lock
├── jobs
│   └── web-server
│       ├──templates
│       │  └── config.json
│       ├── spec
│       └── monit
└── spec
    └── jobs
        └── web_server_spec.rb
```

### Instance configuration

`bosh-template` gem provides default values for `spec.*` ERB accessors:

```ruby
config = JSON.parse(template.render({...}))
expect(config['address']).to eq('my.bosh.com')
expect(config['az']).to eq('az1')
expect(config['bootstrap']).to eq(false)
expect(config['deployment']).to eq('my-deployment')
expect(config['id']).to eq('xxxxxx-xxxxxxxx-xxxxx')
expect(config['index']).to eq(0)
expect(config['ip']).to eq('192.168.0.0')
expect(config['name']).to eq('me')
expect(config['network_data']).to eq('bar')
expect(config['network_ip']).to eq('192.168.0.0')
expect(config['job_name']).to eq('me')
```

These values could be overriden to test particular behaviour:

```ruby
spec = Bosh::Template::Test::InstanceSpec.new(address: 'cloudfoundry.org', bootstrap: true)
config = JSON.parse(template.render({...}, spec: spec))
expect(config['address']).to eq('cloudfoundry.org')
expect(config['bootstrap']).to eq(true)
```

### Links configuration

By default no links are provided to the job, but they can be provided via `links:` key to the `#render` function.

```ruby
links = [
  Bosh::Template::Test::Link.new(
    name: 'primary_db',
    instances: [Bosh::Template::Test::LinkInstance.new(address: 'my.database.com')],
    properties: {
      'adapter' => 'sqlite',
      'username' => 'root',
      'password' => 'asdf1234',
      'port' => 4321,
      'name' => 'webserverdb',
    }
  )
]
config = JSON.parse(template.render({...}, consumes: links))
expect(config['db']['host']).to eq('my.database.com')
expect(config['db']['adapter']).to eq('sqlite')
expect(config['db']['username']).to eq('root')
expect(config['db']['password']).to eq('asdf1234')
expect(config['db']['port']).to eq(4321)
expect(config['db']['database']).to eq('webserverdb')
```
