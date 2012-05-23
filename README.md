# Sendgrid::Parse

Gem to dynamically set or change the encoding type for fields, ie params from SendGrid Parse API (http://docs.sendgrid.com/documentation/api/parse-api-2/)

Requires JSON for parsing 'charsets' envelope.

Works on 1.8.x via Iconv, and 1.9.x via built-in encoding support.

## Installation

Add this line to your application's Gemfile:

    gem 'sendgrid-parse'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sendgrid-parse

## Usage

```ruby
require 'sendgrid-parse'

# Example from SendGrid
params = {
  :charsets => '{"text":"windows-1252"}',
  :text => "Hello Euro \x80"
}

new_params = Sendgrid::Parse::EncodableHash.new(params)
new_params.encode!('UTF-8')

new_params[:text]           # => "Hello Euro €"
new_params[:text].encoding  # => #<Encoding:UTF-8>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
