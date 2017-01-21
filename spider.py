from scrapy.selector import HtmlXPathSelector
from scrapy.spider import BaseSpider
from scrapy.http import Request

DOMAIN = 'lifeinthefastlane.com'
URL = 'http://%s' % DOMAIN

class MySpider(BaseSpider):
    name = DOMAIN
    allowed_domains = [DOMAIN]
    start_urls = [
        URL
    ]

    def parse(self, response):
        hxs = HtmlXPathSelector(response)
        for url in hxs.select('//a/@href').extract():
            if not ( url.startswith('http://') or url.startswith('https://') ):
                url= URL + url 
            if url.startswith('lifeinthefastlane.com/ecg-library/100-ecgs/'):
                print url + "&Quizzed"
            print url
            yield Request(url, callback=self.parse)