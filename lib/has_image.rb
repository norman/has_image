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
      
      attr_accessible :uploaded_data
      
      after_create :store_images
      after_destroy :remove_images
      
      include ModelInstanceMethods
      extend  ModelClassMethods
    
    end

    def default_has_image_options
      {
        :resize_to => "800x800",
        :thumbnails => {},
        :max_size => 3.megabytes,
        :min_size => 4.kilobytes,
        :path_prefix => table_name,
        :base_path => File.join(RAILS_ROOT, 'public'),
        :convert_to => "jpg"
      }
    end

  end

  module ModelInstanceMethods
    
    def uploaded_data=(data)
      storage.data = data
    end
    
    def public_path(thumbnail = nil)
      storage.public_path_for(self, thumbnail)
    end
    
    def remove_images
      storage.remove_images(self.id)
    end

    def store_images
      storage.store_images(self.id)
    end
    
    def storage
      @storage ||= HasFile::Storage.new(self.has_image_options)
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