require 'has_image/processor'
require 'has_image/storage'

# = HasImage
#
# HasImage allows Ruby on Rails applications to have attached images. It is very
# small and lightweight: it only requires only one column (by default,
# "file_name") in your model to store the uploaded image's file name.
# 
# HasImage is, by design, very simplistic: It only supports using a filesystem
# for storage, and only supports
# MiniMagick[http://github.com/probablycorey/mini_magick] as an image processor.
# However, its code is very small, clean and hackable, so adding support for
# other backends or processors should be possible.
# 
# HasImage works best for sites that want to show image galleries with
# fixed-size thumbnails. It uses ImageMagick's crop and center gravity functions
# to produce thumbnails that generally look acceptable, unless the image is a
# panorama, or the subject matter is close to one of the margins, etc. For most
# sites where people upload pictures of themselves or their pets the generated
# thumbnails will look good almost all the time.
# 
# It's pretty easy to change the image processing / resizing code; you can just
# override HasImage::Processor#resize_image to do what you wish:
# 
#   module HasImage::
#     class Processor
#       def resize_image(size)
#         @image.combine_options do |commands|
#           commands.my_custom_resizing_goes_here
#         end
#       end
#     end
#   end
# 	
# Compared to attachment_fu, HasImage has advantages and disadvantages.
# 
# = Advantages:
# 
# * Simpler, smaller, more easily hackable codebase - and specialized for
#   images only.
# * Installable via Ruby Gems. This makes version dependencies easy when using
#   Rails 2.1.
# * Creates only one database record per image.
# * Has built-in facilities for making distortion-free, fixed-size thumbnails.
# * Doesn't regenerate the thumbnails every time you save your model. This means
#   you can easily use it, for example, inside a Member model to store member
#   avatars.
# 
# = Disadvantages:
# 
# * Doesn't save image dimensions. However, if you're using fixed-sized images,
#   this is not a problem because you can just read the size from MyModel.thumbnails[:my_size]
# * No support for AWS or DBFile storage, only filesystem.
# * Only supports MiniMagick as an image processor, no RMagick, GD, CoreImage,
#   etc.
# * No support for anything other than image attachments.
# * Not as popular as attachment_fu, which means fewer bug reports, and
#   probably more bugs. Use at your own risk!
module HasImage

  class ProcessorError < StandardError ; end
  class StorageError < StandardError ; end  
  
  class << self
    def included(base) # :nodoc:
      base.extend(ClassMethods)
    end

    # Enables has_image functionality. You probably don't need to ever invoke
    # this.
    def enable
      return if ActiveRecord::Base.respond_to? :has_image
      ActiveRecord::Base.send(:include, HasImage)    
    end
  end

  module ClassMethods
    
    # Options:
    # *  <tt>:resize_to</tt> - Dimensions to resize to. This should be an ImageMagick geometry string. Fixed sizes are recommended.
    # *  <tt>:thumbnails</tt> - A hash of thumbnail names and sizes. The sizes should be ImageMagick geometry strings. Fixed sized are recommended.
    # *  <tt>:min_size</tt> - Minimum size allowed.
    # *  <tt>:max_size</tt> - Maximum size allowed.
    # *  <tt>:base_path</tt> - Where to install the images. You should probably leave this alone, except for tests.
    # *  <tt>:path_prefix</tt> - Where to install the images, relative to basepath. You should probably leave this alone.
    # *  <tt>:convert_to</tt> - An ImageMagick format to convert images to. Recommended formats: JPEG, PNG, GIF.
    # *  <tt>:output_quality</tt> - Image output quality passed to ImageMagick.
    # *  <tt>:invalid_image_message</tt> - The message that will be shown on validation errors.
    # *  <tt>:file_name_column</tt> - The column that the file name will be saved in.
    #
    # Examples:
    #   has_image
    #   has_image :resize_to "800x800", :thumbnails => {:square => "150x150"}
    #   has_image :resize_to "100x150", :max_size => 500.kilobytes, :file_name_column => "avatar"
    def has_image(options = {})
      options.assert_valid_keys(:resize_to, :thumbnails, :max_size, :min_size,
        :path_prefix, :base_path, :convert_to, :output_quality,
        :invalid_image_message, :file_name_column)
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
    
    # * <tt>:resize_to</tt> - 200x200
    # * <tt>:thumbnails</tt> - {}
    # * <tt>:max_size</tt> - 12.megabytes
    # * <tt>:min_size</tt> - 4.kilobytes
    # * <tt>:path_prefix</tt> - #{table_name}
    # * <tt>:base_path</tt> - #{RAILS_ROOT}/public
    # * <tt>:convert_to</tt> - JPEG
    # * <tt>:output_quality</tt> - 85
    # * <tt>:invalid_image_message</tt> - "Can't process the uploaded image."
    # * <tt>:file_name_column</tt> - :file_name
    def default_has_image_options
      {
        :resize_to => "200x200",
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