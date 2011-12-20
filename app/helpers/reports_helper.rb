module ReportsHelper
  def popup_md5s( string, options = {} )
    if SETTINGS.use_file_bucket_diffs
      hashes = string.scan(/\{md5\}[a-fA-F0-9]{32}/)
      
      # if we have a message containing md5s, evaluate for filebucket link
      if hashes.length != 0
        string.gsub(/changed/, link_to_function( "\\&", "display_file_popup('#{url_for :controller => :files, :action => :diff, :file1 => hashes[0].sub('{md5}',''), :file2 => hashes[1].sub('{md5}','')}')", :class => 'popup-md5')).gsub(/\{md5\}[a-fA-F0-9]{32}/) do |match|
          if options[:exclude_md5s] and options[:exclude_md5s].include? match
            match
          else
            link_to_function options[:label] || match, "display_file_popup('#{url_for :controller => :files, :action => :show, :file => match.sub('{md5}','')}')", :class => 'popup-md5'
          end
        end
      else
        string
      end
    else
      string
    end
  end
end
