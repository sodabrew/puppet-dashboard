module ReportsHelper
  def popup_md5s( string, options = {} )
    if SETTINGS.use_file_bucket_diffs
      string.gsub(/\{md5\}[a-fA-F0-9]{32}/) do |match|
        if options[:exclude_md5s] and options[:exclude_md5s].include? match
          match
        else
          popup_url = url_for :controller => :files, :action => :show, :file => match.sub('{md5}','')
          link_to options[:label] || match, '#', :onclick => "display_file_popup('#{popup_url}'); return false;", :class => 'popup-md5'
        end
      end
    else
      string
    end
  end
end
