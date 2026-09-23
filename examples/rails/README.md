# Rails example

This directory is not a Rails application and it does not proxy the API.

In a Rails console, on the server, read the key from the environment. Do not put the key in a view.

```ruby
require "selltostate"
sts = SellToState.new(api_key: ENV.fetch("STS_API_KEY"))
sts.whoami
```
