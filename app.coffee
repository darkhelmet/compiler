fs = require('fs')
less = require('less')
coffee = require('coffee-script')
jsp = require('uglify-js').parser
pro = require('uglify-js').uglify
request = require('request')

compress = (js) ->
    ast = jsp.parse(js)
    ast = pro.ast_mangle(ast)
    ast = pro.ast_squeeze(ast)
    pro.gen_code(ast)

getExtension = (filename) ->
    i = filename.lastIndexOf('.')
    if i < 0 then return '' else return filename.substr(i+1)

getFilename = (pathname) ->
    i = pathname.lastIndexOf('/')
    if i < 0 then return '' else return pathname.substr(i+1)

compiler = require('zappa') process.env.PORT,  ->
    @use(@express.bodyParser())

    @get '/', ->
        if (path = @request.query.u)?
            request path, (error, response, body) =>
                if error
                    console.log(error)
                    @send(400)
                else
                    filename = getFilename(response.request.href)
                    extension = getExtension(filename)
                    if extension is 'coffee'
                        try
                            js = coffee.compile(body)
                            js = compress(js) if @request.query.uglify
                            filename = filename.replace('coffee', 'js')
                            @response.attachment(filename)
                            @response.contentType('text/javascript')
                            @response.send(js)
                        catch error
                            console.log(error)
                            @send(400)
                    else if extension is 'less'
                        style = body
                        less.render style, { compress: @request.query.compress }, (error, css) =>
                            if error
                                console.log(error)
                                @send(400)
                            else
                                filename = filename.replace('less', 'css')
                                @response.attachment(filename)
                                @response.contentType('text/css')
                                @response.send(css)
                    else
                        @send(400)
        else
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
            less.render style, { compress: @request.body.compress }, (error, css) =>
                if error
                    console.log(error)
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
