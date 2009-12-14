Time::DATE_FORMATS.update(
  :default => lambda{|time| time.strftime('%b %d, %Y ') + time.strftime('%I:%M%p').downcase }
)
