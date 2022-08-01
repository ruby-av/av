# frozen_string_literal: true

module Av
  class Engine < ::Rails::Engine
    initializer 'av.logger' do
      Av.logger = ::Rails.logger
    end
  end
end
