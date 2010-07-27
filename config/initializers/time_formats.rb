# TODO make format customizable through an external configuration file.
Time::DATE_FORMATS.update(
  # :default => lambda{|time| time.strftime('%m/%d/%y ') + time.strftime('%I:%M%p').downcase }
  :default => lambda{|time| time.strftime('%Y-%m-%d %H:%M %Z') },
  :date => lambda{|time| time.strftime('%Y-%m-%d') }
)
