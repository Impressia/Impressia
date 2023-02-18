# Vernissage

## Font

Font used in the application is: Fleur De Leah 
https://fonts.google.com/specimen/Fleur+De+Leah?preview.text=Vernissage%20for&preview.text_type=custom


## Issues

### **There are some issues in bookmarks/favourites endpoints**

It seems like paging is not working in that endpoints (I've tried with page and max_id).

Github issue: [https://github.com/pixelfed/pixelfed/issues/4182](https://github.com/pixelfed/pixelfed/issues/4182)

### **Update media attachment endpoint returns array instead of sinle entity**

On the https://pixelfed.social server, updating a single media attachment via the API (changing the description)
returns a list of media attachments in the response instead of the updated media attachment (it looks like there
are attachments of another user in the response).

Github issue: [https://github.com/pixelfed/pixelfed/issues/4196](https://github.com/pixelfed/pixelfed/issues/4196)


### **Follow/unfollow hashtags is not available through the API**

Pixelfed uses endpoint (POST): https://pixelfed.social/api/local/discover/tag/subscribe, with body:

```json
{
    "name": "streetphotography"
}
```

### **Bookmark/unbookmark statuses from external servers is not working (404 as a respnse)**

Here also Pixelfed uses different endpoing (POST):  https://pixelfed.social/i/bookmark, with body:

```json
{
    "item":"524216615476909436"
}
```

Even if we save bookmark on the web, we don't have reflected that information in statuses JSON. 

### **Reboost is not working**

Seems like reboost is working only from Pixelfed to Mastodon. When I'm following someone from Pixelfed
from my pixelfed account I don't see his reboost on my Pixelfed home timeline.  


### **Status doesn't contains information about bookmark status**

In the status JSON we don't have information about bookmark status.

### **Endpoint about instance information returns different JSON structure**

API in Pixelfed (`/api/v1/instance`) returns JSON with diefferent structure then API specify.

### **API always returns in the response `web` as an application**

In pixelfed source code there is hardcoded application name. API always retruns `web`.

```php
'application'               => [
    'name'      => 'web',
    'website'   => null
 ],
```

### ** (fixed) Place is not available in the API**

In the status response there is no information about place.
That information is visible when using Pixelfed web app. 

There is `place_id` field in status create endpoint.
For search there is an endpoint: `https://{{host}}/api/v1.1/compose/search/location?q=wroc`.

### **(fixed) Trends are not availabe through the API**

Pixelfed uses endpoint (GET): https://pixelfed.social/api/pixelfed/v2/discover/posts/trending?range=daily
This endpoint is not working in different servers e.g.: https://pxlmo.com/api/pixelfed/v2/discover/posts/trending?range=daily

Mastodon endpoint `/api/v1/trends/statuses` is not available (404 response). 

Trends are available via: `/api/v1.1/discover/posts/trending`.
