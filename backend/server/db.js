const MongoClient = require('mongodb').MongoClient
const uri = "mongodb+srv://admin:I83zA2NLzlb56URb@oscar-ima5l.mongodb.net/test?retryWrites=true&w=majority"
const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

var _db

module.exports = {
    connect: (callback) => client.connect(err => {
        _db = client.db("Oscar")
        callback(err)
    }),
    db: () => {
        return _db
    },
    close: () => client.close()
}