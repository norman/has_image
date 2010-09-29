# has\_image - An Image attachment library for Active Record

The has\_image library extends Active Record to allow Rails applications to have
attached images. It is very small and lightweight: it only requires one column
in your model to store the uploaded image's file name.

It was originally created as a smaller, simpler, lighter alternative to
[attachment_fu](http://github.com/technoweenie/attachment_fu) for applications
that need to handle uploaded images.

It only supports using a filesystem for storage, and only supports
[MiniMagick](http://github.com/probablycorey/mini_magick) as an image processor.
However, its code is very small, clean and hackable, so adding support for other
backends or processors should be fairly easy.

Some typical use cases are: websites that want to create photo galleries with
fixed-dimension thumbnails, or that want to store user profile pictures without
creating a separate model for the images.

It creates only one database record per image, and uses ImageMagick's
[crop](http://www.imagemagick.org/script/command-line-options.php#crop) and
[center
gravity](http://www.imagemagick.org/script/command-line-options.php#gravity)
functions to produce thumbnails that generally look acceptable, unless the image
is a panorama, or the subject matter is close to one of the margins, etc. For
most sites where people upload pictures of themselves the generated thumbnails
will look good almost all the time.

## Examples

Point-and-drool use case. It's probably not what you want, but it may be useful
for bootstrapping.

    class Member < ActiveRecord::Base
      has_image
    end

Single image, no thumbnails, with some size limits:

    class Picture < ActiveRecord::Base
      has_image :resize_to => "200x200",
        :max_size => 3.megabytes,
        :min_size => 4.kilobytes
    end

Image with some thumbnails:

    class Photo < ActiveRecord::Base
      has_image :resize_to => "640x480",
        :thumbnails => {
          :square => "200x200",
          :medium => "320x240"
        },
        :max_size => 3.megabytes,
        :min_size => 4.kilobytes
    end

It also provides a view helper to make displaying the images extremely simple:

    <%= image_tag_for(@photo) # show the full-sized image %>
    <%= image_tag_for(@photo, :thumb => :square) # show the square thumbnail %>

The image_tag_for helper calls Rails' image_tag, so you can pass in all the
regular options to set the alt property, CSS class, etc:

    <%= image_tag_for(@photo, :alt => "my cool picture", :class => "photo") %>

Setting up forms for has\_image is simple, too:

    <% form_for(@photo, :html => {:multipart => true}) do |f| %>
      <p>
        <%= f.label :image_data %>
        <%= f.file_field :image_data %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>

## Compatibility

Has\_image is compatible with Rails 2.1.x - 3.0.x.

## Getting it

Install has_image via RubyGems:

  gem install has_image

and add it to your Gemfile (Rails 3.0.x) or environment.rb (Rails 2.x).

Then, add a column named `has_image_file` to your model.

## Source code

[http://github.com/norman/has_image](http://github.com/norman/has_image)

## FAQ

### How do I validate the mime type of my uploaded images?

You don't. Rather than examine the mime type, has\_image runs the "identify"
command on the file to determine if it is processable by ImageMagick, and if it
is, converts it to the format you specify, which defaults to JPEG.

This is better than checking for mime types, because your users may upload
exotic image types that you didn't even realize would work, such as Truevision
Targa images, or Seattle Film Works files.

If you wish to give users a list of file types they can upload, a good start
would be jpeg, png, bmp, and maybe gif and ttf if your installation of
ImageMagick understands them. You can find out what image types your ImageMagick
understands by running:

    identify -list format

Ideally, if your users just upload files that "look like" images on their
computers, it has\_image should "just work."

## Hacking it

Don't like the way it makes images? Want to pipe the images through some [crazy
fast seam carving library written in
OCaml](http://eigenclass.org/hiki/seam-carving-in-ocaml), or watermark them with
your corporate logo? Happiness is just a
[monkey-patch](http://en.wikipedia.org/wiki/Monkey_patch) away:

    module HasImage
      class Processor
        def resize_image(size)
          # your new-and-improved thumbnailer code goes here.
        end
      end
    end

Has\_image follows a philosophy of [skinny model, fat
plugin](http://weblog.jamisbuck.org/2006/10/18/skinny-controller-fat-model.)
This means that it tries to pollute your ActiveRecord model with as little
functionality as possible, so that in a sense, the model is acts like a
"controller" and the plugin like a "model" as regards the image handling
functionality. This makes it easier to test, hack, and reuse, because the
storage and processing functionality is largely independent of your model, and
of Rails.

## Bugs

Please report them on the Github issue tracker.

Copyright (c) 2008-2010 Norman Clarke and Adrian Mugnolo. Released under the MIT
License.

## Acknowledgements

We'd like to thank the following contributors for their help with has\_image:

* [Juan Schwindt](http://github.com/jschwindt)
* [Gerrit Keiser](http://github.com/gerrit)
* the folks from [Tricycle Developments](http://github.com/tricycle)
* [Dima Sabanin](http://github.com/railsmonk)
