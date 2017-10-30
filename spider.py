#To run scrapy runspider spider.py > urls.out

from scrapy.selector import HtmlXPathSelector
from scrapy.spider import BaseSpider
from scrapy.http import Request
import re

DOMAIN = 'privatehealth.co.uk'
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

            matchObj = re.match( r'(.*)doctors-and-health-professionals(.*)', url, re.M|re.I)

            if matchObj:
               print url
            #print url
            yield Request(url, callback=self.parse)