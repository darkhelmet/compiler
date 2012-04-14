# compiler

A little app to compile less and coffee-script as a webservice

## Example

    curl -X POST -F coffee=@script.coffee http://compiler.herokuapp.com/
    curl -X POST -F less=@style.less http://compiler.herokuapp.com/
