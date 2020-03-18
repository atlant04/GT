from scrapy.loader import ItemLoader
from scrapy.loader.processors import TakeFirst, MapCompose, Join


class BlogLoader(ItemLoader):
    title = TakeFirst()
    text = TakeFirst()
    date = TakeFirst()
