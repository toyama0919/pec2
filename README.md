# pec2 [![Build Status](https://secure.travis-ci.org/toyama0919/pec2.png?branch=master)](http://travis-ci.org/toyama0919/pec2)

Run parallel ssh command for ec2.

Commands can run to multiple hosts at once using the ec2 tag.

required python.

## Examples

    $ bundle exec pec2 -t Project:project_a Stages:production -c 'hostname'

## sudo Examples

    $ bundle exec pec2 -t Project:project_a Stages:production -c 'sudo hostname' -P -s ${sudo_password}

## Parallel number control(150 threads)

    $ bundle exec pec2 -t Project:embulk Stages:production -c 'hostname' -P -p 150

## Installation

Add this line to your application's Gemfile:

    gem 'pec2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pec2

## Synopsis

    $ pec2

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Information

* [Homepage](https://github.com/toyama0919/pec2)
* [Issues](https://github.com/toyama0919/pec2/issues)
* [Documentation](http://rubydoc.info/gems/pec2/frames)
* [Email](mailto:toyama0919@gmail.com)

## Copyright

Copyright (c) 2016 toyama0919

See [LICENSE.txt](../LICENSE.txt) for details.
