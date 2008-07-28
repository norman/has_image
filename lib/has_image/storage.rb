require 'active_support'
require 'stringio'
require 'fileutils'
require 'zlib'

module HasImage  
  
  # Filesystem storage for the HasImage gem. The methods that HasImage inserts
  # into ActiveRecord models only depend on the public methods in this class, so
  # it should be reasonably straightforward to implement a different storage
  # mechanism for Amazon AWS, Photobucket, DBFile, SFTP, or whatever you want.  
  class Storage
    
    attr_accessor :image_data, :options, :temp_file

    class << self
      
      # Stolen from {Jamis Buck}[http://www.37signals.com/svn/archives2/id_partitioning.php].
      def partitioned_path(id, *args)
        ("%08d" % id).scan(/..../) + args
      end

      # Generates a 4-6 character random file name to use for the image and its
      # thumbnails. This is done to avoid having files with unfortunate names.
      # On one of my sites users frequently upload images with Arabic names, and
      # they end up being hard to manipulate on the command line. This also
      # helps prevent a possibly undesirable sitation where the uploaded images
      # have offensive names.
      def random_file_name
        Zlib.crc32(Time.now.to_s + rand(10e10).to_s).to_s(36)
      end
          
    end

    # The constuctor should be invoked with the options set by has_image.
    def initialize(options) # :nodoc:
      @options = options
    end

    # The image data can be anything that inherits from IO. If you pass in an
    # instance of Tempfile, it will be used directly without being copied to
    # a new temp file.
    def image_data=(image_data)
      raise StorageError.new if image_data.blank?
      if image_data.is_a?(Tempfile)
        @temp_file = image_data
      else
        image_data.rewind
        @temp_file = Tempfile.new 'has_image_data_%s' % Storage.random_file_name
        @temp_file.write(image_data.read)        
      end
    end

    # Is uploaded file smaller than the allowed minimum?
    def image_too_small?
      @temp_file.open if @temp_file.closed?
      @temp_file.size < options[:min_size]
    end
    
    # Is uploaded file larger than the allowed maximum?
    def image_too_big?
      @temp_file.open if @temp_file.closed?
      @temp_file.size > options[:max_size]
    end
    
    # A tip of the hat to attachment_fu.
    alias uploaded_data= image_data=
    
    # A tip of the hat to attachment_fu.
    alias uploaded_data image_data
    
    # Invokes the processor to resize the image(s) and the installs them to
    # the appropriate directory.
    def install_images(id)
      random_name = Storage.random_file_name
      install_main_image(id, random_name)
      install_thumbnails(id, random_name) if !options[:thumbnails].empty?
      return random_name
    ensure  
      @temp_file.close! if !@temp_file.closed?
      @temp_file = nil
    end
    
    # Gets the "web" path for an image. For example:
    #
    #   /photos/0000/0001/3er0zs.jpg
    def public_path_for(object, thumbnail = nil)
      filesystem_path_for(object, thumbnail).gsub(options[:base_path], '')
    end
    
    # Deletes the images and directory that contains them.
    def remove_images(id)
      FileUtils.rm_r path_for(id)
    end

    # Is the uploaded file within the min and max allowed sizes?
    def valid?
      !(image_too_small? || image_too_big?)
    end

    protected

    # Gets the extension to append to the image. Transforms "jpeg" to "jpg."
    def extension
      options[:convert_to].to_s.downcase.gsub("jpeg", "jpg")
    end
    
    # Returns the options[:thumbnails] hash, coverted to an array and sorted
    # by thumbnail area, highest to lowest. For example:
    #
    #   options[:thumbnails] == {:a => "20x20", :b => "2x2", :c => "100x100"}
    #   sorted_thumbnails == [[:c, "100x100"], [:a, "20x20"], [:b, "2x2"]]
    #
    # This is done to speed up processing images with several thumbnails. Rather
    # than create the thumbnail starting from the highest quality version each
    # time, the next biggest thumbnail is used as the base image for its
    # immediately smaller variant. For example, given an image with 3 thumbnails
    # HasImage will use the 800x800 as the basis of the 500x500, and then the
    # 500x500 as the basis of the 200x200, etc. My benchmarks showed that this
    # will speed up processing by up to around 25% for a 4.5 meg JPEG with 5
    # thumbnails.
    def sorted_thumbnails
      options[:thumbnails].to_a.sort do |b,a| 
        Processor.area(a[1]) <=> Processor.area(b[1])
      end
    end

    private
    
    # File name, plus thumbnail suffix, plus extension. For example:
    #
    #   file_name_for("abc123", :thumb)
    #
    # gives you:
    #
    #   "abc123_thumb.jpg"
    #   
    #
    def file_name_for(*args)
      "%s.%s" % [args.compact.join("_"), extension]
    end

    # Gets the full local filesystem path for an image. For example:
    #
    #   /var/sites/example.com/production/public/photos/0000/0001/3er0zs.jpg
    def filesystem_path_for(object, thumbnail = nil)
      File.join(path_for(object.id), file_name_for(object.has_image_file, thumbnail))
    end
    
    # Write the main image to the install directory - probably somewhere under
    # RAILS_ROOT/public.
    def install_main_image(id, name)
      FileUtils.mkdir_p path_for(id)
      main = processor.resize(@temp_file, @options[:resize_to])
      main.write(File.join(path_for(id), file_name_for(name)))
      main.tempfile.close!
    end
    
    # Write the thumbnails to the install directory - probably somewhere under
    # RAILS_ROOT/public.
    def install_thumbnails(id, name)
      FileUtils.mkdir_p path_for(id)
      path = File.join(path_for(id), file_name_for(name))
      sorted_thumbnails.each do |t|
        thumb = processor.resize(path, t[1])
        path = File.join(path_for(id), file_name_for(name, t[0]))
        thumb.write(path)
        thumb.tempfile.close!
      end
    end

    # Get the full path for the id. For example:
    #
    #  /var/sites/example.org/production/public/photos/0000/0001
    def path_for(id)
      File.join(options[:base_path], options[:path_prefix], Storage.partitioned_path(id))
    end
    
    # Instantiates the processor using the options set in my contructor (if
    # not already instantiated), stores it in an instance variable, and
    # returns it.
    def processor
      @processor ||= Processor.new(options)
    end
    
  end
  
end