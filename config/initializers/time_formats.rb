# TODO make format customizable through an external configuration file.
Time::DATE_FORMATS.update(
  # :default => lambda{|time| time.strftime('%m/%d/%y ') + time.strftime('%I:%M%p').downcase }
  :default => lambda{|time| time.in_time_zone.strftime(SETTINGS.date_format || '%Y-%m-%d %H:%M %Z') },
  :date => lambda{|time| time.in_time_zone.strftime('%Y-%m-%d') },
  :time => lambda{|time| time.in_time_zone.strftime('%I:%M%p') }
)

