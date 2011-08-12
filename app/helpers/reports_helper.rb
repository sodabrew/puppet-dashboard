module ReportsHelper
  def popup_md5s( string, label = nil )
    if SETTINGS.use_file_bucket_diffs
      string.sub(/content changed '(\{md5\}[a-fA-F0-9]{32})'/) do |match|
        hash = $1
        label ||= hash
        filebucket_url = url_for(:controller => :files, :action => :show, :file => hash.sub('{md5}',''))
        function_link = link_to_function(label, "display_file_popup('#{filebucket_url}')", :class => 'popup-md5')

        "content changed '#{function_link}'"
      end
    else
      string
    end
  end
end
