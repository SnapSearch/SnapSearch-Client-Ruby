SnapSearch-Client-Ruby
======================

[![Build Status](https://travis-ci.org/SnapSearch/SnapSearch-Client-Ruby.png?branch=master)](https://travis-ci.org/SnapSearch/SnapSearch-Client-Ruby)

Snapsearch Client Ruby is Ruby based framework agnostic HTTP client library for SnapSearch (https://snapsearch.io/).

SnapSearch provides similar libraries in other languages: https://github.com/SnapSearch/Snapsearch-Clients

Installation
------------

Usage
-----

Development
---------

Get the bundler dependency management tool.

```
gem install bundler
```

Install/update all dependencies:

```
bundle install
```

See all build tasks:

```
bundle exec rake -T
```

Make your changes. Release a new version tag with (see the other `rake version:bump:... etc` tasks):

```
bundle exec rake version:bump
```

Synchronise and push the tag to Github:

```
git push
git push --tags
```

Create the gem package:

```
bundle exec rake gem
```

Push the gem to Ruby Gems:

```
gem push pkg/snapsearch-client-ruby-MAJOR.MINOR.PATCH.gem
```

Tests
----

Tests are written with RSpec. Run tests with `bundle exec rspec spec/`