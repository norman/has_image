## 0.4.0 (2010-09-29)

We have picked up maintainence of has\_image after a few years of neglect. This
is a transitional release which adds Rails 3 compatibility and a few small bug
fixes, as well as the following:

* Allow passing `nil` to avoid resizing.

## Older changes

### 2009-03-11

* Fix a critical problem with image updates breaking when used together with
  Rails' partial updates feature (now "on" by default). Thanks to Juan
  Schwindt <juan@schwindt.org> for the report.
* Replaced a raw SQL call with update_all.

### 2008-10-22

* Added option to not delete images on destroy
* Made thumbnail name separator configurable
* Added height/width methods to storage
* Allowed regenerating only one thumbnail size
* Made has_image column configurable
* Added some compatibility with attachment_fu
* General refactorings and overall code improvement

### 2008-10-22

* Documentation improvements and minor code cleanups.

### 2008-10-09

* Fixed display of images with special symbols in the name,
  like '2777-nipple-+-apple-napple.jpg'. + is reserved by HTTP.
  Now escaping filenames before giving them back in #public_path()

### 2008-09-10

* Fixed images not being converted to target format.

### 2008-08-29

* Fixed bad call to has_image_file

### 2008-08-28

* Added ability to regenerate a model's thumbnails.
* Changed a few methods in storage to accept the model rather than the id.
  This makes storage more hackable as regards generating paths and file names.
* Added "has_image_id" method to model instance methods to facilitate
  grouping the images under a directory structure based on a related model's
  ids.
* Made the generated file name simply by the image object's id - this
  is better adherance to the principle of least surprise.

### 2008-08-25

* Fixed bad call to resize_to in view helper.

### 2008-08-19

* Made storage work more correctly with tempfiles.

### 2008-08-18

* Fixed ability to set the path for storing image files.

### 2008-08-01

* Improved partitioned path handling to avoid collisions when the id is
  very high, which can happen if you use db:fixtures:load.

### 2008-08-01

* Fixed a bug where overwriting a previous image triggered callbacks more
  than once, causing errors.

### 2008-07-29

* Downcased generated file names to avoid potential issues on
  case-insensitive filesystems.
* Added "absolute path" method to model instances.
* Made image deletion nullify the "has_image_file" field.
* Added "has_image?" method to model instances.
* Fixed ENONENT error with record update when there are no images yet.
* Reverted thumbnail sorting feature - it's fast but makes terrible quality
  thumbnails. It's just not worth it.

### 2008-07-28

* Added sorted thumbnail processing. This improves thumbnail generation
  speed by about 25% for 4.5 meg jpegs with 5 thumbnails.
* Fixed broken resize for non-fixed-width thumbnails.
* Added check for bad geometry strings.
* Added dependencies and Rubyforge project to gemspec, updated docs.

### 2008-07-25

* First public release.