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
      
      after_save :store_image
      after_destroy :remove_image
      
      include ModelInstanceMethods
      extend  ModelClassMethods
    
    end

    def default_has_image_options
      {
        :resize_to => "800x800",
        :thumbnails => {
          :square => "75x75",
          :thumb  => "100x75",
          :small  => "240x180",
          :medium => "500x375",
        },
        :max_size => 3.megabytes,
        :min_size => 4.kilobytes
      }
    end

  end

  module ModelInstanceMethods
    
    def uploaded_data=(data)
      @storage = HasFile::Storage.new
      @storage.data = data
    end
    
    def store_image
      @processor = HasFile::Processor.new
      @processor.storage = @storage
    end
    
    def remove_image
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