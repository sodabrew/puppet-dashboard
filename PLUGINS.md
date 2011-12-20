# Dashboard Plugins

The dashboard has a prototype plugin system, intended to allow extensions of
the system to be added.  It is literally a prototype: it has had some use, but
is far from finished, has serious known design headaches, and is generally
inflexible.

If you intend to use it you should absolutely expect to modify the core of the
system to support your needs.  If you are not comfortable with that the odds
are very poor that you will be able to produce the plugin you wish.

The basis of our plugin system is the standard Rails plugin system, but we
have extended that to support features that are not generally available like
database migrations in plugins, and the ability to inject HTML into existing
pages from your plugin.

## Adding a plugin

Create a [Rails style plugin](http://guides.rubyonrails.org/plugins.html)
directory in `vendor/plugins`.

This has the standard Rails plugin bits: `app/*`, `db/migrate`, `init.rb`, etc.

There are special behaviours required or supported around database migrations,
and adding hooks from the `init.rb` file to extend existing views.

## Database migrations

Your migrations must be named `${date}_plugin_${plugin_name}_*.rb` in order to
work.  eg: `20110129205337_plugin_example` for the `example` plugin.

They are otherwise identical to regular Rails migrations.

## Hooks in `init.rb`

Generally a plugin needs to do more than just add views, it needs to extend
existing content.  We have a hook system to support that which you interact
with from your `init.rb` to add callbacks.

Adding a callback is simple: you invoke `Registry.add_callback` as a global,
passing the appropriate *scope*, *hook name*, *priority pattern*, and either a
*value* and a *block* to it.

### The scope argument

The *scope* is an arbitrary `Symbol` naming where in the Dashboard or other
plugins the hook is invoked.  Core Dashboard uses `:core`, generally, but
there is no actual requirement to stick to that standard.

### The hook name argument

The *hook name* is an arbitrary `Symbol`.  The way to find these is to grep
through the invocation of hooks in the system; look for `each_callback` and
`find_first_callback` in the code to find out the available names and all.

Finding the callbacks you are interested in that way is going to be essential
in a minute, by the way, so don't skip over it or whatever.

### The priority pattern argument

The *priority pattern* is a `String` name for your hook.  It can be anything
you want it to be.  Invocations happen in the standard Ruby string sort order
based on those.

Most uses of the priority pattern start with a three digit number, so if you
already know all the other hooks that will attach to the plugins you can
totally position yours where you want.  If you don't, though, just fiddle the
first digit until your HTML winds up where you want or whatever.

### The value or block argument

Finally, the *block* is the code that you want invoked to actually do
something.  This can be used in entirely arbitrary ways, so you absolutely
have to read each and every call site to understand how that block will be
invoked.

The alternative is to pass a *value*, an arbitrary Ruby thing.  This replaces
the block with, obviously, a static value.

This is where that greping through the tree I mentioned turns out useful:
because you found the invocation site you can just read the code there,
typically in a HAML file, to work out how your hook will be invoked.

#### `each_callback` hooks

As a guide, the `Registry.each_callback` method returns the block as a
callable object, which the call site is free to do with anything it wishes.
The standard pattern is, of course, that you just call the hook method and
pass some arguments, but there are no assurances of anything here.

Theoretically an `each_callback` hook could use the value argument, but so far
nothing does.  These pretty much always turn out to be consumed as code.

The `each_callback` hooks invoke *all* hooks, and typically composite their
content to the screen somehow.  Don't forget to read the HAML surrounding the
invocation site to understand how you structure and style your content to work
with the system.

Once you have read every invocation site for that hook, you should have a
picture of the callback options.  Typically the Rails `renderer` is passed as
the first argument to the block, which you can use to render stuff:

    Registry.add_callback :core, :global_nav_widgets, "500_example" do |renderer|
      renderer.render 'shared/my_nav_widgets'
    end

Sometimes additional arguments are passed; they are typically the internal
model objects from the Dashboard or the other plugin.  They are not
documented; just go read the source code to understand how you can interact
with those.

#### `find_first_callback` hooks

The other common invocation path is using `Registry.find_first_callback`, in
which the first "true" result from a block determines the outcome as far as
the plugin system is concerned.

This is used to do, like the previous style of hook, entirely arbitrary
things. Some of them need value arguments, others need blocks.  The only way
to know which is which is to read the invocation site, because all decisions
about *consumption* of the thing are delegated to the invoker.

Unlike the previous version there is pretty much zero common pattern in
calling here.  Currently this only uses code blocks, and invoke them with an
argument to let you make dynamic decisions about the result.

Theoretically someone might start using the static value ability to let you
specify things statically, but obviously you can't know that without reading
every invocation site, and ensuring they will all work with the static
argument.

## Examples

There are some examples available in `lib/core_callbacks.rb`, where we use
these hooks as part of the Dashboard itself.  That also gives you an idea
where in the priority list you can slip your stuff relative to our code -
though, obviously, you can't know what other plugins do.

## Adding hooks

When you start building anything that interacts with the rest of the system at
all you will doubtless find that the invocations are unclear, and that there
are not hooks that you need.

Add them.  Send us a patch.  We will merge extra hooks to support your code
without great qualms.

# Installing Plugins

Plugins should be installed and uninstalled using the provided Rake tasks.  To
see a complete list of tasks, please use `rake -T`.  The following tasks are
specific to installing and uninstalling plugins.

    % rake -T
    ...
    rake puppet:plugin:install        # Install a Dashboard plug-in
    rake puppet:plugin:uninstall      # Uninstall a Dashboard plug-in
    ...

NOTE: When a plugin is installed, the CSS and JavaScript files are _copied_
into the public directory.  This means it is possible for the plugin to become
de-synchronized with the application if it is not re-installed using the rake
task.
