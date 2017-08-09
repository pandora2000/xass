## DESCRIPTION

Xass extends Rails with namespacing CSS classes in Sass.

## SUPPORT

|Xass version|Supported Sass version|
|:-:|:-:|
|0.3.0|3.4.7~3.4.10|
|0.2.0|3.2.19|

## INSTALLATION

We suppose you use Rails with sass-rails.

### Gemfile

```rb
gem 'xass'
```

## USAGE

### Namespacing by directory tree

```sass
// /app/assets/stylesheets/application.sass

@import ./main/**/*
```

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

.hogehoge
  width: 100px
```

This emits the following css (notice that there are three underscores before `hogehoge`.)

```css
.hoge__piyo__fuga___hogehoge {
  width: 100px;
}
```

In view, use helpers or `ns` prefixed class names to apply the style.

```haml
-# /app/views/someview.html.haml

= namespace :hoge, :piyo, :fuga do
  .ns-hogehoge
  -# or %div{ class: ns(:hogehoge) }
```

This emits

```html
<div class="hoge__piyo__fuga___hogehoge"></div>
```

As matter of course, `namespace` can be nested as follows.

```haml
-# /app/views/someview.html.haml

= namespace :hoge do
  = namespace :piyo do
    = namespace :fuga do
      .ns-hogehoge
```

If you don't want to dig namespaces, you can specify namespaces directly in `ns` prefixed class name.

```haml
= namespace :hoge do
  .ns-piyo--fuga--hogehoge
```

### Special class name `root`

You can use `root` class for specify a root class name.

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

.root
  width: 10px
```

This emits

```css
.hoge__piyo__fuga {
  width: 10px;
}
```

And,

```haml
-# /app/views/someview.html.haml

= namespace :hoge, :piyo, :fuga do
  .nsr
  -# or %div{ class: nsr }
```

This emits

```html
<div class="hoge__piyo__fuga"></div>
```

Abbreviately, you can write this as follows.

```haml
-# /app/views/someview.html.haml

= namespace_with_root :hoge, :piyo, :fuga
```

### Disable namespacing

You can use `_` prefix to disable namespacing.

```sass
// /app/assets/stylesheets/application.sass

@import ./main/**/*
```

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

._current
  background-color: black
```

This emits the following css.

```css
.current {
  background-color: black;
}
```

### Reset current namespace

In partial, you may want to reset current namespace. `namespace!` and `namespace_with_root!` do this.

```haml
-# /app/views/someview.html.haml

= namespace_with_root :hoge, :piyo, :fuga do
  = render partial: 'partial'
```

```haml
-# /app/views/_partial.html.haml

= namespace_with_root! :foo do
  foo
```

This emits

```html
<div class="hoge__piyo__fuga">
  <div class="foo">
    foo
  </div>
</div>
```

### Abbreviations

The following aliases are available.

```ruby
alias :dns :namespace
alias :dns! :namespace!
alias :dnsr :namespace_with_root
alias :dnsr! :namespace_with_root!
```
