# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
import json
import pymongo


class MongoDBPipeline(object):

    def open_spider(self, spider):
        settings = spider.settings
        client = pymongo.MongoClient(settings['MONGODB_SERVER'])
        print(settings['MONGODB_SERVER'])
        db = client[settings['MONGODB_DB']]
        self.collection = db[settings['MONGODB_COLLECTION']]
        self.collection.create_index(
            [("fullname", pymongo.ASCENDING)], unique=True)

    def process_item(self, item, spider):
        self.collection.insert(dict(item))
        return item
