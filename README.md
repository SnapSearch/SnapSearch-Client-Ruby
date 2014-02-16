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

Setting Up the Detector
-----------------------

The `Detector` class detects if the incoming request is coming from a robot or not.

Detects if the request came from a search engine robot. It will intercept in cascading order:

1. on a GET request
2. on an HTTP or HTTPS protocol
3. not on any ignored robot user agents
4. not on any route not matching the whitelist
5. not on any route matching the blacklist
6. not on any static files that is not a PHP file if it is detected
7. on requests with _escaped_fragment_ query parameter
8. on any matched robot user agents

You can customize a few aspects of this process:

#### User Agents

Most robots send a unique `user-agent` HTTP header that we match against to confirm if it indeed a request from a robot.  
We also ignore certain user agents, such as the SnapSearch robot.

The list of user agents to match and ignore is contained in `data/robots.json`. You can customize this list through the Detector instance
you are working with:

```
# Retrieve the list of user agents to match and ignore:
detector.robots # => { 'match' => ['SomeRobot', 'AnotherRobot'], 'ignore' => ['SnapSearch'] }

# Add a user agent to match against:
detector.robots['match'] << 'NewRobot'

# Add a user agent to ignore:
detector.robots['ignore'] << 'MyRobot'

# Set a new list of user agents to match and ignore:
detector.robots = { 'match' => ['WebScraper', 'SillyBot'], 'ignore' => ['MyBotToIgnore'] }

# Load from a custom JSON file:
detector.robots_json = './my_robots.json'
detector.robots # => { 'match' => ['MyCustomBot', 'AnotherRobot'], 'ignore' => ['MyLoadedBotFromJSON'] }
```

Tests
----

Tests are written with RSpec. Run tests with `bundle exec rspec spec/`