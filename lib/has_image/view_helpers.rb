module HasImage
  
  module ViewHelpers
  
    def image_tag_for(object, options = {})
      # options = {:size => :square}.merge(options)
      # options[:class] ||= "#{object.class.to_s.downcase}"
  	  image_tag(object.public_path)
    end
  
  end

end