module FriendlyId
  class Railtie < Rails::Railtie
    initializer "has_image.configure_rails_initialization" do |app|
      HasImage.enable
    end
  end
end
