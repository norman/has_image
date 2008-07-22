require 'has_image/storage'
require 'has_image/processor'

module HasImage
  
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
  end

  def self.enable
    return if ActiveRecord::Base.respond_to? :has_image
    ActiveRecord::Base.send(:include, HasImage)    
  end

  module ClassMethods

    def has_image(options = {})
      options.assert_valid_keys(:resize_to, :thumbnails, :max_size, :min_size)
      options = default_has_image_options.merge(options)
      write_inheritable_attribute(:has_image_options, options)
      class_inheritable_reader :has_image_options
      
      attr_accessible :image_data
      
      after_create :install_images
      after_destroy :remove_images
      
      validate_on_create :image_data_valid?
      
      include ModelInstanceMethods
      extend  ModelClassMethods
    
    end

    def default_has_image_options
      {
        :resize_to => "640x480",
        :thumbnails => {},
        :max_size => 12.megabytes,
        :min_size => 4.kilobytes,
        :path_prefix => table_name,
        :base_path => File.join(RAILS_ROOT, 'public'),
        :convert_to => "JPEG",
        :output_quality => "85",
        :invalid_image_message => "Can't process the uploaded image.",
        :file_name_column => :file_name
      }
    end

  end

  module ModelInstanceMethods
    
    def image_data=(image_data)
      storage.image_data = image_data
    end
    
    def image_data_valid?
      if !HasImage::Processor.valid?(storage.temp_file)
        errors.add_to_base(self.class.has_image_options[:invalid_image_message])
      end
    end
    
    def public_path(thumbnail = nil)
      storage.public_path_for(self, thumbnail)
    end
    
    def remove_images
      storage.remove_images(self.id)
    end

    def install_images
      update_attribute(has_image_options[:file_name_column], storage.install_images(self.id))
    end
    
    def storage
      @storage ||= HasImage::Storage.new(self.has_image_options)
    end
    
  end

  module ModelClassMethods

    def thumbnails
      has_image_options[:thumbnails]
    end

  end

end

if defined?(Rails) and defined?(ActiveRecord) and defined?(ActionController)
  HasImage.enable
end