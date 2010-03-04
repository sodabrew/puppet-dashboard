Time::DATE_FORMATS.update(

  :default => lambda{|time| time.strftime('%d/%m/%y ') + time.strftime('%I:%M%p').downcase }
)
