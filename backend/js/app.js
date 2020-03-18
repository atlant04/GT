const express = require('express')
const parser = require('body-parser')
const app = express()
const port = process.env.PORT || 3000
app.use(parser.urlencoded({
    extended: true
}))

require('./db.js').connect(() => {
    app.use(require("./Routes/Course.js"))
    app.listen(port, () => console.log("Listening on port 3000"))
})