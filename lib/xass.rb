require_relative 'initialize'

module Sass::Tree
  class Visitors::Perform
    def visit_mixin(node)
      include_loop = true
      handle_include_loop!(node) if @stack.any? {|e| e[:name] == node.name}
      include_loop = false

      @stack.push(:filename => node.filename, :line => node.line, :name => node.name)
      raise Sass::SyntaxError.new("Undefined mixin '#{node.name}'.") unless mixin = @environment.mixin(node.name)

      if node.children.any? && !mixin.has_content
        raise Sass::SyntaxError.new(%Q{Mixin "#{node.name}" does not accept a content block.})
      end

      args = node.args.map {|a| a.perform(@environment)}
      keywords = Sass::Util.map_hash(node.keywords) {|k, v| [k, v.perform(@environment)]}
      splat = node.splat.perform(@environment) if node.splat

      self.class.perform_arguments(mixin, args, keywords, splat) do |env|
        env.caller = Sass::Environment.new(@environment)
        env.content = node.children if node.has_children

        trace_node = Sass::Tree::TraceNode.from_node(node.name, node)
        with_environment(env) {
          trace_node.children = mixin.tree.map {|c|
            d = c.deep_copy
            xass_recursive_set_filename(d, node.filename)
            visit(d)
          }.flatten
        }
        trace_node
      end
    rescue Sass::SyntaxError => e
      unless include_loop
        e.modify_backtrace(:mixin => node.name, :line => node.line)
        e.add_backtrace(:line => node.line)
      end
      raise e
    ensure
      @stack.pop unless include_loop
    end

    private

    def xass_recursive_set_filename(node, filename)
      node.filename = filename
      node.children.each { |x| xass_recursive_set_filename(x, filename) }
    end
  end

  class RootNode
    alias :old_render :render

    def render
      old_render.split('/*').map { |x|
        next x unless x.match(/^ line [0-9]+, /)
        a, b = x.split("\n", 2)
        m = a.match(/#{Rails.root}\/app\/assets\/stylesheets\/([^. ]+)\./)
        d = "#{a}\n#{b}"
        next d unless m
        p = class_prefix(m[1])
        next d unless p
        selector = class_replaced_selector(b.split("\n")[0].strip[0...-1].strip, p)
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
      p = names.join('__')
      p.empty? ? nil : p
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

require_relative 'xass/railtie' if defined?(Rails)
