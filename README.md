##DESCRIPTION

Xass extends Rails with namespacing CSS classes in Sass.

##INSTALLATION

We suppose you use Rails with sass-rails.

###Gemfile

```rb
gem 'xass'
```

##USAGE

###Example 1

```sass
// /app/assets/stylesheets/application.sass

@import ./main/**/*
```

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

.hogehoge
  width: 100px
```

This emits the following css.

```css
.hoge__piyo__fuga___hogehoge {
  width: 100px;
}
```

And,

```haml
-# /app/views/someview.html.haml

= namespace :hoge, :piyo, :fuga do
  %div{ class: ns(:hogehoge) }
```

Then, you can apply `width: 100px` to the `div` element.

###Example 2

You can use `root` class for convenience.

```sass
// /app/assets/stylesheets/application.sass

@import ./main/**/*
```

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

.root
  width: 10px

.hogehoge
  width: 100px
```

This emits the following css.

```css
.hoge__piyo__fuga {
  width: 10px;
}

.hoge__piyo__fuga___hogehoge {
  width: 100px;
}
```

And,

```haml
-# /app/views/someview.html.haml

= namespace :hoge, :piyo, :fuga do
  %div{ class: ns_root }
    %div{ class: ns(:hogehoge) }
```

You can also write this as follows abbreviately.

```haml
-# /app/views/someview.html.haml

= namespace_with_root :hoge, :piyo, :fuga do
  %div{ class: ns(:hogehoge) }
```

###Example 3

You can use `_` prefix to disable namespacing.

```sass
// /app/assets/stylesheets/application.sass

@import ./main/**/*
```

```sass
// /app/assets/stylesheets/main/hoge/piyo/fuga.sass

.root
  width: 10px

.hogehoge
  width: 100px

._current
  background-color: black
```

This emits the following css.

```css
.hoge__piyo__fuga {
  width: 10px;
}

.hoge__piyo__fuga___hogehoge {
  width: 100px;
}

.current {
  background-color: black;
}
```