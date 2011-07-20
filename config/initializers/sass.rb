# Sass fails to regenerate in production mode at an appropriate time, which
# yields a server error (500), followed by some unstyled content.  Unsetting
# this constant in an initializer prompts Sass to ensure that the stylesheets
# are generated at the appropriate time.  This only applies to the initial
# page load; subsequent requests are appropriately cached and will exhibit the
# former behavior when provoked.
if defined?(Sass::RAILS_LOADED)
  module Sass
    remove_const(:RAILS_LOADED)
  end
end
