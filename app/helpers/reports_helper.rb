module ReportsHelper
  def popup_md5s( string, label = nil )
    if SETTINGS.use_file_bucket_diffs
      string.gsub(/\{md5\}[a-fA-F0-9]{32}/) do |match|
        link_to_function label || match, "display_file_popup('#{url_for :controller => :files, :action => :show, :file => match.sub('{md5}','')}')", :class => 'popup-md5'
      end
    else
      string
    end
  end
end
