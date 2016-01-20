module HumanID
  module Extension
    module Pattern
      class << self
        def compile(handy_pattern)
          case handy_pattern
            # compile(['Article', :name])
            #   => [{string: 'Article'}, {method: :name}]
            when Array then handy_pattern

            # compile(:name)
            #   => { method: :name }
            when Symbol then { method: handy_pattern }

            # compile(':id_:name')
            #   => [ [{method: :id}, {string: '_'}, {method: :name}] ]
            #
            # compile('_:article_name:id_')
            #   => [ [{string: '_'}, {method: :article_name}, {method: :id}, {string: '_'}] ]
            #
            # compile('article_:id')
            #   => [ [{string: 'article_'}, {method: :id}] ]
            #
            # http://rubular.com/r/rHxp8IvOdB
            else [handy_pattern.scan(/(\w+)|(:\w+(?<!_))/).flatten.compact.map do |el|
              el.start_with?(':') ? { method: el[1..-1].to_sym } : { string: el }
            end]
          end
        end

        # class CreateArticles < ActiveRecord::Migration
        #   def change
        #     create_table :articles do |t|
        #       t.string :name
        #       t.text :content
        #     end
        #   end
        # end
        #
        # class Article < ActiveRecord::Base
        # end
        #
        # guess(Article)
        #   => :name
        #
        def guess(model_class)
          attrs = Traits.for(model_class).attributes
          attr  = attrs.find { |el| el.string? } || attrs.find { |el| el.primary_key? } || attrs.first
          attr.name
        end

        def result(compiled_pattern, model)
          compiled_pattern.map do |el|
            case el
              when Symbol then model.send(el)
              when Hash   then el.key?(:method) ? model.send(el[:method]) : el.fetch(:string)
              when Array  then result(el, model).join('')
              else el
            end
          end
        end
      end
    end
  end
end