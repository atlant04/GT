const express = require('express')
const parser = require('body-parser')
const app = express()
const monitor = require('./monitor.js')

const port = process.env.PORT || 3000
app.use(parser.urlencoded({
    extended: true
}))

app.use(express.json());

require('./db.js').connect(() => {
    app.use(require("./Routes/Course.js"))
    app.use(require("./Routes/Listener.js"))
    const worker = require("./Routes/Worker.js")
    app.listen(port, () => {
        console.log("Listening on port 3000")
        worker.startWorker()
        //monitor.start("https://ada7996e.ngrok.io/listen")
    })
})

//setInterval(() => publish(), 10000)