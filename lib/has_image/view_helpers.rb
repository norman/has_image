module HasImage
  
  module ViewHelpers
  
    def image_tag_for(object, options = {})
      thumb = options.delete(:thumb)
      if thumb && !options[:size]
        size = object.class.thumbnails[thumb.to_sym]
        options[:size] = size if size =~ /\A[\d]*x[\d]*\Z/
      end
  	  image_tag(object.public_path(thumb), options)
    end
  
  end

end