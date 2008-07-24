require 'has_image/processor'
require 'has_image/storage'

# = HasImage
#
# HasImage allows Ruby on Rails applications to have attached images. It is very
# small and lightweight: it only requires one column (by default, "file_name")
# in your model to store the uploaded image's file name.
# 
# HasImage is, by design, very simplistic: It only supports using a filesystem
# for storage, and only supports
# MiniMagick[http://github.com/probablycorey/mini_magick] as an image processor.
# However, its code is very small, clean and hackable, so adding support for
# other backends or processors should be fairly easy.
# 
# HasImage works best for sites that want to show image galleries with
# fixed-size thumbnails. It uses ImageMagick's
# crop[http://www.imagemagick.org/script/command-line-options.php#crop] and
# {center
# gravity}[http://www.imagemagick.org/script/command-line-options.php#gravity]
# functions to produce thumbnails that generally look acceptable, unless the
# image is a panorama, or the subject matter is close to one of the margins,
# etc. For most sites where people upload pictures of themselves or their pets
# the generated thumbnails will look good almost all the time.
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
  class FileTooBigError < StorageError ; end  
  class FileTooSmallError < StorageError ; end  
  
  class << self
    def included(base) # :nodoc:
      base.extend(ClassMethods)
    end

    # Enables has_image functionality. You probably don't need to ever invoke
    # this.
    def enable # :nodoc:
      return if ActiveRecord::Base.respond_to? :has_image
      ActiveRecord::Base.send(:include, HasImage)    
    end

    # If you're invoking this method, you need to pass in the class for which
    # you want to get default options; this is used to determine the path where
    # the images will be stored in the file system. Take a look at
    # HasImage::ClassMethods#has_image to see examples of how to set the options
    # in your model.
    #
    # This method is called by your model when you call has_image. It's
    # placed here rather than in the model's class methods to make it easier
    # to access for testing. Unless you're working on the code, it's unlikely
    # you'll ever need to invoke this method.
    #
    # * :resize_to => "200x200",
    # * :thumbnails => {},
    # * :max_size => 12.megabytes,
    # * :min_size => 4.kilobytes,
    # * :path_prefix => klass.to_s.tableize,
    # * :base_path => File.join(RAILS_ROOT, 'public'),
    # * :convert_to => "JPEG",
    # * :output_quality => "85",
    # * :invalid_image_message => "Can't process the image.",
    # * :image_too_small_message => "The image is too small.",
    # * :image_too_big_message => "The image is too big.",
    # * :file_name_column => :file_name
    def default_options_for(klass)
      {
        :resize_to => "200x200",
        :thumbnails => {},
        :max_size => 12.megabytes,
        :min_size => 4.kilobytes,
        :path_prefix => klass.to_s.tableize,
        :base_path => File.join(RAILS_ROOT, 'public'),
        :convert_to => "JPEG",
        :output_quality => "85",
        :invalid_image_message => "Can't process the image.",
        :image_too_small_message => "The image is too small.",
        :image_too_big_message => "The image is too big.",
        :file_name_column => :file_name
      }
    end
    
  end

  module ClassMethods
    # To use HasImage with a Rails model, you must make sure you have a column
    # for storing the attached file's name. This defaults to "file_name,"
    # but can be overridden by setting the option described below. This is the
    # only column you need to add to your model. You might want to take a look
    # at the default options specified in HasImage#default_options_for.
    #
    # Options:
    # *  <tt>:resize_to</tt> - Dimensions to resize to. This should be an ImageMagick {geometry string}[http://www.imagemagick.org/script/command-line-options.php#resize]. Fixed sizes are recommended.
    # *  <tt>:thumbnails</tt> - A hash of thumbnail names and dimensions. The dimensions should be ImageMagick {geometry strings}[http://www.imagemagick.org/script/command-line-options.php#resize]. Fixed sized are recommended.
    # *  <tt>:min_size</tt> - Minimum file size allowed. It's recommended that you set this size in kilobytes.
    # *  <tt>:max_size</tt> - Maximum file size allowed. It's recommended that you set this size in megabytes.
    # *  <tt>:base_path</tt> - Where to install the images. You should probably leave this alone, except for tests.
    # *  <tt>:path_prefix</tt> - Where to install the images, relative to basepath. You should probably leave this alone.
    # *  <tt>:convert_to</tt> - An ImageMagick format to convert images to. Recommended formats: JPEG, PNG, GIF.
    # *  <tt>:output_quality</tt> - Image output quality passed to ImageMagick.
    # *  <tt>:invalid_image_message</tt> - The message that will be shown when the image data can't be processed.
    # *  <tt>:image_too_small_message</tt> - The message that will be shown when the image file is too small. You should ideally set this to something that tells the user what the minimum is.
    # *  <tt>:image_too_big_message</tt> - The message that will be shown when the image file is too big. You should ideally set this to something that tells the user what the maximum is.
    # *  <tt>:file_name_column</tt> - The column that the file name will be saved in.
    #
    # Examples:
    #   has_image # uses all default options
    #   has_image :resize_to "800x800", :thumbnails => {:square => "150x150"}
    #   has_image :resize_to "100x150", :max_size => 500.kilobytes, :file_name_column => "avatar"
    #   has_image :invalid_image_message => "No se puede procesar la imagen."
    def has_image(options = {})
      options.assert_valid_keys(:resize_to, :thumbnails, :max_size, :min_size,
        :path_prefix, :base_path, :convert_to, :output_quality,
        :invalid_image_message, :file_name_column)
      options = HasImage.default_options_for(self).merge(options)
      class_inheritable_accessor :has_image_options
      write_inheritable_attribute(:has_image_options, options)
      
      attr_accessible :image_data
      
      after_create :install_images
      after_destroy :remove_images
      
      validate_on_create :image_data_valid?
      
      include ModelInstanceMethods
      extend  ModelClassMethods
    
    end
    
  end

  module ModelInstanceMethods
    
    def image_data=(image_data)
      storage.image_data = image_data
    end
    
    def image_data_valid?
      return if !storage.temp_file
      if storage.image_too_big?
        errors.add_to_base(self.class.has_image_options[:image_too_big_message])
      elsif storage.image_too_small?
        errors.add_to_base(self.class.has_image_options[:image_too_small_message])
      elsif !HasImage::Processor.valid?(storage.temp_file)
        errors.add_to_base(self.class.has_image_options[:invalid_image_message])
      end
    end
    
    def public_path(thumbnail = nil)
      storage.public_path_for(self, thumbnail)
    end
    
    def remove_images
      return if send(has_image_options[:file_name_column]).blank?
      storage.remove_images(self.id)
    rescue Errno::ENOENT
      logger.warn("Could not delete files for #{self.class.to_s} #{to_param}") 
    end

    def install_images
      return if !storage.temp_file
      update_attribute(has_image_options[:file_name_column], storage.install_images(self.id))
    end
    
    def storage
      @storage ||= HasImage::Storage.new(has_image_options)
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