import mongodb from "mongodb"
const uri = "mongodb+srv://admin:I83zA2NLzlb56URb@oscar-ima5l.mongodb.net/test?retryWrites=true&w=majority"
const client = new mongodb.MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

export var db

export const connect = (callback) => client.connect(err => {
    db = client.db("Oscar")
    callback(err)
})


export const close = () => client.close()