# TODO make format customizable through an external configuration file.
Time::DATE_FORMATS.update(
  # :default => lambda{|time| time.strftime('%m/%d/%y ') + time.strftime('%I:%M%p').downcase }
  :default => lambda{|time| time.in_time_zone.strftime(SETTINGS.datetime_format) },
  :date => lambda{|time| time.in_time_zone.strftime(SETTINGS.date_format) },
  :time => lambda{|time| time.in_time_zone.strftime('%I:%M%p') }
)
Date::DATE_FORMATS.update(
  :default => SETTINGS.date_format
)

