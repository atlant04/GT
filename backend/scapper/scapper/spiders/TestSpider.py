import scrapy
from scapper.loaders import BlogLoader
from scapper.items import Blog


class TestSpider(scrapy.Spider):
    name = "test"
    start_urls = [
        'https://blog.scrapinghub.com/page/1'
    ]

    def parse(self, response):
        b = BlogLoader(item=Blog(), response=response)
        b.add_css('title', 'div.post-header h2 a::text')
        return b.load_item()
