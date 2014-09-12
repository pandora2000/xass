module Xass
  module ViewHelpers
    def namespace(*names, reset: false, &block)
      n = reset ? names : namespace_stack.last + names
      namespace_stack.push(n)
      res = capture(&block)
      namespace_stack.pop
      node = Nokogiri::HTML(res)
      process_namespace_classes(node, n)
      node.to_html.html_safe
    end

    def namespace!(*names, &block)
      namespace(*names, reset: true, &block)
    end

    def namespace_with_root(*names, tag: :div, attrs: {}, reset: false, &block)
      nss = reset ? [] : namespace_stack.last
      content_tag(tag, block ? namespace(*names, reset: reset, &block) : '', attrs_with_additional_class(attrs, ns_root!(*(nss + names))))
    end

    def namespace_with_root!(*names, tag: :div, attrs: {}, &block)
      namespace_with_root(*names, tag: tag, attrs: attrs, reset: true, &(block || Proc.new {}))
    end

    def ns_wrap(name = :wrap, _tag = nil, _attrs = nil, tag: :div, attrs: {}, &block)
      _tag ||= tag
      _attrs ||= attrs
      content_tag(_tag, block ? capture(&block) : '', attrs_with_additional_name(_attrs, name))
    end

    def ns_content(name = :content, _tag = nil, _attrs = nil, tag: :div, attrs: {}, &block)
      _tag ||= tag
      _attrs ||= attrs
      ns_wrap(name, tag: _tag, attrs: _attrs, &block)
    end

    def ns_root(*names)
      ns_root!(*(namespace_stack.last + names))
    end

    def ns_root!(*names)
      names.map(&:to_s).join('__')
    end

    def ns(*names)
      ns!(*(namespace_stack.last + names))
    end

    def ns!(*names)
      "#{ns_root!(*names[0...-1])}___#{names[-1]}"
    end

    def ns_link_to(name, _name = nil, options = nil, html_options = nil, &block)
      if block
        options ||= {}
        link_to(_name, attrs_with_additional_name(options, name), &block)
      else
        html_options ||= {}
        link_to(_name, options, attrs_with_additional_name(html_options, name), &block)
      end
    end

    alias :dns :namespace
    alias :dns! :namespace!
    alias :dnsr :namespace_with_root
    alias :dnsr! :namespace_with_root!
    alias :nsr :ns_root
    alias :nsr! :ns_root!
    alias :nsc :ns_content

    private

    def namespace_stack
      @namespace_stack ||= [[]]
    end

    def attrs_with_additional_class(attrs, klass)
      attrs.symbolize_keys!
      attrs[:class] = attrs[:class].blank? ? klass : "#{attrs[:class]} #{klass}"
      attrs
    end

    def attrs_with_additional_name(attrs, name)
      attrs_with_additional_class(attrs, ns(name))
    end

    def process_namespace_classes(node, n)
      unless node['class'].blank?
        node['class'] = node['class'].split(/ +/).map { |c|
          if c.start_with?('ns-')
            ns!(*n, *c[3..-1].split('--'))
          elsif c.start_with?('nsb-')
            ns!(*c[4..-1].split('--'))
          elsif c.start_with?('dns-')
            n = n + c[4..-1].split('--')
            ''
          elsif c.start_with?('dnsb-')
            n = c[5..-1].split('--')
            ''
          elsif c == 'nsr'
            nsr!(*n)
          elsif c.start_with?('nsr-')
            nsr!(*n, *c[4..-1].split('--'))
          elsif c.start_with?('nsrb-')
            nsr!(*c[5..-1].split('--'))
          elsif c.start_with?('dnsr-')
            n = n + c[5..-1].split('--')
            nsr!(*n)
          elsif c.start_with?('dnsrb-')
            n = c[6..-1].split('--')
            nsr!(*n)
          else
            c
          end
        }.join(' ')
      end
      node.children.each do |c|
        process_namespace_classes(c, n)
      end
    end
  end
end
