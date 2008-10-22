def imagemagick_installed?
  `which identify`
   $?.success?
end

require 'has_image'

abort 'ImageMagick not found in PATH. Is it installed?' unless imagemagick_installed?
