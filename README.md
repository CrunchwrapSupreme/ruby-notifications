# Notifications

A simple interface for the org.freedesktop.Notifications DBus service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'notifications'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install notifications

## Usage

```ruby
require 'notifications'
# Create the service interface
service = Notifications::NotificationService.new
# 'appname' is only required named parameter but isn't very
# useful on its own.
notification = Notifications::Notification.new(appname: "test",
                                               summary: "test",
                                               body: "A test notification")

# Retrieve the service object. Due to DBus protocol we can't hide this detail
# without compromising the ability to fail gracefully.
service.try_introspect

# Send the notification
service.send_notification notification

# Can also short-hand service.close_notification in this instance
# as the service interface tracks the last sent notification for
# improved usability.
service.close_notification notification

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CrunchwrapSupreme]/notifications.
