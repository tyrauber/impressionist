require "impressionist"
require "rails"

module Impressionist
  class Engine < Rails::Engine
    initializer 'impressionist.model' do |app|
      require "#{root}/app/models/impressionist/impressionable.rb"
      if Impressionist.orm == :active_record && defined? ActiveRecord
        require "impressionist/models/active_record/impression.rb"
        require "impressionist/models/active_record/impressionist/impressionable.rb"
        ActiveRecord::Base.send(:include, Impressionist::Impressionable)
      elsif Impressionist.orm == :mongo_mapper
        require "impressionist/models/mongo_mapper/impression.rb"
        require "impressionist/models/mongo_mapper/impressionist/impressionable.rb"
        MongoMapper::Document.plugin Impressionist::Impressionable
      elsif Impressionist.orm == :mongoid
        require 'impressionist/models/mongoid/impression.rb'
        require 'impressionist/models/mongoid/impressionist/impressionable.rb'
        Mongoid::Document.send(:include, Impressionist::Impressionable)
      end

      Impression.class_eval do
        if !!(Impressionist.hstore)
          serialize :params, ActiveRecord::Coders::Hstore
          serialize :session, ActiveRecord::Coders::Hstore
          attr_accessible :params, :session
          scope :with_param, lambda {|key, value=nil|
            where("params"+(value.nil? ? " ? '"+key+"'" : " @> '"+key+" => "+value+"'"))
          }
          scope :with_session, lambda {|key, value=nil|
            where("session"+(value.nil? ? " ? '"+key+"'" : " @> '"+key+" => "+value+"'"))
          }
        end
      end
    end

    initializer 'impressionist.controller' do
      if Impressionist.orm == :mongoid
          require 'impressionist/controllers/mongoid/impressionist_controller.rb'
      end
      ActiveSupport.on_load(:action_controller) do
        include ImpressionistController::InstanceMethods
        extend ImpressionistController::ClassMethods
      end
    end
  end
end
