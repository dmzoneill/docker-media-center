#!/usr/bin/python3

import pycurl
from io import BytesIO
from pprint import pprint
import re

try: 
    from BeautifulSoup import BeautifulSoup
except ImportError:
    from bs4 import BeautifulSoup

def get_done():
    completed_t = []

    try:
        headers = []
        headers.append('authority: iptorrents.com')
        headers.append('cache-control: max-age=0')
        headers.append('sec-ch-ua: "Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"')
        headers.append('sec-ch-ua-mobile: ?0')
        headers.append('dnt: 1')
        headers.append('upgrade-insecure-requests: 1')
        headers.append('user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36')
        headers.append('accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9')
        headers.append('sec-fetch-site: same-origin')
        headers.append('sec-fetch-mode: navigate')
        headers.append('sec-fetch-user: ?1')
        headers.append('sec-fetch-dest: document')
        headers.append('referer: https://iptorrents.com/peers?u=1753756')
        headers.append('accept-language: en-GB,en-US;q=0.9,en;q=0.8')
        headers.append('cookie: uid=1753756; pass=7QpnpsRTANFObwu9wPEtQTS5qmdhUfsE; cf_clearance=28dff2f2b23471d5ad309ae0b4a64b3ed87cf537-1622813037-0-150')


        buffer = BytesIO()
        c = pycurl.Curl()
        c.setopt(c.URL, 'https://iptorrents.com/peers?u=1753756;o=10')
        c.setopt(pycurl.HTTPHEADER, headers)
        c.setopt(c.WRITEDATA, buffer)
        c.perform()
        c.close()

        body = buffer.getvalue()

        parsed_html = BeautifulSoup(body.decode('iso-8859-1'),features="lxml")
        table = parsed_html.body.find('table', attrs={'class':'t1'})
        rows = table.find_all("tr")

        completed_t = []

        for row in rows:
            cols = row.find_all("td")
            if len(cols) > 5:
                name = cols[0].get_text().ljust(50)
                completed = cols[2].get_text().ljust(10)
                uploaded = cols[3].get_text().ljust(10)
                uploadspeed = cols[4].get_text().ljust(10)
                downloaded = cols[5].get_text().ljust(10)
                downloadspeed = cols[6].get_text().ljust(10)
                togo = cols[7].get_text().ljust(10)

                if togo.strip() == "0.0 seconds":
                    #print('{0} {1} {3} {4} {5} {6}'.format(name, completed, uploaded, uploadspeed, downloaded, downloadspeed, togo))
                    name = name.strip().lower().replace(" ", ".")
                    name = re.sub(r'\.{2,}', ' ', name)
                    completed_t.append(name)
    except:
        return completed_t
        
    return completed_t

if __name__ == "__main__":
    pprint(get_done())