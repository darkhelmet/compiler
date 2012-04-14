less = require('less')
coffee = require('coffee-script')

compiler = require('zappa') ->
    @use(@express.bodyParser())

    @get '/', ->
        @render('index')

    @post '/coffee', ->
        try
            js = coffee.compile(@request.body.coffee)
            @response.contentType('text/javascript')
            @send(js)
        catch error
            @send(400)

    @post '/less', ->
        less.render @request.body.less, (err, css) =>
            if err
                @send(400)
            else
                @response.contentType('text/css')
                @send(css)

    @view layout: ->
        doctype 5
        html ->
            head ->
                meta charset: 'utf-8'
                title 'Just compiling things...'
            body @body

    @view index: ->
        div ->
            form action: '/less', method: 'POST', ->
                label 'Less'
                textarea name: 'less'
                input type: 'submit'

        div ->
            form action: '/coffee', method: 'POST', ->
                label 'Coffee'
                textarea name: 'coffee'
                input type: 'submit'

compiler.app.listen(process.env.PORT || 3000)
