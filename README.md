SnapSearch-Client-Ruby
======================

[![Build Status](https://travis-ci.org/SnapSearch/SnapSearch-Client-Ruby.png?branch=master)](https://travis-ci.org/SnapSearch/SnapSearch-Client-Ruby)

Snapsearch Client Ruby is Ruby based framework agnostic HTTP client library for SnapSearch (https://snapsearch.io/).

Snapsearch is a search engine optimisation (SEO) and robot proxy for complex front-end javascript & AJAX enabled (potentially realtime) HTML5 web applications.

Search engines like Google's crawler and dumb HTTP clients such as Facebook's image extraction robot cannot execute complex javascript applications. Complex javascript applications include websites that utilise AngularJS, EmberJS, KnockoutJS, Dojo, Backbone.js, Ext.js, jQuery, JavascriptMVC, Meteor, SailsJS, Derby, RequireJS and much more. Basically any website that utilises javascript in order to bring in content and resources asynchronously after the page has been loaded, or utilises javascript to manipulate the page's content while the user is viewing them such as animation.

Snapsearch intercepts any requests made by search engines or robots and sends its own javascript enabled robot to extract your page's content and creates a cached snapshot. This snapshot is then passed through your own web application back to the search engine, robot or browser.

Snapsearch's robot is an automated load balanced Firefox browser. This Firefox browser is kept up to date with the nightly versions, so we'll always be able to serve the latest in HTML5 technology. Our load balancer ensures your requests won't be hampered by other user's requests.

For more details on how this works and the benefits of usage see https://snapsearch.io/

SnapSearch provides similar libraries in other languages: https://github.com/SnapSearch/Snapsearch-Clients

Installation
------------

SnapSearch-Client-Ruby is available through Rubygems and can be installed via:

```
gem install snapsearch-client-ruby
```

or add it to your Gemfile like this:

```
gem "snapsearch-client-ruby", "~> 1.0.0"
```

For all supported Ruby versions check out the `.travis.yml` file.

Usage
-----

SnapSearch Client Ruby is a rack based middleware for SnapSearch. It works with all rack based frameworks including Rails and Sinatra. You should place the SnapSearch middleware on top of other middleware so it gets called relatively early in the request response cycle. The middleware is also available as individual objects, which can be called independently. In non-rack based frameworks, it is best to start SnapSearch at the entry point of your application.

**The examples folder in this repository contains a rack and sinatra example showing the context of using the SnapSearch middleware in your application. The below instructions is an abridged version of the examples.**

For full documentation on the API and API request parameters see: https://snapsearch.io/documentation

**By the way, you need to blacklist non-html resources such as `sitemap.xml`. This is explained in https://snapsearch.io/documentation#notes**

### Basic Usage

In your `config.ru` file, import the `rack/snap_search`, then setup the configuration:

```ruby
require 'rack/snap_search'

use Rack::SnapSearch do |config|
    
    config.email = 'user@example.com'
    
    config.key = 'API_KEY_HERE'
    
end
```

This will handle everything from the detection of the robot to outputting the cached snapshot. If it detects the robot, it will skip execution of the application and output the snapshot response. The default configuration is to output only the status, location headers and body content. This is because some headers may cause encoding errors.

Here is an example of the response hash from SnapSearch: 

```ruby
response = {
    "cache"             => true/false,
    "callbackResult"    => "",
    "date"              => 1390382314,
    "headers"           => [
        {
            "name"  => "Content-Type",
            "value" => "text/html"
        }
    ],
    "html"              => "<html></html>",
    "message"           => "Success/Failed/Validation Errors",
    "pageErrors"        => [
        {
            "error"   => "Error: document.querySelector(...) is null",
            "trace"   => [
                {
                    "file"      => "filename",
                    "function"  => "anonymous",
                    "line"      => "41",
                    "sourceURL" => "urltofile"
                }
            ]
        }
    ],
    "screensot"         => "BASE64 ENCODED IMAGE CONTENT",
    "status"            => 200
}
```

### Advanced Usage

The rack based middleware has many options and if you use the objects independently they are even more flexible. These options can be seen in context in the examples folder:

```ruby
use Rack::SnapSearch do |config|
    
    config.email = 'user@example.com'
    
    config.key = 'API_KEY_HERE'

    # Optional: The API URL to send requests to.
    config.api_url = 'https://snapsearch.io/api/v1/robot' # Default
    
    # Optional: The CA Cert file to use when sending HTTPS requests to the API.
    config.ca_cert_file = SnapSearch.root.join('resources', 'cacert.pem') # Default
    
    # Optional: Check X-Forwarded-Proto if you use a load balancer that proxies https to http connections
    config.x_forwarded_proto = true # Default
    
    # Optional: Extra API parameters that is sent to SnapSearch
    config.parameters = {} # Default
    
    # Optional: Whitelisted routes. Should be an Array of Regexp instances.
    config.matched_routes = [] # Default
    
    # Optional: Blacklisted routes. Should be an Array of Regexp instances.
    config.ignored_routes = [] # Default
    
    # Optional: A path of the JSON file containing the user agent whitelist & blacklist.
    config.robots_json = SnapSearch.root.join('resources', 'robots.json') # Default
    
    # Optional: A path to the JSON file containing a single Hash with the keys `ignore` and `match`. These keys contain Arrays of Strings (user agents)
    config.extensions_json = SnapSearch.root.join('resources', 'extensions.json') # Default
    
    # Optional: Set to `true` to check file extensions in the URL, this will check if the URL contains invalid file extensions.
    #If there is no file extension, then there's no problem. But if there is, it could be a request to a static file. In which case it is not HTML that we want to intercept.
    #It is typically easier to simply whitelist or blacklist file based routes.
    #You do not need this unless your application server (not your HTTP server) is serving up static files. Like binary content, images and non-HTML text files.
    config.check_file_extensions = false # Default
    
    # Optional: A block to run when an exception occurs when making requests to the API.
    config.on_exception do |exception|
        p exception
    end
    
    # Optional: A block to run before the interception of a bot. You can use this to do client side caching.
    config.before_intercept do |url|
        #Get a client side cached snapshot
    end
    
    # Optional: A block to run after the interception of a bot. You can use this to do client side caching.
    config.after_intercept do |url, response|
        #Save the client side cached snapshot (the cached time should be less then the cached time you passed to SnapSearch, we recommend half the SnapSearch cachetime)
    end
    
    # Optional: A block to manipulate the response from the SnapSearch API if a bit is intercepted. The headers in this case represent [{name: "HEADERKEY", value: "HEADERVALUE"}, ...]
    config.response_callback do |status, headers, body|        
        [ status, headers, body ]
    end

end
```

Check out the resources folder containing the `robots.json` and `extensions.json`. The `robots.json` contains all the Search Engine and Social App robot user agents we're currently checking for. The `extensions.json` contains all the valid file extensions that a web application might use for HTML resources. Feel free to edit them and use your own JSON files for the middleware. Always make sure to ignore the "SnapSearch" robot, otherwise you could get into an infinite interception loop.

The Detector instance's robot and extensions hash are publicly accessible and can be modified during runtime.

```
# Add a user agent to match against:
detector.robots['match'] << 'NewRobot'

# Add a user agent to ignore:
detector.robots['ignore'] << 'MyRobot'

detector.extensions['ruby'] << 'myvalidrubyfileextensionforhtmlresources'
```

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
