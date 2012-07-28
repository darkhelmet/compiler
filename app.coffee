fs = require('fs')
less = require('less')
coffee = require('coffee-script')
jsp = require('uglify-js').parser
pro = require('uglify-js').uglify

compress = (js) ->
    ast = jsp.parse(js)
    ast = pro.ast_mangle(ast)
    ast = pro.ast_squeeze(ast)
    pro.gen_code(ast)

compiler = require('zappa') process.env.PORT,  ->
    @use(@express.bodyParser())

    @get '/', ->
        @render('index')

    @post '/', ->
        if @request.files.coffee?
            try
                js = coffee.compile(fs.readFileSync(@request.files.coffee.path, 'utf8'))
                js = compress(js) if @request.body.uglify
                @response.contentType('text/javascript')
                @send(js)
            catch error
                console.log(error)
                @send(400)
        else if @request.files.less?
            style = fs.readFileSync(@request.files.less.path, 'utf8')
            less.render style, { compress: @request.body.compress }, (err, css) =>
                if err
                    console.log(err)
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
