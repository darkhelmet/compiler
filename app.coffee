fs = require('fs')
less = require('less')
coffee = require('coffee-script')
jsp = require('uglify-js').parser
pro = require('uglify-js').uglify
request = require('request')
express = require('express')
bodyParser = require('body-parser')
fileUpload = require('express-fileupload')

compress = (js) ->
    ast = jsp.parse(js)
    ast = pro.ast_mangle(ast)
    ast = pro.ast_squeeze(ast)
    pro.gen_code(ast)


app = express()
app.use(fileUpload())
app.use(bodyParser.urlencoded(extended: true))

app.get '/', (req, res) ->
    if req.query.coffee?
        request req.query.coffee, (error, response, body) =>
            if error
                console.log(error)
                res.send(400)
            else
                try
                    js = coffee.compile(body)
                    js = compress(js) if req.query.uglify
                    filename = (req.query.filename ? 'compiled') + '.js'
                    res.attachment(filename)
                    res.send(js)
                catch error
                    console.log(error)
                    res.send(400)
    else if req.query.less?
        request req.query.less, (error, response, body) =>
            if error
                console.log(error)
                res.send(400)
            else
                less.render body, { compress: req.query.compress }, (error, compiled) =>
                    if error
                        console.log(error)
                        res.send(400)
                    else
                        filename = (req.query.filename ? 'compiled') + '.css'
                        res.attachment(filename)
                        res.send(compiled.css)
    else
        res.send('https://github.com/darkhelmet/compiler')

app.post '/', (req, res)->
    if req.files.coffee?
        try
            js = coffee.compile(req.files.coffee.data.toString())
            js = compress(js) if req.body.uglify
            res.contentType('text/javascript')
            res.send(js)
        catch error
            console.log(error)
            res.send(400)
    else if req.files.less?
        style = req.files.less.data.toString()
        less.render style, { compress: req.body.compress }, (error, compiled) =>
            if error
                console.log(error)
                res.send(400)
            else
                res.contentType('text/css')
                res.send(compiled.css)
    else
        res.send(400)

port = process.env.PORT or 3000

app.listen port, ->
  console.log("listening on #{port}")
