# graft

Graft is a vendor-independent collaborative hooking library for Ruby.

## Quick start

Add the gem:

```
# without bundler
gem install graft --version '>= 0.3'

# with bundler
bundle add graft --version '>= 0.3'
```

Example:

```
require "graft"
require "net/http"

# define additional behaviour
hook = Graft::Hook["Net::HTTP.start"].add do
  append do |stack, env|
    host = env[:args][0]
    port = env[:args][1] || Net::HTTP.default_port

    puts "HTTP start: #{host}:#{port}"

    # call original
    stack.call(env)
  ensure
    puts "HTTP end: #{host}:#{port} closed"
  end
end

# inject the code
hook.install

# this will now emit output
uri = URI("https://github.com/robots.txt")
Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
  req = Net::HTTP::Get.new(uri)
  res = http.request req
  $stdout.write res.body.gsub(/^/, "|  ")
end
```


## Rationale

Monkeypatching is a common practice in Ruby. Historically the method of choice
was renaming, defining, then aliasing a method in a chain, which Rails codified
as an "alias method chain" (hereafter AMC or simply "chaining").

While still useful in specific cases, AMC is fairly invasive and has
limitations. To that end `Module#prepend` (hereafter simply "prepending") was introduced.

A sad state of affair is that prepending and AMC are fundamentally
incompatible: AMC implements a form of masqueraded inheritance within a single
Module and thus always operates both on the same receiver and the same
ancestor level (the instance's singleton class).

As a consequence, mixing AMC and prepend is dangerous: depending on where
chaining is done, a chained method call ends up "rolling back" the walk up the
inheritance chain that prepend relies on, creating an infinite recursive loop.

It follows that monkeypatch implementors have to be very careful as to how they
monkeypatch to either not mix both or ensure they mix without creating this
situation. Both require extreme care and the latter is vulnerable to any
other new implementor breaking everything again.

This is made worse by monkeypatching being typically implemented in an ad-hoc
manner for each patch point.

Secondly, for the sake of backwards compatibility, monkeypatching has to be
carfeful catering for keyword argument handling changes that happened during
the Ruby 2.6->2.7->3.0 transition. If done improperly, and depending how
arguments are passed on the call site, argument forwarding may either mistakenly fold
keyword argument into splatted `*args` or silently drop keyword arguments. In
both cases the original method ends up receiving incorrect arguments.

Graft aims to encapsulate and resolve these classes of issues and provide a
straightforward API for collaborative hooking.

## Historical `graft` gem

The `graft` gem name was previously owned on rubygems.org, abandoned, and
subsequently the name was transferred ownership to become this gem. Due to a
rubygems.org security policy, old versions (more than 30 days old) cannot be
yanked.

Specifically versions `0.1.0`, `0.1.1`, `0.2.0`, and `0.2.1` have no
relationship to this gem.

Thanks to Patrick Reagan for agreeing on the ownership transfer!
