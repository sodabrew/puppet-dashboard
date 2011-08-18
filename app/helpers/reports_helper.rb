module ReportsHelper
  def popup_md5s( string, options = {} )
    if SETTINGS.use_file_bucket_diffs
      string.gsub(/\{md5\}[a-fA-F0-9]{32}/) do |match|
        if options[:exclude_md5s] and options[:exclude_md5s].include? match
          match
        else
          link_to_function options[:label] || match, "display_file_popup('#{url_for :controller => :files, :action => :show, :file => match.sub('{md5}','')}')", :class => 'popup-md5'
        end
      end
    else
      string
    end
  end
end
