Time::DATE_FORMATS.update(
  :default => lambda{|time| time.strftime('%m/%d/%y ') + time.strftime('%I:%M%p').downcase }
)
