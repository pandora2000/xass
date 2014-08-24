module Xass
  module ViewHelpers
    def namespace(*names, reset: false, &block)
      nss = namespaces
      if reset
        @namespaces = [names]
      else
        @namespaces = nss + [names]
      end
      res = capture(&block)
      @namespaces = nss
      res
    end

    def namespace!(*names, &block)
      namespace(*names, reset: true, &block)
    end

    def namespace_with_root(*names, tag: :div, attrs: {}, reset: false, &block)
      nss = reset ? [] : namespaces
      content_tag(tag, block ? namespace(*names, reset: reset, &block) : '', attrs_with_additional_class(attrs, ns_root!(*(nss.flatten + names))))
    end

    def namespace_with_root!(*names, tag: :div, attrs: {}, &block)
      namespace_with_root(*names, tag: tag, attrs: attrs, reset: true, &(block || Proc.new {}))
    end

    def ns_wrap(name = :wrap, _tag = nil, _attrs = nil, tag: :div, attrs: {}, &block)
      _tag ||= tag
      _attrs ||= attrs
      content_tag(_tag, block ? capture(&block) : '', attrs_with_additional_name(_attrs, name))
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

    def ns_root(*names)
      ns_root!(*(namespaces.flatten + names))
    end

    def ns_root!(*names)
      names.map(&:to_s).join('__')
    end

    def ns(*names)
      "#{ns_root(*names[0...-1])}___#{names[-1]}"
    end

    def ns!(*names)
      "#{ns_root!(*names[0...-1])}___#{names[-1]}"
    end

    private

    def namespaces
      @namespaces ||= []
    end

    def attrs_with_additional_class(attrs, klass)
      attrs.symbolize_keys!
      attrs[:class] = attrs[:class].blank? ? klass : "#{attrs[:class]} #{klass}"
      attrs
    end

    def attrs_with_additional_name(attrs, name)
      attrs_with_additional_class(attrs, ns(name))
    end
  end
end
