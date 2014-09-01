require_relative 'initialize'

module Sass
  module Tree
    class RootNode
      alias :old_render :render

      def render
        old_render.split('/*').map { |x|
          next x unless x.match(/^ line [0-9]+, /)
          a, b = x.split("\n", 2)
          m = a.match(/\/app\/assets\/stylesheets\/([^. ]+)\./)
          next "#{a}\n#{b}" unless m
          selector = class_replaced_selector(b.split("\n")[0].strip[0...-1].strip, class_prefix(m[1]))
          "#{a}\n#{selector} {\n#{b.split("\n", 2)[1]}"
        }.join('/*')
      end

      private

      def class_replaced_selector(selector, class_prefix)
        doc = CSSPool.CSS("#{selector} {}")
        replace_class(doc, class_prefix)
        doc_to_selector(doc)
      end

      def class_prefix(name)
        names = name.split('/')
        names = names[1..(names.index { |x| x.start_with?('!') } || -1)]
        names.join('__')
      end

      def replace_class(doc, class_prefix)
        doc.rule_sets[0].selectors.map do |selector|
          selector.simple_selectors.each do |simple_selector|
            simple_selector.additional_selectors.each do |additional_selector|
              case additional_selector
              when CSSPool::Selectors::Class
                additional_selector.name = extended_selector(class_prefix, additional_selector.name)
              when CSSPool::Selectors::PseudoClass
                next unless additional_selector.extra
                extra = class_replaced_selector(additional_selector.extra, class_prefix) rescue nil
                additional_selector.extra = extra if extra
              end
            end
          end
        end
      end

      def doc_to_selector(doc)
        doc.to_css.split("\n")[0][0...-1].strip.gsub(/\\[0-9a-f]{6}/) do |c|
          [c[1..-1].tr('0', '').to_i(16)].pack('U')
        end
      end

      def extended_selector(class_prefix, klass)
        if klass == 'root'
          class_prefix
        elsif klass.start_with?('_')
          klass[1..-1]
        else
          "#{class_prefix}___#{klass}"
        end
      end
    end
  end
end

require_relative 'xass/railtie' if defined?(Rails)
