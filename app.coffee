fs = require('fs')
less = require('less')
coffee = require('coffee-script')

compiler = require('zappa') process.env.PORT,  ->
    @use(@express.bodyParser())

    @get '/', ->
        @render('index')

    @post '/', ->
        if @request.files.coffee?
            try
                js = coffee.compile(fs.readFileSync(@request.files.coffee.path, 'utf8'))
                @response.contentType('text/javascript')
                @send(js)
            catch error
                @send(400)
        else if @request.files.less?
            less.render fs.readFileSync(@request.files.less.path, 'utf8'), (err, css) =>
                if err
                    @send(400)
                else
                    @response.contentType('text/css')
                    @send(css)
        else
            @send(400)

    @view layout: ->
        doctype 5
        html ->
            head ->
                meta charset: 'utf-8'
                title 'Just compiling things...'
            body @body

    @view index: ->
        h1 ->
            a href: 'https://github.com/darkhelmet/compiler', "Everyday I'm compilin'..."
